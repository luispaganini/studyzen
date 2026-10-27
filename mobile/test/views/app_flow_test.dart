import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyzen/app.dart';

import '../helpers/test_doubles.dart';

void main() {
  late MockDisciplinaService service;
  late FakeNotificationService notifications;

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(StudyZenApp(
      disciplinaService: service,
      notificationService: notifications,
      alertPlayer: FakeAlertPlayer(),
    ));
    await tester.pumpAndSettle();
  }

  setUp(() {
    service = MockDisciplinaService();
    notifications = FakeNotificationService();
  });

  testWidgets('tela de foco mostra 25:00 e inicia/pausa o timer', (tester) async {
    when(() => service.listar()).thenAnswer((_) async => []);
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
    when(() => service.listar()).thenAnswer((_) async => []);
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('preset45')));
    await tester.pumpAndSettle();

    expect(find.text('45:00'), findsOneWidget);
  });

  testWidgets('aba Disciplinas: vazio -> cadastrar -> aparece na listagem', (tester) async {
    when(() => service.listar()).thenAnswer((_) async => []);
    when(() => service.criar(nome: 'Cálculo I', cargaHoraria: 60))
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

  testWidgets('erro ao carregar mostra opção de tentar novamente', (tester) async {
    var calls = 0;
    when(() => service.listar()).thenAnswer((_) async {
      calls++;
      if (calls == 1) throw Exception('Não foi possível conectar ao servidor.');
      return [disciplina(1, 'Redes')];
    });
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('tabDisciplinas')));
    await tester.pumpAndSettle();
    expect(find.text('Algo deu errado'), findsOneWidget);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(find.text('Redes'), findsOneWidget);
  });
}
