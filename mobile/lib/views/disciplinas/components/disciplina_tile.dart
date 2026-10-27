import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/disciplina.dart';

class DisciplinaTile extends StatelessWidget {
  final Disciplina disciplina;

  const DisciplinaTile({super.key, required this.disciplina});

  @override
  Widget build(BuildContext context) {
    final inicial = disciplina.nome.characters.first.toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppColors.focusGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            inicial,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.background),
          ),
        ),
        title: Text(disciplina.nome, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${disciplina.cargaHoraria}h de carga horária',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
