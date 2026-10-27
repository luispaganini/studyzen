import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'services/disciplina_service.dart';
import 'services/notification_service.dart';
import 'viewmodels/disciplinas_viewmodel.dart';
import 'viewmodels/pomodoro_viewmodel.dart';
import 'views/shell/home_shell.dart';

class StudyZenApp extends StatelessWidget {
  final DisciplinaService disciplinaService;
  final NotificationService notificationService;
  final AlertPlayer alertPlayer;

  const StudyZenApp({
    super.key,
    required this.disciplinaService,
    required this.notificationService,
    required this.alertPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DisciplinaService>.value(value: disciplinaService),
        ChangeNotifierProvider(create: (_) => DisciplinasViewModel(disciplinaService)..carregar()),
        ChangeNotifierProvider(
          create: (_) => PomodoroViewModel(notifications: notificationService, alert: alertPlayer),
        ),
      ],
      child: MaterialApp(
        title: 'StudyZen',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const HomeShell(),
      ),
    );
  }
}
