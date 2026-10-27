import 'package:flutter/foundation.dart';

import '../core/view_state.dart';
import '../models/disciplina.dart';
import '../services/disciplina_service.dart';

class DisciplinasViewModel extends ChangeNotifier {
  final DisciplinaService _service;

  DisciplinasViewModel(this._service);

  List<Disciplina> _disciplinas = [];
  ViewState _state = ViewState.idle;
  String _errorMessage = '';

  List<Disciplina> get disciplinas => List.unmodifiable(_disciplinas);
  ViewState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isEmpty => _state == ViewState.success && _disciplinas.isEmpty;
  int get cargaHorariaTotal => _disciplinas.fold(0, (sum, d) => sum + d.cargaHoraria);

  Future<void> carregar() async {
    _state = ViewState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _disciplinas = await _service.listar();
      _state = ViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }

  void adicionar(Disciplina disciplina) {
    _disciplinas = [..._disciplinas, disciplina]
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    _state = ViewState.success;
    notifyListeners();
  }
}
