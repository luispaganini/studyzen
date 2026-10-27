import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/notification_service.dart';

enum PomodoroStatus { idle, running, paused, finished }

class PomodoroViewModel extends ChangeNotifier {
  static const defaultMinutes = 25;
  static const minMinutes = 1;
  static const maxMinutes = 90;
  static const presets = [15, 25, 45];
  static const notificationId = 1001;

  final NotificationService _notifications;
  final AlertPlayer _alert;
  final DateTime Function() _now;
  final Duration _tickInterval;

  PomodoroViewModel({
    required NotificationService notifications,
    required AlertPlayer alert,
    DateTime Function()? now,
    Duration tickInterval = const Duration(milliseconds: 250),
  })  : _now = now ?? DateTime.now,
        _notifications = notifications,
        _alert = alert,
        _tickInterval = tickInterval;

  int _minutes = defaultMinutes;
  Duration _remaining = const Duration(minutes: defaultMinutes);
  PomodoroStatus _status = PomodoroStatus.idle;
  DateTime? _endsAt;
  Timer? _ticker;

  int get minutes => _minutes;
  Duration get total => Duration(minutes: _minutes);
  Duration get remaining => _remaining;
  PomodoroStatus get status => _status;
  DateTime? get endsAt => _endsAt;
  bool get isRunning => _status == PomodoroStatus.running;
  bool get canConfigure => _status == PomodoroStatus.idle || _status == PomodoroStatus.finished;

  double get progress {
    final totalMs = total.inMilliseconds;
    if (totalMs == 0) return 0;
    return (1 - _remaining.inMilliseconds / totalMs).clamp(0.0, 1.0);
  }

  String get formattedRemaining {
    final seconds = (_remaining.inMilliseconds / 1000).ceil();
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  void setMinutes(int value) {
    if (!canConfigure) return;
    _minutes = value.clamp(minMinutes, maxMinutes);
    _remaining = total;
    _status = PomodoroStatus.idle;
    notifyListeners();
  }

  Future<void> start() async {
    if (_status == PomodoroStatus.running) return;
    final base = _status == PomodoroStatus.paused ? _remaining : total;
    _remaining = base;
    _endsAt = _now().add(base);
    _status = PomodoroStatus.running;
    _startTicker();
    notifyListeners();

    await _notifications.ensurePermissions();
    if (_status != PomodoroStatus.running || _endsAt == null) return;
    await _notifications.scheduleAt(
      id: notificationId,
      at: _endsAt!,
      title: 'Sessão de foco concluída! 🎉',
      body: 'Você focou por $_minutes minutos. Hora de uma pausa.',
    );
  }

  Future<void> pause() async {
    if (_status != PomodoroStatus.running) return;
    _recalculate();
    if (_status != PomodoroStatus.running) return;
    _stopTicker();
    _endsAt = null;
    _status = PomodoroStatus.paused;
    notifyListeners();
    await _notifications.cancel(notificationId);
  }

  Future<void> reset() async {
    _stopTicker();
    _endsAt = null;
    _remaining = total;
    _status = PomodoroStatus.idle;
    notifyListeners();
    await _notifications.cancel(notificationId);
  }

  void sync() {
    if (_status != PomodoroStatus.running) return;
    _recalculate();
    notifyListeners();
  }

  void _recalculate() {
    final left = _endsAt!.difference(_now());
    if (left <= Duration.zero) {
      _finish();
    } else {
      _remaining = left;
    }
  }

  void _finish() {
    _stopTicker();
    _endsAt = null;
    _remaining = Duration.zero;
    _status = PomodoroStatus.finished;
    _alert.play();
  }

  void _startTicker() {
    _stopTicker();
    _ticker = Timer.periodic(_tickInterval, (_) => sync());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
