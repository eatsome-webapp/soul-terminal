# Architecture Research: SOUL Terminal v1.1

*Geschreven: 2026-03-20 — Milestone v1.1: Van terminal naar AI coding omgeving*

---

## System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        TermuxApplication                            │
│  onCreate() → preWarmFlutterEngine() → FlutterEngineCache           │
│  FLUTTER_ENGINE_ID = "soul_flutter_engine"                          │
└────────────────────────────┬────────────────────────────────────────┘
                             │ engine lifecycle
┌────────────────────────────▼────────────────────────────────────────┐
│                        TermuxActivity                               │
│                                                                     │
│  TermuxActivityRootView (LinearLayout, vertical)                    │
│  ├── RelativeLayout (terminal container, weight=1)                  │
│  │    └── DrawerLayout                                              │
│  │         ├── TerminalView  ←── renders TerminalSession            │
│  │         └── left_drawer (ListView: session list)                 │
│  ├── FrameLayout flutter_container (weight=1, visibility toggled)   │
│  │    └── FlutterFragment (cached engine)                           │
│  └── View activity_termux_bottom_space_view (IME spacer)            │
│                                                                     │
│  ServiceConnection ←──────────────────────────────┐                │
│  setupPigeonBridges() (called in onServiceConnected)                │
└──────────┬─────────────────────────────────────────┼───────────────┘
           │ bindService                             │
┌──────────▼─────────────────────────────────────────▼───────────────┐
│                         TermuxService (foreground)                  │
│  TermuxShellManager.mTermuxSessions []                              │
│  createTermuxSession() / removeTermuxSession()                      │
│  setTermuxTerminalSessionClient()                                   │
└──────────┬──────────────────────────────────────────────────────────┘
           │ manages
┌──────────▼──────────────────────────────────────────────────────────┐
│                   terminal-emulator module                          │
│  TerminalSession → PTY ↔ shell process                              │
│  TerminalEmulator → TerminalBuffer (scrollback)                     │
│  Callbacks via: TerminalSessionClient                               │
└──────────┬──────────────────────────────────────────────────────────┘
           │ rendered by
┌──────────▼──────────────────────────────────────────────────────────┐
│                   terminal-view module                              │
│  TerminalView (Android View)                                        │
│  onTextChanged() → TermuxTerminalSessionActivityClient              │
│                  → SoulBridgeController.onTerminalTextChanged()     │
└─────────────────────────────────────────────────────────────────────┘

Pigeon Bridge (bidirectioneel, in-process, main thread):

  Flutter (Dart)                     Java (Host)
  ┌──────────────────┐               ┌──────────────────────┐
  │ TerminalBridgeApi│──HostApi ────►│ TerminalBridgeImpl   │
  │ SystemBridgeApi  │──HostApi ────►│ SystemBridgeImpl     │
  │ SoulBridgeApi    │◄──FlutterApi─ │ SoulBridgeController │
  └──────────────────┘               └──────────────────────┘
   (pigeons/terminal_bridge.dart)     (com.termux.bridge.*)
   (pigeons/system_bridge.dart)
```

---

## Component Responsibilities

### Bestaande componenten (v1.0)

| Component | Verantwoordelijkheid | Wijzigingen v1.1 |
|-----------|---------------------|------------------|
| `TermuxApplication` | App init, FlutterEngine pre-warm, FlutterEngineCache | Geen |
| `TermuxActivity` | Host Activity, layout toggle terminal/Flutter, Pigeon setup | **Uitbreiden**: bottom sheet layout, onboarding check |
| `TermuxService` | Foreground service, session lifecycle, PTY management | Geen (bridge gaat via Activity) |
| `TermuxShellManager` | Session lijst beheer | Geen |
| `TermuxTerminalSessionActivityClient` | Callback-bridge session→Activity, `onTextChanged` | **Uitbreiden**: aanroep `SoulBridgeController` |
| `SoulBridgeController` | Debounced output push naar Flutter (max 10/sec) | **Uitbreiden**: active session tracking |
| `TerminalBridgeImpl` | `executeCommand`, `createSession`, `listSessions`, `getTerminalOutput` | **Uitbreiden**: `switchSession(id)` |
| `SystemBridgeImpl` | `getDeviceInfo`, `getPackageInfo` | **Uitbreiden**: `isBootstrapInstalled()`, `runInstallStep()` |
| `FlutterFragment` | Flutter UI container, engine lifecycle | Geen (framework level) |
| `terminal-emulator` | VT/ANSI emulatie, PTY, scrollback buffer | Scrollback naar 20k (config) |
| `terminal-view` | TerminalView render, touch, keyboard | Extra keys voor Claude Code |

### Nieuwe componenten (v1.1)

| Component | Type | Locatie | Verantwoordelijkheid |
|-----------|------|---------|---------------------|
| `BottomSheetTerminalLayout` | Layout refactor | `activity_termux.xml` | CoordinatorLayout wrapper zodat terminal als bottom sheet schuift |
| `SessionTabBar` | Flutter widget | `flutter_module/lib/` | Tab bar bovenin Flutter UI, toont actieve sessies, stuurt via Pigeon |
| `OnboardingFlow` | Flutter screen | `flutter_module/lib/` | Eerste-start wizard: bootstrap check → install → gereed |
| `SoulAwarenessService` | Flutter service | `flutter_module/lib/` | Luistert naar `onTerminalOutput`, geeft context door aan SOUL AI brain |
| `OnboardingBridge` | Pigeon uitbreiding | `pigeons/system_bridge.dart` | `isBootstrapInstalled()`, `runInstallStep(String pkg)`, installatieprogressie |
| `SessionBridge` | Pigeon uitbreiding | `pigeons/terminal_bridge.dart` | `switchSession(int id)`, `renameSession(int id, String name)`, `closeSession(int id)` |

---

## Project Structure

```
soul-terminal/
├── app/
│   └── src/main/
│       ├── java/com/termux/
│       │   ├── app/
│       │   │   ├── TermuxActivity.java          ← wijzigen: bottom sheet setup, onboarding gate
│       │   │   ├── TermuxApplication.java       ← ongewijzigd
│       │   │   ├── TermuxService.java           ← ongewijzigd
│       │   │   └── terminal/
│       │   │       └── TermuxTerminalSessionActivityClient.java  ← uitbreiden: bridge push
│       │   └── bridge/
│       │       ├── SoulBridgeController.java    ← uitbreiden: session tracking
│       │       ├── TerminalBridgeImpl.java      ← uitbreiden: switchSession, renameSession
│       │       ├── SystemBridgeImpl.java        ← uitbreiden: bootstrap check/install
│       │       ├── TerminalBridgeApi.java       ← gegenereerd door Pigeon (niet handmatig)
│       │       └── SystemBridgeApi.java         ← gegenereerd door Pigeon (niet handmatig)
│       └── res/layout/
│           └── activity_termux.xml             ← herschrijven: CoordinatorLayout + BottomSheet
│
├── flutter_module/
│   ├── pigeons/
│   │   ├── terminal_bridge.dart                ← uitbreiden: switch/rename/close session
│   │   └── system_bridge.dart                  ← uitbreiden: bootstrap APIs
│   └── lib/
│       ├── main.dart                           ← herschrijven: onboarding gate + main screen
│       ├── generated/                          ← gegenereerd, niet handmatig
│       ├── screens/
│       │   ├── soul_home_screen.dart           ← NIEUW: hoofd Flutter scherm (SOUL chat)
│       │   └── onboarding/
│       │       ├── onboarding_flow.dart        ← NIEUW: wizard controller
│       │       ├── onboarding_welcome.dart     ← NIEUW: stap 1
│       │       └── onboarding_install.dart     ← NIEUW: stap 2 (bootstrap install)
│       └── widgets/
│           └── session_tab_bar.dart            ← NIEUW: tab bar voor sessies
│
├── terminal-emulator/                          ← upstream, minimaal wijzigen
├── terminal-view/                              ← upstream, minimaal wijzigen
└── termux-shared/                              ← upstream, minimaal wijzigen
```

---

## Architectural Patterns

### 1. Bottom Sheet Terminal (Java/Android kant)

**Patroon:** CoordinatorLayout + BottomSheetBehavior over FlutterFragment als main content.

```xml
<!-- activity_termux.xml — nieuwe structuur -->
<CoordinatorLayout>
    <!-- Hoofd content: Flutter (SOUL UI) -->
    <FrameLayout id="flutter_container"
        layout_height="match_parent" />
    <!-- FlutterFragment wordt hier ingeladen -->

    <!-- Bottom sheet: terminal -->
    <TermuxActivityRootView id="terminal_sheet"
        app:layout_behavior="BottomSheetBehavior"
        app:behavior_peekHeight="48dp"
        app:behavior_hideable="false">
        <DrawerLayout>
            <TerminalView />
        </DrawerLayout>
        <!-- Tab bar handle bovenaan sheet -->
        <TabHandleView id="session_tab_handle" />
    </TermuxActivityRootView>
</CoordinatorLayout>
```

**States:**
- `STATE_COLLAPSED` (peekHeight=48dp) — tab bar zichtbaar, terminal verborgen → Flutter is hoofdscherm
- `STATE_EXPANDED` — terminal fullscreen
- `STATE_HALF_EXPANDED` (50%) — split view

**Implicaties:**
- `TermuxActivityRootView` (huidige custom LinearLayout) moet `CoordinatorLayout.LayoutParams` ondersteunen. Optie: wrapper FrameLayout erbuiten, `TermuxActivityRootView` erin.
- `mIsFlutterVisible` toggle logica verdwijnt — vervangen door `BottomSheetBehavior.setState()`.
- IME handling: `android:windowSoftInputMode="adjustResize"` werkt met CoordinatorLayout.

### 2. FlutterFragment als Hoofdscherm

**Huidig:** FlutterFragment in `flutter_container` (weight=1, naast terminal, zichtbaarheid toggle).

**v1.1:** FlutterFragment vult de volledige CoordinatorLayout op de achtergrond. Terminal is bottom sheet erover.

**Gevolg voor Pigeon setup:** `setupPigeonBridges()` wordt aangeroepen in `onServiceConnected`. Dit blijft ongewijzigd — het moment van setup is correct.

### 3. Output Streaming — Pigeon vs EventChannel

**Huidige aanpak:** `SoulBridgeController` gebruikt Pigeon's gegenereerde `SoulBridgeApi` (FlutterApi) met 100ms debounce. Dit zijn MethodChannel-calls onder de motorkap.

**EventChannel alternatief:** Lower-level, native stream, geen serialisatie overhead, ideaal voor hoge frequentie. Maar: Pigeon ondersteunt streaming via `@EventChannelApi` pas in recente versies, en onze Pigeon-setup werkt al.

**Beslissing voor v1.1:** Behoud Pigeon-debounce (10/sec) voor output streaming — voldoende voor SOUL awareness. Als later real-time typing feedback nodig is (< 50ms), migreer `onTerminalOutput` naar een handmatige `EventChannel` naast de Pigeon MethodChannels.

**Waarom niet nu:** 10 updates/sec geeft SOUL genoeg context. Hogere frequentie heeft geen meerwaarde totdat SOUL realtime mee-typeert.

### 4. Session Tab Bar

**Patroon:** Flutter-side widget bovenaan het terminal sheet handle. Tab bar toont sessies van `listSessions()` en roept `switchSession(id)` aan via Pigeon.

**Data flow:**
1. Java `SoulBridgeController.onSessionChanged()` → Flutter `SoulBridgeApi.onSessionChanged(SessionInfo)` → tab bar herlaadt
2. Flutter tab-tik → `TerminalBridgeApi.switchSession(id)` → Java → `TermuxService.setCurrentStoredSession()`

**Nieuw Pigeon API (toevoegen aan `terminal_bridge.dart`):**
```dart
@HostApi()
abstract class TerminalBridgeApi {
  // bestaand...
  void switchSession(int id);          // NIEUW
  void renameSession(int id, String name);  // NIEUW
  void closeSession(int id);           // NIEUW
}
```

### 5. SOUL Terminal Awareness

**Patroon:** Flutter-side service (geen Android Service) die luistert naar `onTerminalOutput` callbacks en deze doorgeeft aan de SOUL AI logic.

```dart
// Conceptueel — flutter_module/lib/
class SoulAwarenessService implements SoulBridgeApi {
  @override
  void onTerminalOutput(String output) {
    // Buffer laatste N regels
    // Trigger SOUL brain met context als commando eindigt
    // Detecteer foutmeldingen (exit code patterns)
  }

  @override
  void onSessionChanged(SessionInfo info) {
    // Verander context van actieve sessie
  }
}
```

**SOUL command → terminal data flow:**
```
SOUL AI (Dart)
  → TerminalBridgeApi.executeCommand("npm install")   [Pigeon HostApi call]
  → Java: TerminalBridgeImpl.executeCommand()
  → TerminalSession.write("npm install\n")
  → PTY → bash → output
  → TerminalSessionClient.onTextChanged()
  → SoulBridgeController.onTerminalTextChanged() [debounced]
  → SoulBridgeApi.onTerminalOutput(output)        [Pigeon FlutterApi call]
  → Flutter: SoulAwarenessService.onTerminalOutput()
  → SOUL brain verwerkt output
```

### 6. Onboarding Flow

**Patroon:** Flutter-side, meerstaps wizard. Eerste check op Java-kant of bootstrap geïnstalleerd is.

**Nieuwe Pigeon APIs (toevoegen aan `system_bridge.dart`):**
```dart
@HostApi()
abstract class SystemBridgeApi {
  // bestaand...
  bool isBootstrapInstalled();                     // NIEUW
  void runInstallStep(String description);         // NIEUW — async via SoulBridgeApi callback
}

@FlutterApi()
abstract class SoulBridgeApi {
  // bestaand...
  void onInstallProgress(String step, int percent);  // NIEUW
  void onInstallComplete(bool success, String error); // NIEUW
}
```

**Java-kant `SystemBridgeImpl`:**
- `isBootstrapInstalled()` → checkt of `$PREFIX/bin/bash` bestaat
- `runInstallStep()` → delegeert aan `TermuxInstaller` achterlogica, pusht progress via `SoulBridgeController`

**Flutter onboarding flow:**
```
main.dart
  └── check SharedPreferences: "onboarding_done"
       ├── false → OnboardingFlow()
       │    ├── WelcomeStep (statisch)
       │    ├── PermissionsStep (storage, notifications)
       │    ├── BootstrapStep → SystemBridgeApi.isBootstrapInstalled()
       │    │    └── false → "Install development tools" knop
       │    │         → SystemBridgeApi.runInstallStep(...)
       │    │         → SoulBridgeApi.onInstallProgress() updates UI
       │    └── CompleteStep → SharedPreferences.set("onboarding_done", true)
       └── true → SoulHomeScreen()
```

**Constraint:** `TermuxInstaller` draait bootstrap installatie al in `TermuxActivity.onServiceConnected()` als bootstrap mist. De onboarding moet dit onderscheppen of samenwerken: onboarding toont de progress die `TermuxInstaller` al doet.

---

## Data Flow

### A. Normale terminal output naar SOUL

```
bash (PTY)
  → TerminalSession.onProcessExit() / bytes uit PTY
  → TerminalEmulator.processCodePoint()
  → TerminalBuffer update
  → TerminalSessionClient.onTextChanged(session)       ← callback interface
  → TermuxTerminalSessionClientBase.onTextChanged()
  → TermuxTerminalSessionActivityClient.onTextChanged()
  → SoulBridgeController.onTerminalTextChanged(session)
  → [100ms debounce]
  → SoulBridgeApi.onTerminalOutput(last50Lines)         ← Pigeon FlutterApi
  → Flutter: SoulAwarenessService.onTerminalOutput()
  → SOUL brain context update
```

### B. SOUL commando naar terminal

```
Flutter: TerminalBridgeApi.executeCommand("git status")  ← Pigeon HostApi
  → Java: TerminalBridgeImpl.executeCommand()
  → getCurrentTerminalSession()  [last session van TermuxService]
  → TerminalSession.write("git status\n")
  → PTY stdin → bash verwerkt commando
  → output terug via flow A
```

### C. Session tab interactie

```
Gebruiker tikt tab in Flutter UI
  → TerminalBridgeApi.switchSession(2)               ← Pigeon HostApi
  → Java: TerminalBridgeImpl.switchSession(2)
  → TermuxService.getTermuxSessions().get(2)
  → [activity] setCurrentSession(terminalSession)
  → TerminalView.attachSession(terminalSession)
  → SoulBridgeController.onSessionChanged(2, name, true)  ← notify Flutter
  → Flutter tab bar update
```

### D. Bottom sheet drag interactie

```
Gebruiker sleept terminal sheet omhoog
  → BottomSheetBehavior callback: onStateChanged(STATE_EXPANDED)
  → Java: TerminalView.requestFocus()
  → Keyboard popup (als terminal focussed)
  → Normaal terminal gebruik

Gebruiker sleept sheet terug omlaag
  → BottomSheetBehavior: STATE_COLLAPSED
  → Flutter Flutter krijgt focus terug
  → Terminal processen blijven lopen (TermuxService)
```

### E. Onboarding → bootstrap installatie

```
OnboardingFlow: SystemBridgeApi.isBootstrapInstalled()   ← Pigeon
  → Java: SystemBridgeImpl: check $PREFIX/bin/bash
  → false: Flutter toont install stap

Gebruiker drukt "Install"
  → SystemBridgeApi.runInstallStep("bootstrap")          ← Pigeon
  → Java: TermuxInstaller.setupIfNeeded(activity, callback)
  → [progresscallbacks] SoulBridgeApi.onInstallProgress("Extracting...", 45)  ← Pigeon
  → Flutter: progress bar update
  → [klaar] SoulBridgeApi.onInstallComplete(true, "")    ← Pigeon
  → Flutter: markeer onboarding klaar, navigeer naar SoulHomeScreen
```

---

## Anti-Patterns

| Anti-pattern | Reden | Alternatief |
|-------------|-------|------------|
| EventChannel voor terminal output | Overhead van handmatige setup, Pigeon werkt al, 10/sec is genoeg | Pigeon debounce behouden; EventChannel pas als < 50ms latency nodig |
| PlatformView voor TerminalView in Flutter | Sync rendering problemen, touch event conflicts, jank | FlutterFragment naast native terminal (huidig patroon) |
| TermuxService direct binden vanuit Flutter | Flutter/Dart kent Android Service niet, violates layering | Via Pigeon bridge via Activity (huidig patroon) |
| Polling van terminal output vanuit Flutter | CPU waste, race conditions | Push via `SoulBridgeApi.onTerminalOutput` (huidig patroon) |
| RecyclerView voor session list | `androidx.recyclerview` dependency niet aanwezig in project | ListView + BaseAdapter (conform STATE.md constraint) |
| Meerdere FlutterEngines | +40MB per engine, complexe lifecycle | Eén engine in FlutterEngineCache (huidig patroon) |
| Onboarding als Android native UI | Breekt de "Flutter is hoofdscherm" architectuur | Onboarding volledig in Flutter module |
| `android:nonTransitiveRClass=true` | Breekt bestaande cross-module R-class referenties | Behoud `false` (conform STATE.md constraint) |
| Kotlin in `app/` module | Vereist extra Gradle plugin, upstream merge conflicts | Java only voor host-side (conform STATE.md) |

---

## Integration Points

### Nieuw vs. gewijzigd

| Component | Status | Reden |
|-----------|--------|-------|
| `activity_termux.xml` | **Herschrijven** | Root view moet CoordinatorLayout worden |
| `TermuxActivity.java` | **Uitbreiden** | Bottom sheet setup, onboarding gate, remove toggle logic |
| `TerminalBridgeImpl.java` | **Uitbreiden** | `switchSession`, `renameSession`, `closeSession` |
| `SystemBridgeImpl.java` | **Uitbreiden** | `isBootstrapInstalled`, `runInstallStep` |
| `SoulBridgeController.java` | **Uitbreiden** | `onInstallProgress`, `onInstallComplete` push, active session tracking |
| `TermuxTerminalSessionActivityClient.java` | **Uitbreiden** | Bridge call ook als Flutter zichtbaar maar terminal in collapsed state |
| `pigeons/terminal_bridge.dart` | **Uitbreiden** | Nieuwe session management methods |
| `pigeons/system_bridge.dart` | **Uitbreiden** | Bootstrap check/install APIs + install progress callbacks |
| `flutter_module/lib/main.dart` | **Herschrijven** | Onboarding gate, SoulHomeScreen als entry point |
| `SoulHomeScreen` (widget) | **Nieuw** | Hoofd Flutter scherm, host voor SessionTabBar + SOUL chat |
| `SessionTabBar` (widget) | **Nieuw** | Tab bar in bottom sheet handle area |
| `OnboardingFlow` (widgets) | **Nieuw** | Meerstaps wizard |
| `SoulAwarenessService` (Dart class) | **Nieuw** | Terminal output → SOUL brain context |
| `TermuxApplication.java` | Ongewijzigd | Engine pre-warm werkt al |
| `TermuxService.java` | Ongewijzigd | Session management API volledig genoeg |
| `terminal-emulator/` | Minimaal | Scrollback naar 20k via config (geen code) |
| `terminal-view/` | Minimaal | Extra keys CSS voor Claude Code |

### Kritieke koppelpunten

1. **`onServiceConnected` → `setupPigeonBridges()`** — Dit is de enige plek waar engine, service en bridge samenkomen. Alle bridge setup moet hier gebeuren.

2. **`BottomSheetBehavior.BottomSheetCallback`** — Java callback voor state changes. Hier wordt focus management gedaan (terminal focus bij expand, Flutter focus bij collapse).

3. **`TermuxTerminalSessionActivityClient.onTextChanged()`** — Enige plek waar terminal output bridge-calls worden getriggerd. Moet ook werken als terminal in collapsed state is (SOUL awareness werkt op achtergrond).

4. **`TermuxInstaller.setupIfNeeded()`** — Bestaande bootstrap installatie logica. Onboarding moet hier omheen wrappen, niet dupliceren.

---

## Suggested Build Order

### Stap 1: Layout refactor — CoordinatorLayout + BottomSheet
**Afhankelijk van:** niets
**Wijzigt:** `activity_termux.xml`, `TermuxActivity.java`
**Test:** Terminal schuift omhoog als bottom sheet, Flutter zichtbaar op achtergrond, terminal processen blijven lopen
**Risico:** IME handling, `TermuxActivityRootView` custom insets listener — testen na refactor

### Stap 2: Pigeon API uitbreiding — session management + bootstrap
**Afhankelijk van:** stap 1 niet vereist, maar logisch samen
**Wijzigt:** `pigeons/terminal_bridge.dart`, `pigeons/system_bridge.dart`
**Actie:** Pigeon codegen uitvoeren → `TerminalBridgeApi.java`, `SystemBridgeApi.java` worden gegenereerd
**Implementeer:** `TerminalBridgeImpl.switchSession()`, `SystemBridgeImpl.isBootstrapInstalled()`

### Stap 3: Flutter SoulHomeScreen + SessionTabBar
**Afhankelijk van:** stap 2 (Pigeon APIs beschikbaar)
**Wijzigt:** `main.dart`, nieuw `soul_home_screen.dart`, nieuw `session_tab_bar.dart`
**Test:** Tab bar toont sessies, tik wisselt actieve sessie, terminal schuift mee

### Stap 4: Onboarding flow
**Afhankelijk van:** stap 2 (bootstrap APIs), stap 3 (SoulHomeScreen als doel)
**Wijzigt:** `main.dart` (routing), nieuw `onboarding/` screens
**Test:** Eerste start → wizard → bootstrap install → SoulHomeScreen; tweede start → direct SoulHomeScreen

### Stap 5: SOUL terminal awareness
**Afhankelijk van:** stap 3 (SoulHomeScreen host), bestaande `SoulBridgeController`
**Wijzigt:** nieuw `SoulAwarenessService`, `SoulBridgeController.java` uitbreiden
**Test:** Commando uitvoeren → SOUL ontvangt output → kan follow-up commando sturen

### Stap 6: UX polish
**Afhankelijk van:** stap 1-5 werkend
**Wijzigt:** scrollback config, extra keys layout, kleurthema tweaks, landscape support
**Onafhankelijk van Flutter fases** — kan parallel aan stap 3-5

---

## Constraints Reminder

- `android.nonTransitiveRClass=false` — behoud, alle cross-module R-class refs werken zo
- ListView + BaseAdapter — geen RecyclerView dependency
- Java only in `app/` module — geen Kotlin
- Pigeon codegen uitvoeren na elke pigeon-wijziging (CI of lokaal via `flutter pub run pigeon`)
- Bootstrap installatie: `TermuxInstaller.setupIfNeeded()` al aanwezig — wrap, niet dupliceer
- `FlutterEngineCache` key: `"soul_flutter_engine"` (gedefinieerd in `TermuxApplication`)
- `setupPigeonBridges()` wordt aangeroepen in `onServiceConnected` — afhankelijk van zowel engine als service beschikbaar

---

*Bronnen: Flutter docs (add-to-app, FlutterFragment, platform channels), Android developer docs (BottomSheetBehavior, CoordinatorLayout), bestaande codebase analyse*
