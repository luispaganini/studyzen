import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:studyzen/services/disciplina_service.dart';

void main() {
  const baseUrl = 'http://api.test';

  test('listar faz GET e converte JSON em disciplinas', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.toString(), '$baseUrl/api/disciplinas');
      return http.Response(
        jsonEncode([
          {'id': 1, 'nome': 'Cálculo', 'cargaHoraria': 60, 'criadoEm': '2026-10-12T10:00:00Z'},
        ]),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final lista = await DisciplinaService(client: client, baseUrl: baseUrl).listar();

    expect(lista, hasLength(1));
    expect(lista.first.nome, 'Cálculo');
    expect(lista.first.cargaHoraria, 60);
  });

  test('criar faz POST com corpo JSON e retorna a disciplina criada', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(jsonDecode(request.body), {'nome': 'Física', 'cargaHoraria': 40});
      return http.Response(
        jsonEncode({'id': 7, 'nome': 'Física', 'cargaHoraria': 40, 'criadoEm': '2026-10-12T10:00:00Z'}),
        201,
      );
    });

    final criada = await DisciplinaService(client: client, baseUrl: baseUrl).criar(nome: 'Física', cargaHoraria: 40);

    expect(criada.id, 7);
  });

  test('criar lança ApiException com mensagens de validação do backend', () async {
    final client = MockClient((_) async => http.Response(
          jsonEncode({
            'title': 'One or more validation errors occurred.',
            'errors': {
              'Nome': ['O nome é obrigatório.'],
            },
          }),
          400,
        ));

    expect(
      () => DisciplinaService(client: client, baseUrl: baseUrl).criar(nome: '', cargaHoraria: 10),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', 'O nome é obrigatório.')),
    );
  });

  test('falha de rede vira ApiException amigável', () async {
    final client = MockClient((_) async => throw http.ClientException('offline'));

    expect(
      () => DisciplinaService(client: client, baseUrl: baseUrl).listar(),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('conectar'))),
    );
  });
}
