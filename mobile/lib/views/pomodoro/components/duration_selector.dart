import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../viewmodels/pomodoro_viewmodel.dart';

class DurationSelector extends StatelessWidget {
  final int minutes;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const DurationSelector({
    super.key,
    required this.minutes,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: enabled ? 1 : 0.35,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                key: const Key('pomodoroMinus'),
                onPressed: enabled && minutes > PomodoroViewModel.minMinutes ? () => onChanged(minutes - 1) : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              SizedBox(
                width: 120,
                child: Text(
                  '$minutes min',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton.filledTonal(
                key: const Key('pomodoroPlus'),
                onPressed: enabled && minutes < PomodoroViewModel.maxMinutes ? () => onChanged(minutes + 1) : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: [
              for (final preset in PomodoroViewModel.presets)
                ChoiceChip(
                  key: Key('preset$preset'),
                  label: Text('$preset min'),
                  selected: minutes == preset,
                  onSelected: enabled ? (_) => onChanged(preset) : null,
                  selectedColor: AppColors.primary.withValues(alpha: 0.25),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
