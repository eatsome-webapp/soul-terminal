# Project Research Summary

**Project:** SOUL Terminal
**Domain:** Android terminal emulator with embedded Flutter AI interface
**Researched:** 2026-03-20
**Confidence:** HIGH

## Executive Summary

SOUL Terminal is een fork van Termux (Java/Android) die uitgebreid wordt met een embedded Flutter module als primaire AI-interface. De architectuur keert het gebruikelijke terminal-app patroon om: Flutter (SOUL AI brain) is het hoofdscherm, de terminal schuift omhoog als een persistent bottom sheet. De twee lagen communiceren via een type-safe Pigeon bridge; de terminal rendering blijft volledig native (geen PlatformView).

De v1.0 fundering is gelegd: FlutterFragment embedding, Pigeon bridge, CI/CD pipeline, Kitty keyboard protocol en OSC9 notificaties zijn gebouwd. V1.1 bouwt hier direct op voort met vijf kerndoelen: bottom sheet terminal layout, session tab bar, onboarding wizard, SOUL terminal awareness (AI stuurt terminal aan), en UX polish. De Pigeon bridge wordt uitgebreid maar het fundamentele patroon wijzigt niet.

De technische risico's zijn concreet en beheersbaar: touch event conflicts tussen BottomSheetBehavior en TerminalView, IME-handling in CoordinatorLayout, Pigeon thread-safety bij hoge output volumes, en HyperOS-specifiek foreground service management zijn de kritieke pitfalls. Elk heeft een gedocumenteerde oplossing. Security verdient aandacht vóór het AI-naar-terminal pad live gaat: command injection whitelist en API key isolation zijn niet-onderhandelbaar.

## Key Findings

### Recommended Stack

**Build system (geen wijzigingen):** AGP 8.13.2 + Gradle 9.2.1 zijn correct. AGP 9.x is nog te pril voor Flutter add-to-app. targetSdk moet naar 34 (Play Store vereist dit). minSdk naar 24 vereenvoudigt desugaring. `desugar_jdk_libs` upgraden van 1.1.5 naar 2.1.3.

**Flutter embedding:** FlutterFragment (add-to-app), engine pre-warmed in `TermuxApplication.onCreate()`, gecached via `FlutterEngineCache`. Pigeon 26.2.x voor de type-safe bridge. Één engine — nooit meerdere (+40MB per extra engine).

**V1.1 toevoegingen (minimaal):** `ViewPager2:1.1.0` (vervangt deprecated ViewPager v1), `datastore-preferences:1.1.5` voor API key opslag via Android Keystore AES-GCM (EncryptedSharedPreferences is deprecated). `BottomSheetBehavior`, `CoordinatorLayout`, `EventChannel` en `RenderEffect` (API 31+) zitten al in bestaande dependencies — geen nieuwe libs nodig.

**Bewust niet gebruiken:** AGP 9.x, Kotlin in `app/`, Jetpack Compose in de host app, FlutterActivity, PlatformView voor terminal rendering, manual MethodChannel (Pigeon doet dit), EncryptedSharedPreferences, AccessibilityService (Play Store ban jan 2026).

### Expected Features

**Table stakes (inherited gratis):** ~13 Termux-features inclusief bash/zsh, package manager, meerdere sessies, persistent sessions via foreground service, clipboard, extra keys, true color, unicode, SSH.

**V1.0 gebouwd:** SOUL branding, FlutterFragment embedding, Pigeon bridge (terminal control + session info + output streaming), Kitty keyboard protocol, OSC9 notificaties, command palette, CI/CD.

**V1.1 — Tier 1 differentiators (must ship):**

| Feature | Complexiteit | Onderscheidend van |
|---------|-------------|-------------------|
| Bottom sheet terminal | Medium | Alle Android terminals: terminal is de UI, niet een paneel |
| SOUL terminal awareness (AI stuurt terminal aan) | Medium-Hoog | Termux/Termius/JuiceSSH: geen AI integratie |
| Session tab bar | Laag | Termux: onvindbare swipe-drawer |
| Onboarding flow (guided setup) | Medium | Termux: geen onboarding |

**V1.1 — Tier 2 UX polish:** Smart path detection, native permission dialogs, scrollback 20k regels (was 2000), Claude Code extra keys profiel.

**Tier 3 (na v1.1):** Autonome AI command loop, AI error explanation, semantic command history.

**Bewust NIET bouwen:** Warp-stijl terminal Blocks (jaren werk, upstream incompatibel), split panes (touch event chaos, tmux dekt dit), cloud sync, inline image rendering, eigen terminal emulator, iOS versie.

### Architecture Approach

De host Activity (`TermuxActivity`) krijgt een nieuwe root layout: `CoordinatorLayout` met `FlutterFragment` als fullscreen achtergrond en de terminal als `BottomSheetBehavior` child. Drie states: collapsed (peek 48dp, alleen tab handle zichtbaar), half-expanded (50%, split view), expanded (fullscreen terminal).

De Pigeon bridge blijft het centrale communicatiekanaal. Uitbreidingen voor v1.1: `switchSession()`, `renameSession()`, `closeSession()` in de terminal bridge; `isBootstrapInstalled()`, `runInstallStep()`, install progress callbacks in de system bridge. Alle Pigeon calls vanuit Java naar Flutter moeten via de main thread (`Handler(Looper.getMainLooper()).post{}`).

Terminal output naar SOUL: 100ms debounce buffer in `SoulBridgeController` — voldoende voor AI context, geen EventChannel migratie nodig totdat realtime typing feedback (<50ms) vereist is.

Nieuwe Flutter-side componenten: `SoulHomeScreen` (hoofd scherm), `SessionTabBar` (widget in sheet handle), `OnboardingFlow` (meerstaps wizard), `SoulAwarenessService` (Dart class, luistert naar `onTerminalOutput`).

**Bouwvolgorde:**
1. CoordinatorLayout + BottomSheetBehavior layout refactor
2. Pigeon API uitbreiding + codegen
3. Flutter SoulHomeScreen + SessionTabBar
4. Onboarding flow
5. SOUL terminal awareness
6. UX polish (parallel aan stappen 3-5)

### Critical Pitfalls

**CP-1 — IME + BottomSheet conflict:** Het toetsenbord duwt het sheet omhoog via CoordinatorLayout insets. Oplossing: `windowSoftInputMode="adjustPan"` + handmatige inset-verwerking via `ViewCompat.setOnApplyWindowInsetsListener`.

**CP-2 — Touch interception (blokkerende pitfall):** `BottomSheetBehavior` pikt verticale swipes in de terminal weg. `TerminalView` implementeert geen `NestedScrollingChild3`. Oplossing: dedicated `BottomSheetDragHandleView` zodat alleen de handle het sheet expandeert; `NestedScrollingChild3` implementatie in TerminalView.

**CP-3 — HyperOS doodt TermuxService (doeldevice!):** Xiaomi HyperOS negeert `android:stopWithTask="false"` en `START_STICKY`. Oplossing: detecteer Xiaomi bij onboarding, toon gerichte instructies (Settings → Battery → No restrictions + Autostart), `PowerManager.PARTIAL_WAKE_LOCK` als backup.

**CP-4 — Pigeon main thread crash:** `TerminalSession` output-callbacks komen van de PTY reader thread; Pigeon verwacht main thread calls. Crasht pas bij hoog output volume (niet zichtbaar in development). Oplossing: `Handler(Looper.getMainLooper()).post{}` wrapper + 16ms debounce buffer.

**CP-5 — Prompt-detectie faalt bij custom PS1 en zsh/fish:** `$ ` regex werkt niet met ANSI kleurcodes, multi-line prompts of starship. Oplossing: OSC 133 shell integration (`\033]133;D\007` = commando klaar), toevoegen via onboarding `.bashrc`/`.zshrc` configuratie.

**SM-1 — Command injection (security, EERST implementeren):** LLM-output direct als terminal input kan shell injection bevatten. Oplossing: gestructureerde command API (`runCommand(executable, args[])`), whitelist van destructieve patronen, bevestigingsdialoog voor `rm -rf`, `dd`, `mkfs` e.d.

## Implications for Roadmap

### Phase ordering rationale

**Stap 1 als eerste** (CoordinatorLayout layout refactor) heeft geen dependencies maar is de fundering van alles — de bottom sheet is de visuele architectuur van v1.1. Zonder dit kan niets worden getest.

**Pigeon API uitbreiding direct daarna** omdat zowel session tabs als onboarding als SOUL awareness nieuwe Pigeon APIs nodig hebben. Codegen eenmalig uitvoeren, alle implementaties wachten hierop.

**Security (SM-1) vóór SOUL terminal awareness live gaat** — de command injection whitelist moet er zijn voordat de AI-naar-terminal data flow in productie komt. Dit is geen optie.

**CP-3 (HyperOS) in de onboarding verwerken** — het testapparaat is een Xiaomi 17 Ultra. Zonder de battery-permissie instructies werken achtergrond-sessies op het primaire testdevice niet, wat elke andere test onbetrouwbaar maakt.

**UX polish (scrollback 20k, extra keys) parallel uitvoerbaar** aan de Flutter fases — deze raken alleen de terminal-emulator configuratie, geen Flutter of Pigeon code.

### Research Flags

| Gebied | Dieper onderzoek nodig? | Reden |
|--------|------------------------|-------|
| Bottom sheet + IME | Nee — patroon gedocumenteerd | `adjustPan` + inset listener is bewezen aanpak |
| NestedScrollingChild3 in TerminalView | Ja — implementatie-details onbekend | TerminalView is custom View, geen standaard scroll view |
| OSC 133 parsing in Java | Nee — protocol is eenvoudig | Byte-sequence herkenning, geen externe library nodig |
| Flutter insets in CoordinatorLayout (CP-7) | Ja — edge cases onbekend | FlutterView inset-doorgifte in geneste hierarchy niet gedocumenteerd |
| TermuxInstaller second stage wrapping | Ja — interne API onbekend | Onboarding moet `setupIfNeeded()` onderscheppen zonder duplicatie |
| HyperOS autostart API | Nee — documentatie beschikbaar | `dontkillmyapp.com/xiaomi` is voldoende referentie |

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Build system (AGP, Gradle, SDK versions) | HIGH | Geverifieerd tegen official release notes |
| Flutter embedding pattern (FlutterFragment + Pigeon) | HIGH | Official docs, v1.0 al werkend |
| BottomSheetBehavior layout | HIGH | Android Material docs, patroon bewezen in Maps/Music apps |
| Touch event conflict resolution | MEDIUM | NestedScrollingChild3 implementatie vereist praktijktest |
| Flutter insets in CoordinatorLayout (CP-7) | MEDIUM | Specifieke edge case, workarounds gedocumenteerd maar niet geverifieerd |
| Pigeon thread safety (CP-4) | HIGH | Root cause duidelijk, oplossing standaard Java pattern |
| HyperOS service survival (CP-3) | HIGH | Bekend Xiaomi-probleem, oplossing gedocumenteerd |
| OSC 133 prompt detection (CP-5) | HIGH | Protocol open standaard, Fish/Zsh/Bash supporten het |
| SOUL terminal awareness (end-to-end) | MEDIUM | Data flow duidelijk, ANSI stripping + context windowing vereist praktijkimplementatie |
| Onboarding bootstrap wrapping | MEDIUM | TermuxInstaller interne API moet worden geïnspecteerd |
| CI/CD pipeline (Flutter AAR + Gradle) | HIGH | Bestaand patroon, geen nieuwe risico's |
| Security (SM-1 command injection) | HIGH | Oplossing duidelijk: gestructureerde API + whitelist |
| AndroidX dependency versions | HIGH | Geverifieerd tegen Maven Central |

## Sources

**Stack:**
- Android Developers: BottomSheetBehavior API reference (2025-10-28)
- ProAndroidDev: "Goodbye EncryptedSharedPreferences: A 2026 Migration Guide" (Jay Patel, 2025-12-04)
- AndroidX DataStore release page: stable 1.1.5 (April 2025)
- Android AOSP: Window blurs API (source.android.com, 2025-12-02)
- Flutter docs: Add-to-App, FlutterFragment, platform channels
- ViewPager2:1.1.0 AndroidX stable release

**Features:**
- Warp Terminal documentation: Blocks, Agent Mode, Session Management (docs.warp.dev)
- GitHub Copilot CLI architecture (shubh7.medium.com)
- How Claude Code works (virtuslab.com)
- Material Design: Persistent vs Modal Bottom Sheet (m2.material.io)
- Android Linux Terminal adds tabs — Android 16 (androidauthority.com, 2025)
- Best Practices Developer Onboarding 2025 (blog.stateshift.com)

**Architecture:**
- Flutter docs (add-to-app, FlutterFragment, platform channels)
- Android developer docs (BottomSheetBehavior, CoordinatorLayout)
- Bestaande codebase analyse (soul-terminal v1.0)

**Pitfalls:**
- Flutter GitHub issues (CoordinatorLayout + FlutterView insets)
- Material Components Android issues (BottomSheetBehavior + IME)
- Termux GitHub issues (#4134, #3798 — session management UX)
- dontkillmyapp.com/xiaomi (HyperOS foreground service behavior)
- embracethered.com (ANSI escape injection research)
- Trail of Bits (prompt injection naar RCE)
- Android Developers: OSC 133 shell integration
