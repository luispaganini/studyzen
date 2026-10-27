import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyzen/core/view_state.dart';
import 'package:studyzen/viewmodels/avaliacao_form_viewmodel.dart';
import 'package:studyzen/viewmodels/avaliacoes_viewmodel.dart';

import '../helpers/test_doubles.dart';

void main() {
  group('AvaliacoesViewModel', () {
    late MockAvaliacaoService service;
    late AvaliacoesViewModel vm;

    setUp(() {
      service = MockAvaliacaoService();
      vm = AvaliacoesViewModel(service);
    });

    test('carregar popula avaliações com sucesso', () async {
      when(() => service.listar()).thenAnswer((_) async => [avaliacao(1, 'Prova 1')]);

      await vm.carregar();

      expect(vm.state, ViewState.success);
      expect(vm.avaliacoes, hasLength(1));
      expect(vm.avaliacoes.first.titulo, 'Prova 1');
    });

    test('adicionar mantém ordenação pela data de entrega mais próxima', () {
      final a1 = avaliacao(1, 'Mais longe', data: DateTime.utc(2026, 11, 20));
      final a2 = avaliacao(2, 'Mais perto', data: DateTime.utc(2026, 11, 10));

      vm.adicionar(a1);
      vm.adicionar(a2);

      expect(vm.avaliacoes.first.id, 2);
      expect(vm.avaliacoes.last.id, 1);
    });
  });

  group('AvaliacaoFormViewModel', () {
    late MockAvaliacaoService service;
    late AvaliacaoFormViewModel vm;

    setUp(() {
      service = MockAvaliacaoService();
      vm = AvaliacaoFormViewModel(service);
    });

    test('decompor busca subtarefas automáticas', () async {
      when(() => service.obterDecomposicao('Trabalho de Conclusão'))
          .thenAnswer((_) async => ['Pesquisa', 'Rascunho', 'Revisão']);

      vm.setTipo('Trabalho de Conclusão');
      await vm.decompor();

      expect(vm.subtarefas, ['Pesquisa', 'Rascunho', 'Revisão']);
    });

    test('removerSubtarefa remove etapa da lista', () {
      vm.adicionarSubtarefa('Etapa 1');
      vm.adicionarSubtarefa('Etapa 2');
      vm.removerSubtarefa(0);

      expect(vm.subtarefas, ['Etapa 2']);
    });

    test('salvar exige disciplina e data', () async {
      final res = await vm.salvar(titulo: 'Teste');
      expect(res, isNull);
      expect(vm.errorMessage, contains('disciplina'));
    });
  });
}
