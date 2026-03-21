# Phase 10: Onboarding Flow - Context

**Gathered:** 2026-03-21
**Status:** Ready for planning

<domain>
## Phase Boundary

Meerstaps onboarding wizard voor eerste app-start. Gebruiker kiest een setup-profiel (Claude Code / Python / Alleen terminal), packages worden geïnstalleerd via terminal sessie met voortgang in SOUL chat, API key wordt ingevoerd en opgeslagen, GitHub CLI wordt geauthenticeerd, Xiaomi/HyperOS battery-instructies worden getoond op relevante devices, en shell configuratie (OSC 133) wordt geschreven. Na voltooiing toont "Je omgeving is klaar" en navigeert naar SOUL chat.

</domain>

<decisions>
## Implementation Decisions

### Wizard flow design
- Nieuwe `SetupWizardScreen` widget — bestaande `OnboardingScreen` is project-onboarding (naam/beschrijving/tech stack), niet geschikt voor environment setup
- Lineaire stap-navigatie met skip-mogelijkheid op optionele stappen (API key, GitHub CLI)
- Wizard-stijl met cards/stappen en voortgangsbalk — niet chat-achtig
- First-run detectie via DataStore boolean flag (`setup_completed`), check bij app start in router redirect
- Na voltooiing: flag opslaan, navigeren naar SOUL chat hoofdscherm
- Bestaande `/onboarding` route hergebruiken of nieuwe `/setup-wizard` route — Claude's discretion

### Package installation UX
- Voortgang als chat-berichten (systeem-berichten stijl) in SOUL chat UI — per ONBR-02 requirement
- Dedicated terminal sessie via Pigeon voor package installatie — voorkomt conflict met user-sessies
- Bij installatie-fout: foutmelding in chat + retry knop + mogelijkheid om te skippen en later handmatig te installeren
- Foreground installatie — gebruiker ziet wat er gebeurt, kan niet per ongeluk afsluiten tijdens installatie
- Installatie-commando's via gestructureerde `runCommand()` API (Phase 9 AWAR-05 whitelist is dependency)

### Setup profiel inhoud
- **Claude Code profiel**: `nodejs`, `git`, `gh` packages + `npm install -g @anthropic-ai/claude-code`
- **Python profiel**: `python`, `pip`, `git` packages
- **Alleen terminal profiel**: geen package installatie, skip naar volgende stap
- Eén profiel kiezen, geen combinaties — gebruiker kan later zelf extra packages installeren

### API key invoer (ONBR-03)
- Bestaande `ApiKeyService` hergebruiken — heeft al format validatie (`sk-ant-api03-...`), API validatie via `count_tokens`, en secure storage via `flutter_secure_storage`
- API key stap is skippable — gebruiker kan later invoeren via settings
- Validatie inline in wizard: format check → API call → opslaan of foutmelding

### GitHub CLI authenticatie (ONBR-04)
- Flow via SOUL chat: `gh auth login --web` opent browser voor OAuth
- Skippable stap — niet iedereen gebruikt GitHub
- Toon instructies als chat-berichten, open browser via `url_launcher`

### Device-specifieke instructies (ONBR-05)
- Xiaomi/HyperOS detectie via `Build.MANUFACTURER` + `Build.VERSION` check via MethodChannel (patroon al in `permission_service.dart`)
- Dedicated wizard-stap met instructies voor battery restrictions + autostart
- Stap verschijnt alleen op Xiaomi/HyperOS devices — overgeslagen op andere devices
- Trust-based verificatie: "Ik heb dit gedaan" knop — autostart status is niet programmatisch te verifiëren

### Shell configuratie (ONBR-06)
- Schrijf OSC 133 `PROMPT_COMMAND` configuratie naar `.bashrc` (bash) en `precmd` hook naar `.zshrc` (zsh)
- Configuratie via terminal sessie (echo/append commando's)
- Vereist voor Phase 9 AWAR-03 (commando-klaar detectie) om te functioneren

### Claude's Discretion
- Exacte wizard UI design (kleuren, spacing, iconen per stap)
- Stap-volgorde optimalisatie (welkom → profiel → packages → API key → GitHub → HyperOS → shell config → klaar)
- Error handling bij shell config schrijven
- Hoe bestaande OnboardingScreen/route te reconcilen met nieuwe SetupWizardScreen
- Animaties/transities tussen wizard stappen

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Bestaande onboarding code (te vervangen/aanvullen)
- `flutter_module/lib/ui/onboarding/onboarding_screen.dart` — Bestaande project-onboarding UI (chat-stijl), niet herbruikbaar maar referentie voor widget patterns
- `flutter_module/lib/ui/onboarding/onboarding_provider.dart` — Bestaande onboarding state management, OnboardingStep enum — te vervangen met nieuwe wizard steps

### API key handling
- `flutter_module/lib/services/auth/api_key_service.dart` — Volledige ApiKeyService met format validatie, API validatie via count_tokens, secure storage — direct herbruikbaar voor ONBR-03

### Routing & first-run detection
- `flutter_module/lib/core/router/app_router.dart` — GoRouter configuratie, bestaande `/onboarding` route op r87
- `flutter_module/lib/ui/shell/app_shell.dart` — r51: huidige onboarding redirect logica

### Device detectie
- `flutter_module/lib/services/platform/permission_service.dart` — Xiaomi/HyperOS awareness bij NotificationListenerService — patroon voor device detectie

### Pigeon bridge (package installatie via terminal)
- `flutter_module/pigeons/terminal_bridge.dart` — Pigeon definitie met TerminalBridgeApi HostApi
- `app/src/main/java/com/termux/bridge/TerminalBridgeImpl.java` — Java HostApi implementatie: `executeCommand()`, `createSession()`
- `flutter_module/lib/generated/terminal_bridge.g.dart` — Generated Dart Pigeon code

### Phase 9 dependency (awareness)
- `.planning/phases/09-soul-terminal-awareness/09-CONTEXT.md` — OSC 133 configuratie, gestructureerde command API, dedicated sessie concept
- `.planning/ROADMAP.md` §Phase 10 — Requirements ONBR-01..07, dependencies op Phase 6 en 9

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **ApiKeyService**: Volledige service met format + API validatie en secure storage — direct herbruikbaar voor ONBR-03
- **OnboardingScreen**: Chat-stijl widget met message list, input field, progress bar — referentie maar niet herbruikbaar voor wizard-stijl
- **OnboardingNotifier**: State management patroon met steps enum en copyWith — patroon herbruikbaar, inhoud vervangen
- **PermissionService**: Xiaomi/HyperOS bewuste permission handling — patroon voor device detectie
- **GoRouter**: Bestaande `/onboarding` route en redirect logica in AppShell

### Established Patterns
- **Riverpod NotifierProvider**: State management via Notifier + NotifierProvider (zie onboarding_provider.dart)
- **GoRouter routing**: Shell routes met bottom nav, top-level routes voor flows (setup, chat)
- **flutter_secure_storage**: API keys via FlutterSecureStorage (Android Keystore backed)
- **Pigeon bridge**: Type-safe Flutter ↔ Java communicatie voor terminal operaties

### Integration Points
- **Router redirect**: AppShell r51 checkt of onboarding nodig is — moet aangepast voor nieuwe setup wizard
- **DataStore**: `datastore-preferences:1.1.5` al als dependency — gebruiken voor `setup_completed` flag
- **Pigeon createSession/executeCommand**: Package installatie uitvoeren in dedicated terminal sessie
- **SoulBridgeController.onTerminalTextChanged()**: Output streaming voor installatie-voortgang in chat

</code_context>

<specifics>
## Specific Ideas

- HyperOS battery-instructies zijn kritiek voor Xiaomi 17 Ultra (primair testdevice) — zonder dit werken achtergrond-sessies niet
- Package installatie moet voortgang tonen als chat-berichten, niet als droge log output — het is SOUL die je helpt met setup
- OSC 133 configuratie in .bashrc/.zshrc is essentieel voor Phase 9 AWAR-03 — zonder dit kan SOUL niet detecteren wanneer een commando klaar is
- Setup wizard moet aanvoelen als een begeleide ervaring, niet als een configuratie-scherm

</specifics>

<deferred>
## Deferred Ideas

- Multi-step command sequences zonder per-stap bevestiging — v2 (AUTO-01)
- Automatisch detecteren welke packages al geïnstalleerd zijn en overslaan — nice-to-have, niet v1.1

</deferred>

---

*Phase: 10-onboarding-flow*
*Context gathered: 2026-03-21*
