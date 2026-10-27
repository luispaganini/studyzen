import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyzen/app.dart';

import '../helpers/test_doubles.dart';

void main() {
  late MockDisciplinaService disciplinaService;
  late MockAvaliacaoService avaliacaoService;
  late FakeNotificationService notifications;

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 2856);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(StudyZenApp(
      disciplinaService: disciplinaService,
      avaliacaoService: avaliacaoService,
      notificationService: notifications,
      alertPlayer: FakeAlertPlayer(),
    ));
    await tester.pumpAndSettle();
  }

  setUp(() {
    disciplinaService = MockDisciplinaService();
    avaliacaoService = MockAvaliacaoService();
    notifications = FakeNotificationService();

    when(() => disciplinaService.listar()).thenAnswer((_) async => []);
    when(() => avaliacaoService.listar()).thenAnswer((_) async => []);
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
}
