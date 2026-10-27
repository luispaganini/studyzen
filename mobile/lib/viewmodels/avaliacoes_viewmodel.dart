import 'package:flutter/foundation.dart';

import '../core/view_state.dart';
import '../models/avaliacao.dart';
import '../services/avaliacao_service.dart';

class AvaliacoesViewModel extends ChangeNotifier {
  final AvaliacaoService _service;

  AvaliacoesViewModel(this._service);

  ViewState _state = ViewState.idle;
  List<Avaliacao> _avaliacoes = [];
  String _errorMessage = '';

  ViewState get state => _state;
  List<Avaliacao> get avaliacoes => _avaliacoes;
  String get errorMessage => _errorMessage;
  bool get isEmpty => _state == ViewState.success && _avaliacoes.isEmpty;

  Future<void> carregar() async {
    _state = ViewState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _avaliacoes = await _service.listar();
      _state = ViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    } finally {
      notifyListeners();
    }
  }

  void adicionar(Avaliacao nova) {
    _avaliacoes = [..._avaliacoes, nova]
      ..sort((a, b) => a.dataEntrega.compareTo(b.dataEntrega));
    _state = ViewState.success;
    notifyListeners();
  }
}

