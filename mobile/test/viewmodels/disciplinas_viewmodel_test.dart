import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyzen/core/view_state.dart';
import 'package:studyzen/services/disciplina_service.dart';
import 'package:studyzen/viewmodels/disciplina_form_viewmodel.dart';
import 'package:studyzen/viewmodels/disciplinas_viewmodel.dart';

import '../helpers/test_doubles.dart';

void main() {
  late MockDisciplinaService service;

  setUp(() => service = MockDisciplinaService());

  group('DisciplinasViewModel', () {
    test('carregar popula a lista e muda estado para success', () async {
      when(() => service.listar()).thenAnswer((_) async => [disciplina(1, 'Redes', carga: 40)]);
      final vm = DisciplinasViewModel(service);

      await vm.carregar();

      expect(vm.state, ViewState.success);
      expect(vm.disciplinas.single.nome, 'Redes');
      expect(vm.cargaHorariaTotal, 40);
    });

    test('carregar em caso de erro expõe mensagem', () async {
      when(() => service.listar()).thenThrow(const ApiException('offline'));
      final vm = DisciplinasViewModel(service);

      await vm.carregar();

      expect(vm.state, ViewState.error);
      expect(vm.errorMessage, 'offline');
    });

    test('isEmpty quando sucesso sem itens', () async {
      when(() => service.listar()).thenAnswer((_) async => []);
      final vm = DisciplinasViewModel(service);

      await vm.carregar();

      expect(vm.isEmpty, isTrue);
    });

    test('adicionar insere mantendo ordem alfabética', () async {
      when(() => service.listar()).thenAnswer((_) async => [disciplina(1, 'Banco'), disciplina(2, 'Redes')]);
      final vm = DisciplinasViewModel(service);
      await vm.carregar();

      vm.adicionar(disciplina(3, 'Cálculo'));

      expect(vm.disciplinas.map((d) => d.nome), ['Banco', 'Cálculo', 'Redes']);
    });
  });

  group('DisciplinaFormViewModel', () {
    test('validarNome rejeita nulo, vazio e só espaços', () {
      final vm = DisciplinaFormViewModel(service);

      expect(vm.validarNome(null), isNotNull);
      expect(vm.validarNome(''), isNotNull);
      expect(vm.validarNome('   '), isNotNull);
      expect(vm.validarNome('a' * 121), isNotNull);
      expect(vm.validarNome('Cálculo'), isNull);
    });

    test('validarCargaHoraria exige inteiro entre 1 e 1000', () {
      final vm = DisciplinaFormViewModel(service);

      expect(vm.validarCargaHoraria(''), isNotNull);
      expect(vm.validarCargaHoraria('0'), isNotNull);
      expect(vm.validarCargaHoraria('1001'), isNotNull);
      expect(vm.validarCargaHoraria('abc'), isNotNull);
      expect(vm.validarCargaHoraria('60'), isNull);
    });

    test('salvar com dados válidos chama o service com valores normalizados', () async {
      when(() => service.criar(nome: 'Cálculo', cargaHoraria: 60)).thenAnswer((_) async => disciplina(1, 'Cálculo'));
      final vm = DisciplinaFormViewModel(service);

      final criada = await vm.salvar(nome: '  Cálculo ', cargaHoraria: ' 60 ');

      expect(criada?.id, 1);
      expect(vm.isSaving, isFalse);
      verify(() => service.criar(nome: 'Cálculo', cargaHoraria: 60)).called(1);
    });

    test('salvar com dados inválidos não chama o service', () async {
      final vm = DisciplinaFormViewModel(service);

      final criada = await vm.salvar(nome: '', cargaHoraria: '60');

      expect(criada, isNull);
      verifyNever(() => service.criar(nome: any(named: 'nome'), cargaHoraria: any(named: 'cargaHoraria')));
    });

    test('salvar expõe erro do backend', () async {
      when(() => service.criar(nome: any(named: 'nome'), cargaHoraria: any(named: 'cargaHoraria')))
          .thenThrow(const ApiException('Não foi possível conectar ao servidor.'));
      final vm = DisciplinaFormViewModel(service);

      final criada = await vm.salvar(nome: 'Física', cargaHoraria: '40');

      expect(criada, isNull);
      expect(vm.errorMessage, contains('conectar'));
    });
  });
}
