import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class HumorScaleSelector extends StatelessWidget {
  final void Function(int nivel, String emoji, String sentimento) onSelect;
  final bool isSaving;

  const HumorScaleSelector({
    super.key,
    required this.onSelect,
    this.isSaving = false,
  });

  static const List<({int nivel, String emoji, String sentimento})> opcoes = [
    (nivel: 1, emoji: '😫', sentimento: 'Muito estressado'),
    (nivel: 2, emoji: '🙁', sentimento: 'Estressado'),
    (nivel: 3, emoji: '😐', sentimento: 'Neutro'),
    (nivel: 4, emoji: '🙂', sentimento: 'Produtivo'),
    (nivel: 5, emoji: '😄', sentimento: 'Excelente'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mood_rounded, color: AppColors.secondary, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Como foi seu foco hoje?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              if (isSaving) ...[
                const Spacer(),
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Toque para registrar seu humor imediatamente.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final op in opcoes)
                _EmojiButton(
                  key: Key('humorEmoji-${op.nivel}'),
                  emoji: op.emoji,
                  label: op.sentimento,
                  onTap: isSaving ? null : () => onSelect(op.nivel, op.emoji, op.sentimento),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmojiButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback? onTap;

  const _EmojiButton({
    super.key,
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 4),
            Text(
              label.split(' ').first,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
