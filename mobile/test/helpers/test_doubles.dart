import 'package:mocktail/mocktail.dart';
import 'package:studyzen/models/disciplina.dart';
import 'package:studyzen/services/disciplina_service.dart';
import 'package:studyzen/services/notification_service.dart';

class MockDisciplinaService extends Mock implements DisciplinaService {}

class FakeNotificationService implements NotificationService {
  final List<DateTime> scheduled = [];
  final List<int> cancelled = [];
  int permissionRequests = 0;

  @override
  Future<void> init() async {}

  @override
  Future<void> ensurePermissions() async => permissionRequests++;

  @override
  Future<void> scheduleAt({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  }) async =>
      scheduled.add(at);

  @override
  Future<void> cancel(int id) async => cancelled.add(id);
}

class FakeAlertPlayer implements AlertPlayer {
  int plays = 0;

  @override
  Future<void> play() async => plays++;
}

class FakeClock {
  DateTime current = DateTime.utc(2026, 10, 12, 9);

  DateTime call() => current;

  void advance(Duration d) => current = current.add(d);
}

Disciplina disciplina(int id, String nome, {int carga = 60}) =>
    Disciplina(id: id, nome: nome, cargaHoraria: carga, criadoEm: DateTime.utc(2026, 10, 12));
