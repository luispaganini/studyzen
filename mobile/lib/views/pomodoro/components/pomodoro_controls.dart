import 'package:flutter/material.dart';

import '../../../viewmodels/pomodoro_viewmodel.dart';

class PomodoroControls extends StatelessWidget {
  final PomodoroStatus status;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;

  const PomodoroControls({
    super.key,
    required this.status,
    required this.onStart,
    required this.onPause,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final running = status == PomodoroStatus.running;
    final label = switch (status) {
      PomodoroStatus.running => 'Pausar',
      PomodoroStatus.paused => 'Retomar',
      PomodoroStatus.finished => 'Nova sessão',
      PomodoroStatus.idle => 'Iniciar foco',
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
          child: FilledButton.icon(
            key: ValueKey('pomodoroPrimary-$status'),
            onPressed: running ? onPause : onStart,
            icon: Icon(running ? Icons.pause_rounded : Icons.play_arrow_rounded),
            label: Text(label),
          ),
        ),
        const SizedBox(width: 12),
        IconButton.outlined(
          key: const Key('pomodoroReset'),
          tooltip: 'Reiniciar',
          onPressed: status == PomodoroStatus.idle ? null : onReset,
          icon: const Icon(Icons.restart_alt_rounded),
          padding: const EdgeInsets.all(16),
        ),
      ],
    );
  }
}
