# Soul Terminal — Handoff Briefing

## Wat is soul-terminal?

Een fork van Termux (de Android terminal emulator) die we ombouwen tot de terminal-laag van SOUL — onze AI co-founder app. Het idee: één APK die zowel een werkende terminal is als een Flutter-based AI interface bevat. De terminal draait native (Java), de AI-kant draait in Flutter via een embedded FlutterFragment.

**Repo:** `eatsome-webapp/soul-terminal` (public fork van termux/termux-app)
**Werkdirectory:** `~/soul-terminal-sync` (NIET `~/soul-terminal` — die is een verouderde subdirectory in het soul-app monorepo, zie "Wat ging er mis" hieronder)

## Wat ging er mis

Er waren TWEE kopieën van soul-terminal:
1. **`eatsome-webapp/soul-terminal`** op GitHub — echte fork van termux-app, 10 Android-fix commits
2. **`~/soul-terminal/`** — subdirectory in het soul-app monorepo (`eatsome-webapp/soul-app`)

GSD agents hebben 58 feature-commits (Flutter integration, Pigeon bridges, Kitty keyboard, OSC9 notifications, command palette) geschreven in de **monorepo subdirectory**. Die code is nooit naar het echte GitHub repo gepusht. De twee repo's hadden ook verschillende upstream-versies — de monorepo gebruikte termux-app v0.118.1, het GitHub repo heeft de nieuwste upstream.

**Vandaag gefixt:**
- Aparte clone gemaakt (`~/soul-terminal-sync`)
- 17 nieuwe bestanden (flutter_module, bridge classes) direct gekopieerd
- 16 bestaande bestanden handmatig geport (features toegevoegd aan nieuwere upstream code)
- Flutter inclusie conditioneel gemaakt in settings.gradle en build.gradle

## Huidige staat (19 maart 2026)

### Wat WERKT
- Terminal zelf: bash prompt, tabs, extra keys
- Package name: `com.soul.terminal` (installeert naast echte Termux)
- CI/CD: GitHub Actions bouwt bij elke push
- Android 14 fixes: foregroundServiceType, PendingIntent flags, receiver exports
- Bootstrap: officiële Termux bootstrap met post-extractie path fixup voor text files

### Wat NIET werkt
- **Build faalt met 80 compile errors** — Flutter imports in TermuxActivity, TermuxApplication, en bridge classes compileren niet omdat Flutter SDK niet beschikbaar is als dependency. De `implementation project(':flutter')` is conditioneel, maar de Java imports zijn dat niet.
- **pkg install** — alle apt mirrors falen. ELF binaries hebben hardcoded paden naar `/data/data/com.termux/files/usr/` i.p.v. `/data/data/com.soul.terminal/files/usr/`. Enige fix: custom bootstrap bouwen (zie todos).
- **targetSdkVersion = 28** — nodig voor exec() vanuit app data dir (SELinux), maar blokkeert Play Store (eist 34+)
- **Twee shell-start errors** (niet-blokkerend):
  - `dpkg: error opening configuration directory '/data/data/com.termux/files/usr/etc/dpkg/dpkg.cfg.d': Permission denied`
  - `bash: /data/data/com.termux/files/usr/etc/profile: Permission denied`

## Directe volgende stap: FIX DE BUILD

De build faalt omdat Java files Flutter classes importeren die niet bestaan zonder Flutter module. Er zijn twee opties:

### Optie A: Guard met `try/catch` + reflection (snel, dirty)
Wrap alle Flutter-calls in runtime checks. Nadeel: lelijke code, error-prone.

### Optie B: Feature flag via BuildConfig (schoner)
1. Voeg `buildConfigField "boolean", "FLUTTER_ENABLED", "false"` toe aan `app/build.gradle`
2. Verplaats alle Flutter-specifieke code naar een apart source set of guard met `if (BuildConfig.FLUTTER_ENABLED)`
3. De Flutter imports moeten dan achter een compile-time flag — maar Java heeft geen conditional compilation

### Optie C: Aparte source files (schoonst)
1. Maak een `FlutterIntegration.java` helper class die alle Flutter-calls bevat
2. Maak een `NoOpFlutterIntegration.java` stub die niks doet
3. Selecteer via build flavor of Gradle conditie welke meekomt
4. TermuxActivity/Application roepen alleen de interface aan

**Aanbeveling:** Optie C. Het is iets meer werk maar voorkomt een web van if-statements door de hele codebase.

## Concrete errors die gefixt moeten worden

```
TermuxActivity.java:80      — import io.flutter.embedding.engine.FlutterEngine
TermuxActivity.java:81      — import io.flutter.embedding.engine.FlutterEngineCache
TermuxApplication.java:8-10 — Flutter engine imports + DartExecutor
SoulBridgeController.java:12 — import io.flutter.plugin.common.BinaryMessenger
+ 76 meer gerelateerde errors
```

Alle errors zijn Flutter-import gerelateerd. Geen andere compile issues.

## Todos (in .planning/todos/pending/)

| Prioriteit | Todo | Impact |
|-----------|------|--------|
| **P0** | Fix build (Flutter imports) | Alles blokkeert hierop |
| **P1** | Custom bootstrap (`com.soul.terminal` prefix) | pkg install broken, dpkg/bash errors |
| **P2** | targetSdk 34+ migration | Play Store publicatie |
| **P3** | Process recovery (niet alleen foreground service) | Achtergrond-stabiliteit |
| **P3** | WorkManager + foreground task hybrid | Batterij vs overleving |
| **P3** | Foreground notification UX | Niet lelijk Termux-style |

## Repo & build info

```bash
# Werkdirectory
cd ~/soul-terminal-sync

# Remote
git remote -v
# origin https://github.com/eatsome-webapp/soul-terminal.git

# Branch: master (niet main!)
git branch
# * master

# Build triggeren
git push origin master
# GitHub Actions bouwt automatisch

# Build status checken
gh run list --repo eatsome-webapp/soul-terminal --limit 5

# APK downloaden (na succesvolle build)
gh run download <run-id> --repo eatsome-webapp/soul-terminal

# Installeren
adb install -r <apk-file>
```

## Architectuur samenvatting

```
soul-terminal (Java/Android)
├── app/                          # Hoofd-app module
│   └── src/main/java/com/termux/
│       ├── app/
│       │   ├── TermuxActivity.java      ← Flutter toggle, command palette
│       │   ├── TermuxApplication.java   ← Flutter engine pre-warm
│       │   └── terminal/
│       │       ├── CommandPaletteAdapter.java  (NEW)
│       │       ├── TermuxTerminalSessionActivityClient.java  ← OSC9 notifications
│       │       └── TermuxTerminalViewClient.java  ← Kitty keyboard, Ctrl+Shift+P
│       └── bridge/                      (NEW - hele package)
│           ├── SoulBridgeController.java
│           ├── SystemBridgeApi.java      ← Pigeon generated
│           ├── SystemBridgeImpl.java
│           ├── TerminalBridgeApi.java    ← Pigeon generated
│           └── TerminalBridgeImpl.java
├── flutter_module/               (NEW - hele directory)
│   ├── lib/main.dart             # Test UI
│   ├── pigeons/                  # Pigeon schema's
│   └── lib/generated/            # Pigeon gegenereerde code
├── terminal-emulator/            # Terminal engine
│   └── ...KeyHandler.java        ← Kitty CSI u encoding
│   └── ...TerminalEmulator.java  ← Kitty mode + OSC9 handling
├── terminal-view/
│   └── ...TerminalView.java      ← Kitty key routing
└── termux-shared/
    └── ...TermuxConstants.java   ← OSC9 notification constants
```

## Niet vergeten

- **`~/soul-terminal`** (in monorepo) is VEROUDERD — gebruik `~/soul-terminal-sync`
- De monorepo `~/soul-terminal/` subdir moet later opgeruimd worden
- soul-terminal GitHub repo branch = `master`, NIET `main`
- Nooit lokaal bouwen — altijd GitHub Actions
- Bij nieuwe bootstrap: force-stop + clear app data nodig na install
- ADB wireless debugging adres verandert vaak — opnieuw opvragen als het niet werkt
