import 'package:flutter_test/flutter_test.dart';
import 'package:studyzen/viewmodels/pomodoro_viewmodel.dart';

import '../helpers/test_doubles.dart';

void main() {
  late FakeClock clock;
  late FakeNotificationService notifications;
  late FakeAlertPlayer alert;
  late PomodoroViewModel vm;

  setUp(() {
    clock = FakeClock();
    notifications = FakeNotificationService();
    alert = FakeAlertPlayer();
    vm = PomodoroViewModel(
      notifications: notifications,
      alert: alert,
      now: clock.call,
      tickInterval: const Duration(days: 1),
    );
  });

  tearDown(() => vm.dispose());

  test('inicia com padrão de 25 minutos', () {
    expect(vm.minutes, 25);
    expect(vm.formattedRemaining, '25:00');
    expect(vm.status, PomodoroStatus.idle);
  });

  test('start agenda notificação local para o fim da sessão', () async {
    await vm.start();

    expect(vm.status, PomodoroStatus.running);
    expect(notifications.permissionRequests, 1);
    expect(notifications.scheduled.single, clock.current.add(const Duration(minutes: 25)));
  });

  test('tempo continua sincronizado após voltar do background', () async {
    await vm.start();

    clock.advance(const Duration(minutes: 10, seconds: 30));
    vm.sync();

    expect(vm.formattedRemaining, '14:30');
    expect(vm.progress, closeTo(0.42, 0.001));
  });

  test('ao zerar, dispara alerta sonoro e marca como concluído', () async {
    await vm.start();

    clock.advance(const Duration(minutes: 26));
    vm.sync();

    expect(vm.status, PomodoroStatus.finished);
    expect(vm.formattedRemaining, '00:00');
    expect(alert.plays, 1);
  });

  test('pause congela o tempo e cancela notificação; retomar reagenda com o restante', () async {
    await vm.start();
    clock.advance(const Duration(minutes: 5));
    await vm.pause();

    clock.advance(const Duration(minutes: 30));
    vm.sync();
    expect(vm.status, PomodoroStatus.paused);
    expect(vm.formattedRemaining, '20:00');
    expect(notifications.cancelled, contains(PomodoroViewModel.notificationId));

    await vm.start();
    expect(notifications.scheduled.last, clock.current.add(const Duration(minutes: 20)));
  });

  test('reset volta ao estado inicial e cancela notificação', () async {
    await vm.start();
    clock.advance(const Duration(minutes: 3));

    await vm.reset();

    expect(vm.status, PomodoroStatus.idle);
    expect(vm.formattedRemaining, '25:00');
    expect(notifications.cancelled, isNotEmpty);
  });

  test('setMinutes é configurável e respeita limites', () {
    vm.setMinutes(45);
    expect(vm.formattedRemaining, '45:00');

    vm.setMinutes(0);
    expect(vm.minutes, PomodoroViewModel.minMinutes);

    vm.setMinutes(500);
    expect(vm.minutes, PomodoroViewModel.maxMinutes);
  });

  test('setMinutes é ignorado durante a sessão', () async {
    await vm.start();

    vm.setMinutes(10);

    expect(vm.minutes, 25);
  });
}
