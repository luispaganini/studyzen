import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/pomodoro_viewmodel.dart';
import '../disciplinas/disciplinas_screen.dart';
import '../pomodoro/pomodoro_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => context.read<PomodoroViewModel>().sync(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: const [PomodoroScreen(), DisciplinasScreen()],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              key: Key('tabFoco'),
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer_rounded),
              label: 'Foco',
            ),
            NavigationDestination(
              key: Key('tabDisciplinas'),
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: 'Disciplinas',
            ),
          ],
        ),
      ),
    );
  }
}
