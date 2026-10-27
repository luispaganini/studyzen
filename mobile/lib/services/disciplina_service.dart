import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/disciplina.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class DisciplinaService {
  final http.Client _client;
  final String _baseUrl;

  DisciplinaService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  Uri get _endpoint => Uri.parse('$_baseUrl/api/disciplinas');

  Future<List<Disciplina>> listar() async {
    final response = await _send(() => _client.get(_endpoint));
    final body = jsonDecode(response.body) as List<dynamic>;
    return body.map((e) => Disciplina.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Disciplina> criar({required String nome, required int cargaHoraria}) async {
    final response = await _send(() => _client.post(
          _endpoint,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'nome': nome, 'cargaHoraria': cargaHoraria}),
        ));
    return Disciplina.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request();
    } catch (_) {
      throw const ApiException('Não foi possível conectar ao servidor.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) return response;
    throw ApiException(_extractError(response));
  }

  String _extractError(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final errors = body['errors'];
      if (errors is Map<String, dynamic> && errors.isNotEmpty) {
        return errors.values.expand((v) => (v as List).cast<String>()).join('\n');
      }
      final title = body['title'];
      if (title is String) return title;
    } catch (_) {}
    return 'Erro inesperado (${response.statusCode}).';
  }
}
