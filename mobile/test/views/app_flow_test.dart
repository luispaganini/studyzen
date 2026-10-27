import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyzen/app.dart';

import '../helpers/test_doubles.dart';

void main() {
  late MockDisciplinaService disciplinaService;
  late MockAvaliacaoService avaliacaoService;
  late MockHumorService humorService;
  late FakeNotificationService notifications;

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 2856);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(StudyZenApp(
      disciplinaService: disciplinaService,
      avaliacaoService: avaliacaoService,
      humorService: humorService,
      notificationService: notifications,
      alertPlayer: FakeAlertPlayer(),
    ));
    await tester.pumpAndSettle();
  }

  setUp(() {
    disciplinaService = MockDisciplinaService();
    avaliacaoService = MockAvaliacaoService();
    humorService = MockHumorService();
    notifications = FakeNotificationService();

    when(() => disciplinaService.listar()).thenAnswer((_) async => []);
    when(() => avaliacaoService.listar()).thenAnswer((_) async => []);
    when(() => humorService.listar()).thenAnswer((_) async => []);
  });

  testWidgets('tela de foco mostra 25:00 e inicia/pausa o timer', (tester) async {
    await pumpApp(tester);

    expect(find.text('25:00'), findsOneWidget);
    await tester.tap(find.text('Iniciar foco'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('FOCANDO'), findsOneWidget);
    expect(notifications.scheduled, hasLength(1));

    await tester.tap(find.text('Pausar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('PAUSADO'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pomodoroReset')));
    await tester.pumpAndSettle();
  });

  testWidgets('presets alteram a duração', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('preset45')));
    await tester.pumpAndSettle();

    expect(find.text('45:00'), findsOneWidget);
  });

  testWidgets('aba Disciplinas: vazio -> cadastrar -> aparece na listagem', (tester) async {
    when(() => disciplinaService.criar(nome: 'Cálculo I', cargaHoraria: 60))
        .thenAnswer((_) async => disciplina(1, 'Cálculo I'));
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('tabDisciplinas')));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma disciplina ainda'), findsOneWidget);

    await tester.tap(find.byKey(const Key('novaDisciplinaButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('salvarButton')));
    await tester.pumpAndSettle();
    expect(find.text('Informe o nome da disciplina'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('nomeField')), 'Cálculo I');
    await tester.enterText(find.byKey(const Key('cargaField')), '60');
    await tester.tap(find.byKey(const Key('salvarButton')));
    await tester.pumpAndSettle();

    expect(find.text('Cálculo I'), findsWidgets);
    expect(find.text('60h de carga horária'), findsOneWidget);
  });

  testWidgets('US07: Checagem rápida de humor com 1 toque', (tester) async {
    when(() => humorService.registrar(
          nivel: any(named: 'nivel'),
          emoji: any(named: 'emoji'),
          sentimento: any(named: 'sentimento'),
        )).thenAnswer((_) async => humor(1, 4, emoji: '🙂', sentimento: 'Produtivo'));

    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('tabPrazos')));
    await tester.pumpAndSettle();

    expect(find.text('Como foi seu foco hoje?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('humorEmoji-4')));
    await tester.pumpAndSettle();

    verify(() => humorService.registrar(nivel: 4, emoji: '🙂', sentimento: 'Produtivo')).called(1);
    expect(find.textContaining('registrado com sucesso'), findsOneWidget);
  });

  testWidgets('US02 & US03: Cadastro de avaliação com DatePicker e Decomposição Inteligente', (tester) async {
    when(() => disciplinaService.listar()).thenAnswer((_) async => [disciplina(1, 'Engenharia de Software')]);
    when(() => avaliacaoService.obterDecomposicao('Trabalho de Conclusão'))
        .thenAnswer((_) async => ['Pesquisa', 'Rascunho', 'Revisão']);
    when(() => avaliacaoService.criar(
          disciplinaId: any(named: 'disciplinaId'),
          titulo: any(named: 'titulo'),
          tipo: any(named: 'tipo'),
          dataEntrega: any(named: 'dataEntrega'),
          subtarefas: any(named: 'subtarefas'),
        )).thenAnswer((_) async => avaliacao(1, 'TCC Final', discNome: 'Engenharia de Software'));

    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('tabPrazos')));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum prazo pendente'), findsOneWidget);

    await tester.tap(find.byKey(const Key('novoPrazoButton')));
    await tester.pumpAndSettle();

    // Testa Decomposição Inteligente (US03)
    await tester.tap(find.byKey(const Key('decomporButton')));
    await tester.pumpAndSettle();
    expect(find.text('Pesquisa'), findsOneWidget);
    expect(find.text('Rascunho'), findsOneWidget);
    expect(find.text('Revisão'), findsOneWidget);

    // Preenche título e seleciona disciplina
    await tester.enterText(find.byKey(const Key('tituloField')), 'TCC Final');
    await tester.tap(find.byKey(const Key('disciplinaDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Engenharia de Software').last);
    await tester.pumpAndSettle();

    // Seleciona data com DatePicker (US02)
    await tester.tap(find.byKey(const Key('dataPickerButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Salva o prazo
    await tester.tap(find.byKey(const Key('salvarAvaliacaoButton')));
    await tester.pumpAndSettle();

    expect(find.text('TCC Final'), findsOneWidget);
    expect(find.text('Engenharia de Software'), findsOneWidget);
    expect(find.text('Etapas decompostas:'), findsOneWidget);
  });
}
