# Phase 6: App Merge - Context

**Gathered:** 2026-03-20
**Status:** Ready for planning

<domain>
## Phase Boundary

De bestaande SOUL Flutter app (melos monorepo: `soul-app/apps/soul/` met 237 Dart files + `soul-app/packages/soul_core/`) samenvoegen met de soul-terminal `flutter_module`. Na merge is de SOUL chat UI operationeel als hoofdscherm in de FlutterFragment. Dit omvat: code kopiëren, pubspec merge (52 deps), AndroidManifest merge, ProviderScope refactoring voor FlutterFragment, database pad unificatie, foreground service coëxistentie, CI/CD validatie, en API key opslag onder com.soul.terminal.

</domain>

<decisions>
## Implementation Decisions

### Monorepo flattening
- Kopieer `soul-app/apps/soul/lib/*` naar `flutter_module/lib/` (core/, models/, services/, ui/ directories + main.dart)
- Merge `soul-app/packages/soul_core/lib/` inline in `flutter_module/lib/core/` — soul_core bevat maar 1 Dart file, aparte package niet nodig
- `objectbox-model.json` en `objectbox.g.dart` meenemen naar flutter_module/lib/
- Assets (`assets/config/default_intervention_config.yaml`) meenemen naar flutter_module/
- Bestaande bridge test code in `main.dart` vervangen door SOUL app root widget
- Pigeon bridges (terminal_bridge, system_bridge) behouden in hun huidige locaties
- Package imports wijzigen van `package:soul_app/` naar `package:flutter_module/`

### ProviderScope refactoring
- SOUL app gebruikt nu `ProviderContainer` in `main()` met overrides (objectBoxStoreProvider, apiKeyNotifierProvider)
- Refactor naar `UncontrolledProviderScope` wrapping de root widget
- `ProviderContainer` wordt aangemaakt tijdens FlutterFragment attachment, niet in `main()`
- ObjectBox store initialisatie verplaatsen naar een async init die vanuit Java/FlutterFragment getriggerd kan worden
- API key laden na store initialisatie, voor widget build

### Database pad strategie
- Fresh paths onder `com.soul.terminal` app directory — geen data migratie van standalone soul-app
- Drift SQLite database: standaard `path_provider` getFilesDir() werkt correct in FlutterFragment context
- ObjectBox store: standaard `objectbox/` subdirectory onder app files dir
- Beide databases schrijven naar `/data/data/com.soul.terminal/files/` — geen pad conflicten met Termux's eigen data

### Foreground service coëxistentie
- SOUL ForegroundService (`flutter_foreground_task`) en TermuxService draaien tegelijk
- Aparte notification channels: SOUL gebruikt eigen channel ID, Termux heeft `com.soul.terminal.service`
- Unieke notification IDs om conflicts te voorkomen
- Boot receiver van SOUL app meenemen in AndroidManifest merge
- `FOREGROUND_SERVICE` en `FOREGROUND_SERVICE_SPECIAL_USE` permissies al aanwezig in SOUL manifest

### pubspec.yaml merge
- 52 SOUL deps toevoegen aan flutter_module pubspec.yaml
- Bestaande `pigeon` dep behouden
- Dart SDK constraint aanpassen naar `^3.11.1` (SOUL app vereiste)
- Dev dependencies meenemen: build_runner, drift_dev, freezed, json_serializable, riverpod_generator, objectbox_generator
- Assets sectie toevoegen voor intervention config
- `module:` sectie behouden (androidPackage: com.soul.terminal.flutter_module)

### AndroidManifest merge
- SOUL permissies toevoegen aan soul-terminal `app/src/main/AndroidManifest.xml`:
  - `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_SPECIAL_USE`, `RECEIVE_BOOT_COMPLETED`
  - `POST_NOTIFICATIONS`, `WAKE_LOCK`, `READ_CONTACTS`, `READ_CALENDAR`
  - `MANAGE_EXTERNAL_STORAGE`
- SOUL services registreren in Termux AndroidManifest:
  - ForegroundService met `specialUse` type
  - NotificationListenerService
- flutter_module's eigen AndroidManifest hoeft niet te wijzigen (Flutter plugin manifests mergen automatisch)

### API key opslag
- API keys opslaan via Android Keystore onder `com.soul.terminal` package context
- `flutter_secure_storage` dependency al in SOUL pubspec — werkt out-of-the-box in FlutterFragment
- ApiKeyService class uit SOUL app ongewijzigd overnemen
- Keys overleven app herstart (Keystore is persistent per package)

### CI/CD aanpassingen
- Flutter SDK versie in GitHub Actions aanpassen naar 3.41.4 (matching proot-distro versie)
- ObjectBox native libs (objectbox_flutter_libs) vereist NDK in CI
- `build_runner` stap toevoegen voor codegen (Drift, Freezed, Riverpod, ObjectBox)
- Bestaande twee-stage build (Flutter → Gradle) behouden maar met meer deps

### KRITIEK: Merge strategie (uit mislukte poging 1)
- **NOOIT bulk copy-paste** — incrementeel mergen, per laag, met compilatie check na elke stap
- **NOOIT .g.dart/.freezed.dart files kopiëren** — altijd `build_runner` draaien om te regenereren
- **`objectbox-model.json` WEL kopiëren** (is het schema), `objectbox.g.dart` NIET (is generated)
- **`dart analyze` is NIET voldoende als bewijs** — de app moet daadwerkelijk STARTEN op een device
- **Incrementele volgorde verplicht:**
  1. pubspec.yaml deps toevoegen → `flutter pub get` → groen
  2. core/di/providers.dart + dependencies → `build_runner` → groen
  3. core/database/ (Drift schema) → `build_runner` → groen
  4. services/ laag voor laag → elke laag compileerbaar
  5. models/ → `build_runner` → groen (Freezed, ObjectBox)
  6. ui/ als laatste → router, screens, widgets
  7. main.dart herschrijven als ALLERLAATSTE stap
  8. **Na elke stap: `build_runner` + CI build check**
- **main.dart MOET de SOUL app init-flow EXACT volgen:**
  1. `WidgetsFlutterBinding.ensureInitialized()`
  2. `openStore()` (ObjectBox)
  3. `ProviderContainer` met `objectBoxStoreProvider.overrideWithValue(store)`
  4. API key laden uit secure storage
  5. OpenClaw client initialiseren
  6. Foreground service starten
  7. `SentryConfig.init()` wrapping
  8. `runApp(UncontrolledProviderScope(container: container, child: SoulApp(...)))`
- **Finale verificatie: APK installeren op device, SOUL chat UI moet zichtbaar zijn als hoofdscherm**

### HARDE GATE: CI build als verificatie
- **Elke plan-stap MOET eindigen met: push naar GitHub → CI build groen**
- Als CI rood is: STOP, fix, opnieuw pushen tot groen. Pas dan door naar volgende stap
- `dart analyze` alleen is GEEN bewijs — alleen een groene CI build telt
- Executor agents MOETEN `~/soul-app/apps/soul/lib/main.dart` en `~/soul-app/apps/soul/lib/core/di/providers.dart` LEZEN (niet raden) voor elke stap die providers of init-flow raakt
- Executor agents MOETEN de bronbestanden in soul-app LEZEN voor ze iets kopiëren of herschrijven — geen aannames op basis van het plan alleen

### Claude's Discretion
- Eventuele tussentijdse compilatie-fixes bij import conflicts
- Melos workspace configuratie (verwijderen of laten staan in soul-app)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### SOUL app broncode (merge source)
- `~/soul-app/apps/soul/pubspec.yaml` — Alle 52 dependencies, assets, SDK constraints
- `~/soul-app/apps/soul/lib/main.dart` — ProviderContainer setup, ObjectBox init, API key loading
- `~/soul-app/apps/soul/lib/core/di/providers.dart` — Riverpod provider definities en overrides
- `~/soul-app/apps/soul/lib/core/router/app_router.dart` — GoRouter configuratie (wordt root widget)
- `~/soul-app/apps/soul/android/app/src/main/AndroidManifest.xml` — Permissies en services om te mergen
- `~/soul-app/packages/soul_core/` — Core shared library (models, drift schema)

### flutter_module (merge target)
- `flutter_module/pubspec.yaml` — Huidige minimal deps, module configuratie
- `flutter_module/lib/main.dart` — Huidige bridge test UI (wordt vervangen)
- `flutter_module/lib/generated/` — Pigeon generated code (behouden)
- `flutter_module/pigeons/` — Pigeon schema definities (behouden)

### Integration points (Phase 3 decisions)
- `app/src/main/java/com/termux/app/TermuxActivity.java` — FlutterFragment host
- `app/src/main/java/com/termux/app/TermuxApplication.java` — FlutterEngine pre-warming
- `app/src/main/java/com/termux/app/TermuxService.java` — Terminal service (Pigeon wraps dit)
- `settings.gradle` — flutter_module include
- `.github/workflows/debug_build.yml` — CI debug build
- `.github/workflows/release_build.yml` — CI release build

### Architectuur
- `.planning/PROJECT.md` — Architectuurbeslissing: Termux + FlutterFragment
- `.planning/phases/03-flutter-integration/03-CONTEXT.md` — Pigeon API surface, FlutterEngine caching, toggle mechanism

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **Pigeon bridges** (terminal_bridge.g.dart, system_bridge.g.dart): Behouden — SOUL chat UI gaat deze gebruiken voor terminal interactie
- **SoulBridgeApi implementatie**: onTerminalOutput/onSessionChanged callbacks — basis voor SOUL awareness
- **SOUL app UI** (237 Dart files): Volledige chat interface, persona management, conversation history — wordt het hoofdscherm
- **ApiKeyService**: Secure storage wrapper voor API keys — ongewijzigd bruikbaar

### Established Patterns
- **flutter_module**: add-to-app module pattern met `module:` sectie in pubspec — moet behouden blijven
- **Pigeon codegen**: Schema in `pigeons/`, generated in `lib/generated/` — nieuwe bridges volgen dit patroon
- **SOUL app**: Riverpod + codegen (@riverpod), GoRouter, Drift + ObjectBox, Logger
- **Java host**: Alle Android code is Java, geen Kotlin migratie

### Integration Points
- **main.dart**: Wordt vervangen door SOUL root widget met UncontrolledProviderScope
- **TermuxActivity**: FlutterFragment toont straks SOUL chat UI i.p.v. bridge test screen
- **CI/CD**: Moet build_runner codegen + ObjectBox native libs + 52 deps kunnen builden
- **app/build.gradle**: Mogelijk extra dependencies voor ObjectBox Android plugin

</code_context>

<specifics>
## Specific Ideas

- SOUL app main.dart toont het initialisatiepatroon: ObjectBox store → ProviderContainer → API key laden → GoRouter. Dit patroon moet bewaard blijven maar verplaatst naar FlutterFragment lifecycle.
- soul_core package is minimaal (1 file) — inline mergen in lib/core/ voorkomt onnodige package boundaries
- `objectbox-model.json` en `objectbox.g.dart` zijn gegenereerde files die in dezelfde directory als de modellen moeten staan
- SOUL app heeft `xterm` als dependency — dit kan conflicteren met de native terminal of kan later nuttig zijn voor terminal rendering in Flutter

</specifics>

<deferred>
## Deferred Ideas

- Data migratie van standalone SOUL app naar soul-terminal — bewuste keuze om niet te doen (geen bestaande gebruikers), maar kan later nodig zijn als mensen beide apps gebruiken
- Melos workspace cleanup in soul-app repo — niet relevant voor soul-terminal
- SOUL app tests migreren — kan in aparte fase of als onderdeel van CI hardening

</deferred>

---

*Phase: 06-app-merge*
*Context gathered: 2026-03-20*
