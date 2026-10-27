import 'package:flutter/material.dart';

import 'app.dart';
import 'services/disciplina_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notifications = LocalNotificationService();
  await notifications.init();

  runApp(StudyZenApp(
    disciplinaService: DisciplinaService(),
    notificationService: notifications,
    alertPlayer: SystemAlertPlayer(),
  ));
}
