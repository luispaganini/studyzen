import 'package:flutter/foundation.dart';

import '../models/disciplina.dart';
import '../services/disciplina_service.dart';

class DisciplinaFormViewModel extends ChangeNotifier {
  static const maxNome = 120;
  static const minCarga = 1;
  static const maxCarga = 1000;

  final DisciplinaService _service;

  DisciplinaFormViewModel(this._service);

  bool _isSaving = false;
  String? _errorMessage;

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  String? validarNome(String? value) {
    final nome = value?.trim() ?? '';
    if (nome.isEmpty) return 'Informe o nome da disciplina';
    if (nome.length > maxNome) return 'Máximo de $maxNome caracteres';
    return null;
  }

  String? validarCargaHoraria(String? value) {
    final carga = int.tryParse(value?.trim() ?? '');
    if (carga == null) return 'Informe a carga horária em horas';
    if (carga < minCarga || carga > maxCarga) return 'Entre $minCarga e $maxCarga horas';
    return null;
  }

  Future<Disciplina?> salvar({required String nome, required String cargaHoraria}) async {
    if (_isSaving) return null;
    if (validarNome(nome) != null || validarCargaHoraria(cargaHoraria) != null) return null;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _service.criar(nome: nome.trim(), cargaHoraria: int.parse(cargaHoraria.trim()));
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
