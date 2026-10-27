import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/avaliacao.dart';

class AvaliacaoTile extends StatelessWidget {
  final Avaliacao avaliacao;

  const AvaliacaoTile({super.key, required this.avaliacao});

  @override
  Widget build(BuildContext context) {
    final formatadorData = '${avaliacao.dataEntrega.day.toString().padLeft(2, '0')}/${avaliacao.dataEntrega.month.toString().padLeft(2, '0')}/${avaliacao.dataEntrega.year}';
    final diasRestantes = avaliacao.dataEntrega.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    avaliacao.tipo,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.event_rounded,
                  size: 16,
                  color: diasRestantes < 3 ? AppColors.danger : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  formatadorData,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: diasRestantes < 3 ? AppColors.danger : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              avaliacao.titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            if (avaliacao.disciplinaNome != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.menu_book_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    avaliacao.disciplinaNome!,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
            if (avaliacao.subtarefas.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white10),
              const SizedBox(height: 6),
              const Text(
                'Etapas decompostas:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary),
              ),
              const SizedBox(height: 4),
              for (final sub in avaliacao.subtarefas)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.secondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          sub.titulo,
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
