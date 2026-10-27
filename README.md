# StudyZen

App de organização acadêmica e foco para estudantes universitários.

| Camada  | Stack                                                       |
|---------|-------------------------------------------------------------|
| Mobile  | Flutter · MVVM (Provider + ChangeNotifier)                  |
| Backend | ASP.NET Core (.NET 10) Web API · EF Core                    |
| Banco   | PostgreSQL 17 (Docker Compose)                              |
| CI      | GitHub Actions (`.github/workflows/ci.yml`)                 |

## Estrutura

```
studyzen/
├── backend/
│   ├── src/StudyZen.Api/          Controllers · Services · Data · Models · Dtos
│   └── tests/StudyZen.Api.Tests/  xUnit (unitários + integração)
├── mobile/
│   ├── lib/
│   │   ├── core/                  tema, config, ViewState
│   │   ├── models/                Model
│   │   ├── services/              acesso a API e notificações
│   │   ├── viewmodels/            ViewModel (ChangeNotifier)
│   │   └── views/                 View (telas + components/)
│   └── test/                      services, viewmodels, widgets
└── docker-compose.yml
```

## Rodando localmente

```bash
docker compose up -d

cd backend
dotnet run --project src/StudyZen.Api --urls http://0.0.0.0:5000

cd mobile
flutter run
```

O app usa `http://10.0.2.2:5000` no emulador Android e `http://localhost:5000` nas demais plataformas.
Para um dispositivo físico: `flutter run --dart-define=API_BASE_URL=http://<ip-da-maquina>:5000`.

## Testes

```bash
cd backend && dotnet test
cd mobile && flutter test
```

## Sprint 1 — Jira (STUD)

| Issue  | Entrega                                                                   |
|--------|---------------------------------------------------------------------------|
| STUD-1 | Infra: solução .NET + EF Core/PostgreSQL, app Flutter, Docker, CI         |
| STUD-5 | US01 Cadastro de Disciplinas — `GET/POST /api/disciplinas` + telas        |
| STUD-9 | US04 Timer Pomodoro — 25 min padrão, sync em background, notificação local |
