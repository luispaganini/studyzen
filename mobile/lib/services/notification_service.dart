import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

abstract class NotificationService {
  Future<void> init();
  Future<void> ensurePermissions();
  Future<void> scheduleAt({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  });
  Future<void> cancel(int id);
}

abstract class AlertPlayer {
  Future<void> play();
}

class SystemAlertPlayer implements AlertPlayer {
  @override
  Future<void> play() async {
    await SystemSound.play(SystemSoundType.alert);
    await HapticFeedback.heavyImpact();
  }
}

class LocalNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  final Map<int, Timer> _fallbackTimers = {};
  bool _initialized = false;
  bool _permissionsRequested = false;

  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'pomodoro_channel',
      'Pomodoro',
      channelDescription: 'Avisos de fim de sessão de foco',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    ),
    iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true, presentBanner: true),
    linux: LinuxNotificationDetails(),
  );

  bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<void> init() async {
    if (_initialized || kIsWeb) return;
    tzdata.initializeTimeZones();
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestSoundPermission: false,
            requestBadgePermission: false,
          ),
          linux: LinuxInitializationSettings(defaultActionName: 'Abrir StudyZen'),
        ),
      );
      _initialized = true;
    } catch (e) {
      debugPrint('Notificações indisponíveis: $e');
    }
  }

  @override
  Future<void> ensurePermissions() async {
    if (_permissionsRequested || !_initialized) return;
    _permissionsRequested = true;
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, sound: true);
  }

  @override
  Future<void> scheduleAt({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    await cancel(id);

    if (!_isMobile) {
      final delay = at.difference(DateTime.now());
      _fallbackTimers[id] = Timer(delay.isNegative ? Duration.zero : delay, () {
        _fallbackTimers.remove(id);
        _plugin.show(id: id, title: title, body: body, notificationDetails: _details);
      });
      return;
    }

    final scheduled = tz.TZDateTime.from(at.toUtc(), tz.UTC);
    try {
      await _plugin.zonedSchedule(
        id: id,
        scheduledDate: scheduled,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        title: title,
        body: body,
      );
    } on PlatformException {
      await _plugin.zonedSchedule(
        id: id,
        scheduledDate: scheduled,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: title,
        body: body,
      );
    }
  }

  @override
  Future<void> cancel(int id) async {
    _fallbackTimers.remove(id)?.cancel();
    if (!_initialized) return;
    await _plugin.cancel(id: id);
  }
}
