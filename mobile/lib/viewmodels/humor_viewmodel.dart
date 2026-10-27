import 'package:flutter/foundation.dart';

import '../core/view_state.dart';
import '../models/humor.dart';
import '../services/humor_service.dart';

class HumorViewModel extends ChangeNotifier {
  final HumorService _service;

  HumorViewModel(this._service);

  ViewState _state = ViewState.idle;
  List<RegistroHumor> _historico = [];
  String _errorMessage = '';
  RegistroHumor? _ultimoRegistro;

  ViewState get state => _state;
  List<RegistroHumor> get historico => _historico;
  String get errorMessage => _errorMessage;
  RegistroHumor? get ultimoRegistro => _ultimoRegistro;

  Future<void> carregar() async {
    _state = ViewState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _historico = await _service.listar();
      if (_historico.isNotEmpty) {
        _ultimoRegistro = _historico.first;
      }
      _state = ViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> registrarHumor({
    required int nivel,
    required String emoji,
    String? sentimento,
  }) async {
    try {
      final salvo = await _service.registrar(
        nivel: nivel,
        emoji: emoji,
        sentimento: sentimento,
      );
      _ultimoRegistro = salvo;
      _historico = [salvo, ..._historico];
      _state = ViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}

