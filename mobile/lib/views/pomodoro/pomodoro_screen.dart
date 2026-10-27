import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/pomodoro_viewmodel.dart';
import 'components/duration_selector.dart';
import 'components/pomodoro_controls.dart';
import 'components/timer_ring.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PomodoroViewModel>();
    final caption = switch (vm.status) {
      PomodoroStatus.running => 'FOCANDO',
      PomodoroStatus.paused => 'PAUSADO',
      PomodoroStatus.finished => 'CONCLUÍDO',
      PomodoroStatus.idle => 'PRONTO',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Foco')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => AppColors.focusGradient.createShader(bounds),
                  child: const Text(
                    'Uma tarefa de cada vez.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 32),
                TimerRing(
                  progress: vm.progress,
                  label: vm.formattedRemaining,
                  caption: caption,
                  active: vm.isRunning,
                ),
                const SizedBox(height: 40),
                PomodoroControls(
                  status: vm.status,
                  onStart: vm.start,
                  onPause: vm.pause,
                  onReset: vm.reset,
                ),
                const SizedBox(height: 32),
                DurationSelector(
                  minutes: vm.minutes,
                  enabled: vm.canConfigure,
                  onChanged: vm.setMinutes,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
