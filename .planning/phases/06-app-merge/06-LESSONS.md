# Phase 6: App Merge — Lessons Learned (Poging 1)

**Datum:** 2026-03-21
**Status:** Execution gefaald — revert nodig

## Wat er mis ging

### 1. Agents doen oppervlakkig werk
- Bulk `cp -r` van 237 files zonder te begrijpen wat ze doen
- `dart analyze` als "bewijs" — vangt geen runtime crashes
- Geen enkele runtime test (flutter run / APK installatie)
- Generated `.g.dart` files gekopieerd i.p.v. geregenereerd → broken code

### 2. Plans waren te grof
- "Kopieer alle Dart files" is geen plan, het is een wish
- Geen incrementele verificatie tussendoor
- Acceptance criteria waren grep-based, niet runtime-based
- Geen rekening gehouden met de SOUL app init-flow complexiteit

### 3. main.dart herschreven zonder begrip
- Agent herschreef main.dart op basis van het PLAN, niet op basis van de werkende SOUL app
- ProviderContainer, ObjectBox init, API key loading, OpenClaw, Sentry, foreground service — alles moet in exact de juiste volgorde
- Resultaat: blanco scherm (crash bij init)

## Wat anders moet (Poging 2)

### Incrementele merge strategie
1. **Start met werkende flutter_module** (huidige bridge test UI)
2. **Voeg eerst pubspec deps toe** → `flutter pub get` → groen
3. **Kopieer core/di/providers.dart** en dependencies → `build_runner` → groen
4. **Kopieer core/database/** → `build_runner` → groen (Drift schema)
5. **Kopieer services/** laag voor laag → elke laag compileerbaar
6. **Kopieer models/** → `build_runner` → groen (Freezed, ObjectBox)
7. **Kopieer ui/** als laatste → router, screens, widgets
8. **Herschrijf main.dart** als allerlaatste stap, gebaseerd op werkende SOUL app main.dart
9. **Na elke stap: `dart analyze` + `build_runner` + compilatie check**

### Geen generated files kopiëren
- NOOIT `.g.dart`, `.freezed.dart`, `objectbox.g.dart` kopiëren
- Altijd `dart run build_runner build --delete-conflicting-outputs` na elke stap
- `objectbox-model.json` WEL kopiëren (is het schema, niet generated code)

### Runtime verificatie verplicht
- Elke plan moet eindigen met: "APK bouwt succesvol in CI"
- Finale plan: "APK installeert en SOUL chat UI is zichtbaar"
- Geen plan is "klaar" tot het op het device werkt

### main.dart moet exact de SOUL app init-flow volgen
De SOUL app init volgorde (uit ~/soul-app/apps/soul/lib/main.dart):
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `openStore()` (ObjectBox)
3. `ProviderContainer` met `objectBoxStoreProvider.overrideWithValue(store)`
4. API key laden uit secure storage
5. OpenClaw client initialiseren
6. Foreground service starten
7. `SentryConfig.init()` wrapping
8. `runApp(UncontrolledProviderScope(container: container, child: SoulApp(...)))`

In FlutterFragment context: zelfde flow, maar in een widget initState of FutureBuilder.

### Import refactoring is niet "waarschijnlijk nul"
- De research zei "SOUL gebruikt relative imports" — dit moet GEVERIFIEERD worden
- `package:soul_app/` imports moeten naar `package:flutter_module/`
- soul_core imports moeten geresolved worden

## Impact op plans

De huidige 5 plans moeten herschreven worden met:
- Kleinere, incrementele taken
- build_runner na elke codegen-relevante stap
- Runtime verificatie (niet alleen static analysis)
- Exacte volgorde van init-flow behouden
- CI build als gate per plan (niet alleen plan 5)

## SOUL app structuur (referentie voor volgende poging)

```
~/soul-app/apps/soul/lib/
├── main.dart          # Init flow — de "source of truth"
├── core/
│   ├── di/providers.dart    # Alle Riverpod providers
│   ├── router/app_router.dart  # GoRouter config
│   ├── theme/soul_theme.dart   # Material theme
│   └── sentry_config.dart
├── models/            # Data models (@freezed, ObjectBox entities)
├── services/          # Business logic (auth, database, vessels, etc.)
└── ui/                # Screens en widgets
    ├── chat/          # Chat UI (het hoofdscherm)
    ├── personas/      # Persona management
    ├── settings/      # Settings screens
    └── ...

52 dependencies — key ones:
- flutter_riverpod + riverpod_annotation (state management)
- drift + sqlite3_flutter_libs (SQL database)
- objectbox + objectbox_flutter_libs (NoSQL database)
- anthropic_sdk_dart (Claude API)
- go_router (navigation)
- flutter_secure_storage (API keys)
- flutter_foreground_task (background service)
- sentry_flutter (error tracking)
```
