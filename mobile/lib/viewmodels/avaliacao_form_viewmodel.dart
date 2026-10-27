import 'package:flutter/foundation.dart';

import '../models/avaliacao.dart';
import '../services/avaliacao_service.dart';

class AvaliacaoFormViewModel extends ChangeNotifier {
  static const maxTitulo = 120;

  final AvaliacaoService _service;

  AvaliacaoFormViewModel(this._service);

  bool _isSaving = false;
  bool _isDecompondo = false;
  String? _errorMessage;

  int? _disciplinaId;
  String _tipo = 'Trabalho de Conclusão';
  DateTime? _dataEntrega;
  List<String> _subtarefas = [];

  bool get isSaving => _isSaving;
  bool get isDecompondo => _isDecompondo;
  String? get errorMessage => _errorMessage;

  int? get disciplinaId => _disciplinaId;
  String get tipo => _tipo;
  DateTime? get dataEntrega => _dataEntrega;
  List<String> get subtarefas => _subtarefas;

  void setDisciplina(int? id) {
    _disciplinaId = id;
    notifyListeners();
  }

  void setTipo(String novoTipo) {
    _tipo = novoTipo;
    notifyListeners();
  }

  void setDataEntrega(DateTime data) {
    _dataEntrega = data;
    notifyListeners();
  }

  void adicionarSubtarefa(String titulo) {
    if (titulo.trim().isEmpty) return;
    _subtarefas = [..._subtarefas, titulo.trim()];
    notifyListeners();
  }

  void removerSubtarefa(int index) {
    if (index < 0 || index >= _subtarefas.length) return;
    final copy = [..._subtarefas]..removeAt(index);
    _subtarefas = copy;
    notifyListeners();
  }

  Future<void> decompor() async {
    _isDecompondo = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final sugeridas = await _service.obterDecomposicao(_tipo);
      _subtarefas = [..._subtarefas, ...sugeridas];
    } catch (e) {
      _errorMessage = 'Não foi possível decompor automaticamente.';
    } finally {
      _isDecompondo = false;
      notifyListeners();
    }
  }

  String? validarTitulo(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Informe o título da avaliação';
    if (t.length > maxTitulo) return 'Máximo de $maxTitulo caracteres';
    return null;
  }

  Future<Avaliacao?> salvar({required String titulo}) async {
    if (_isSaving) return null;
    if (_disciplinaId == null) {
      _errorMessage = 'Selecione uma disciplina.';
      notifyListeners();
      return null;
    }
    if (_dataEntrega == null) {
      _errorMessage = 'Selecione a data de entrega.';
      notifyListeners();
      return null;
    }
    if (validarTitulo(titulo) != null) return null;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final subs = _subtarefas.map((s) => Subtarefa(titulo: s)).toList();
      return await _service.criar(
        disciplinaId: _disciplinaId!,
        titulo: titulo.trim(),
        tipo: _tipo,
        dataEntrega: _dataEntrega!,
        subtarefas: subs,
      );
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}

