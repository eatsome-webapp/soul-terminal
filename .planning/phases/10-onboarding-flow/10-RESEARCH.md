# Phase 10: Onboarding Flow — Research

**Researched:** 2026-03-21
**Phase:** 10-onboarding-flow

## Summary

De bestaande `OnboardingScreen` is een project-onboarding (naam/beschrijving/tech stack) en niet herbruikbaar voor environment setup. Een nieuwe `SetupWizardScreen` moet gemaakt worden. First-run detectie gaat via `SettingsDao` (Drift, al aanwezig) — geen DataStore nodig. Package installatie loopt via `SoulAwareness.runCommand()` die al bestaat en OSC 133-aware is. Device detectie voor Xiaomi/HyperOS is al geïmplementeerd via `SystemBridgeApi.getDeviceInfo()`. `url_launcher` is al een dependency. De routing-aanpak is: `initialLocation` in `main()` uitbreiden met een `setup_completed` check in `SettingsDao`, en de wizard naar `/setup-wizard` routeren.

---

## 1. Bestaande onboarding flow en wat er moet veranderen

### Current State

Er zijn twee bestaande flows:
- `/setup` — `SetupScreen`: API key invoer, navigeert naar `/onboarding` na opslaan
- `/onboarding` — `OnboardingScreen`: project-onboarding (naam, beschrijving, tech stack, goals) in chat-stijl; slaat project op in Drift DB en navigeert naar `/chat/new`

`AppShell` bevat **geen** redirect-logica voor onboarding. De first-run detectie zit in `main()` op r82–88: `initialLocation` wordt bepaald door `hasProjects && savedKey.isNotEmpty`. Als er geen project of key is, gaat de app naar `/chat/new` (demo mode). De huidige `/setup` → `/onboarding` flow is los van de env setup wizard.

### Approach

- Nieuwe route `/setup-wizard` met nieuwe `SetupWizardScreen` — de bestaande `/onboarding` blijft voor project-toevoeging (aangestuurd vanuit AppShell popup menu).
- First-run check in `main()` uitbreiden: als `setup_completed` vlag **niet** gezet is in `SettingsDao`, is `initialLocation = '/setup-wizard'`.
- Na voltooiing: `SettingsDao.setBool('setup_completed', true)` + `context.go('/')`.
- De bestaande `OnboardingState`/`OnboardingNotifier` pattern is het correcte patroon voor de wizard state, maar de inhoud is volledig anders — nieuwe `SetupWizardNotifier` + `SetupWizardState`.

### Key Files

- `flutter_module/lib/main.dart` — r82–88: initialLocation logica uitbreiden
- `flutter_module/lib/core/router/app_router.dart` — `/setup-wizard` route toevoegen
- `flutter_module/lib/ui/onboarding/onboarding_screen.dart` — referentie voor widget patterns, niet aanpassen
- `flutter_module/lib/ui/onboarding/onboarding_provider.dart` — referentie voor NotifierProvider patroon
- Nieuw: `flutter_module/lib/ui/setup_wizard/setup_wizard_screen.dart`
- Nieuw: `flutter_module/lib/ui/setup_wizard/setup_wizard_provider.dart`

---

## 2. First-run detectie via SettingsDao

### Current State

`SettingsDao` (Drift, `flutter_module/lib/services/database/daos/settings_dao.dart`) heeft al:
- `getBool(key)` / `setBool(key, value)` methods
- `SettingsKeys` klasse voor constante sleutels
- Al beschikbaar via `settingsDaoProvider` in `providers.dart`

Er is **geen** `setup_completed` key in `SettingsKeys` — die moet toegevoegd worden.

`datastore-preferences:1.1.5` staat in STATE.md als research finding maar de **codebase gebruikt al Drift `SettingsDao`** voor alle key-value opslag. DataStore is niet geïmplementeerd — `SettingsDao` is de juiste keuze.

### Approach

1. Voeg `static const String setupCompleted = 'setup_completed';` toe aan `SettingsKeys`.
2. In `main()` na de `hasProjects` check: `await settingsDao.getBool(SettingsKeys.setupCompleted) ?? false`. Als `false` → `initialLocation = '/setup-wizard'`.
3. `SetupWizardNotifier.complete()` roept `settingsDao.setBool(SettingsKeys.setupCompleted, true)` aan.

### Key Files

- `flutter_module/lib/services/database/daos/settings_dao.dart` — `SettingsKeys` uitbreiden
- `flutter_module/lib/main.dart` — first-run check toevoegen
- `flutter_module/lib/core/di/providers.dart` — `settingsDaoProvider` al beschikbaar

---

## 3. Package installatie via terminal bridge

### Current State

`SoulAwareness.runCommand(executable, args)` in `flutter_module/lib/services/awareness/soul_awareness_service.dart` is al volledig geïmplementeerd:
- Maakt gebruik van de dedicated awareness sessie (via `createAwarenessSession()`)
- Wacht op OSC 133 completion via `_commandCompleter`
- 30 seconden timeout
- Output wordt gebufferd in `_outputBuffer` en gefilterd (ANSI stripped, secrets gefilterd)
- Retourneert `CommandResult` met output

`TerminalBridgeApi.runCommand(sessionId, executable, args)` is gedefinieerd in Pigeon en geïmplementeerd in `TerminalBridgeImpl.java` (r156–179) — inclusief destructive command check en AlertDialog.

Package installatie commando's per profiel:
- **Claude Code**: `pkg install nodejs git gh` → `npm install -g @anthropic-ai/claude-code`
- **Python**: `pkg install python git`
- **Terminal only**: geen installatie

### Approach

De `SoulAwareness` service hergebruiken:
1. `SetupWizardNotifier` roept `soulAwarenessProvider.notifier.runCommand()` aan per installatie-stap.
2. Output van `CommandResult.output` wordt geparsed naar chat-berichten in wizard state.
3. `soulAwareness.outputStream` (broadcast stream) kan direct gelistend worden voor realtime progress updates tijdens installatie.
4. `SetupWizardNotifier` moet first `soulAwareness.initialize()` aanroepen als awareness sessie nog niet bestaat.

**Let op**: Package installatie commando's voor Termux zijn `pkg` (niet `apt`). `pkg install nodejs git gh` is één commando — moet als `runCommand('pkg', ['install', '-y', 'nodejs', 'git', 'gh'])` gestuurd worden. De `-y` flag voorkomt interactieve bevestiging.

### Key Files

- `flutter_module/lib/services/awareness/soul_awareness_service.dart` — hergebruiken
- `flutter_module/lib/services/awareness/soul_awareness_service.g.dart` — gegenereerd
- Nieuw: `flutter_module/lib/ui/setup_wizard/setup_wizard_provider.dart`

---

## 4. Installatie voortgang streamen naar Flutter UI

### Current State

`SoulAwareness.outputStream` is een `StreamController<String>.broadcast()` — elke subscriber ontvangt real-time output. `onTerminalOutput()` wordt aangeroepen vanuit `SoulApp` (implementeert `SoulBridgeApi`) zodra Java output stuurt.

De bestaande `OnboardingScreen` toont al een `ListView` van berichten in chat-stijl — dat patroon is direct herbruikbaar voor de installatie-stap van de wizard.

### Approach

In de installatie-stap van `SetupWizardScreen`:
1. Listen op `soulAwarenessProvider.notifier.outputStream` via `StreamBuilder` of in de notifier zelf.
2. Elke output-regel wordt toegevoegd als systeem-bericht in de wizard state.
3. Visueel: systeem-berichten als chips/cards met monospace font — duidelijk onderscheid van SOUL-berichten.
4. Auto-scroll naar beneden bij nieuwe berichten (ScrollController).
5. Bij `CommandResult` completion: success of error bericht toevoegen.

**Alternatief** (schoner): `SetupWizardNotifier` luistert op `outputStream` via `ref.listen` of directe stream subscription en appended berichten aan `state.installLog`. De UI bouwt de list van `state.installLog`.

### Key Files

- `flutter_module/lib/services/awareness/soul_awareness_service.dart` — `outputStream` getter
- Nieuw: `flutter_module/lib/ui/setup_wizard/setup_wizard_screen.dart` — installatie stap

---

## 5. Xiaomi/HyperOS detectie

### Current State

`SystemBridgeApi` (Pigeon) + `SystemBridgeImpl.java` zijn al volledig geïmplementeerd:
- `SystemBridgeImpl.getDeviceInfo()` retourneert `Build.MANUFACTURER`, `Build.MODEL`, `Build.VERSION.RELEASE`, `Build.VERSION.SDK_INT`
- Pigeon definitie: `flutter_module/pigeons/system_bridge.dart`
- Generated Dart: `flutter_module/lib/generated/system_bridge.g.dart`

HyperOS detectie logica:
- `manufacturer.toLowerCase() == 'xiaomi'` detecteert Xiaomi devices
- HyperOS vs MIUI: via `Build.VERSION.RELEASE` is niet betrouwbaar; voor de wizard is `manufacturer == 'xiaomi'` voldoende — beide hebben dezelfde battery/autostart restricties

### Approach

In `SetupWizardNotifier.build()`:
```dart
final deviceInfo = await SystemBridgeApi().getDeviceInfo();
final isXiaomi = deviceInfo.manufacturer.toLowerCase() == 'xiaomi';
```
Wizard-stap 5 (HyperOS instructies) wordt overgeslagen als `!isXiaomi`.

**Geen nieuwe Java code nodig** — `SystemBridgeApi` is al klaar.

### Key Files

- `flutter_module/lib/generated/system_bridge.g.dart` — `SystemBridgeApi` Dart client
- `app/src/main/java/com/termux/bridge/SystemBridgeImpl.java` — al geïmplementeerd

---

## 6. Shell configuratie schrijven (.bashrc/.zshrc)

### Current State

Geen bestaande implementatie. OSC 133 configuratie is vereist voor Phase 9 AWAR-03.

Bash configuratie: `PROMPT_COMMAND='printf "\033]133;D\007"'`
Zsh configuratie: `precmd() { printf "\033]133;D\007" }`

Via `SoulAwareness.runCommand()`:
- Bash: `runCommand('bash', ['-c', 'echo \'PROMPT_COMMAND="printf \\\\033]133;D\\\\007"\' >> ~/.bashrc'])`
- Zsh: `runCommand('bash', ['-c', 'echo \'precmd() { printf "\\\\033]133;D\\\\007"; }\' >> ~/.zshrc'])`

**Let op shell escaping**: dubbele quotes en backslashes moeten correct escaped worden. Veiliger is een heredoc of Python-based schrijven:
`runCommand('python3', ['-c', 'open("/data/data/com.soul.terminal/files/home/.bashrc", "a").write(\'...\')'])`

Nog veiliger: via `sendInput` een multi-line echo commando sturen. Of een dedicated `writeBashrcConfig()` methode toevoegen aan de Pigeon bridge (writes via Java FileOutputStream — geen shell escaping issues).

**Aanbeveling**: Voeg `void writeShellConfig(String content, String filepath)` toe aan `TerminalBridgeApi` in Pigeon, geïmplementeerd in Java met `FileOutputStream`. Zo vermijd je shell escaping complexiteit.

### Approach

Optie A (simpel, huidige API): `sendInput` in de awareness sessie met zorgvuldig escaped commando.
Optie B (robuust, aanbevolen): Nieuw Pigeon method `writeShellConfig(filepath, content)` → Java schrijft direct naar filesystem.

Voor optie B: Pigeon definitie uitbreiden, code handmatig genereren (patroon uit STATE.md §From 08-03), Java implementatie in `TerminalBridgeImpl`.

### Key Files

- `flutter_module/pigeons/terminal_bridge.dart` — uitbreiden (indien optie B)
- `app/src/main/java/com/termux/bridge/TerminalBridgeImpl.java` — uitbreiden (indien optie B)
- `flutter_module/lib/generated/terminal_bridge.g.dart` — handmatig updaten (pigeon codegen via cmd-proxy als token beschikbaar)

---

## 7. GoRouter redirect voor first-run

### Current State

GoRouter heeft **geen redirect functie** in `app_router.dart` — geen `redirect:` parameter op routes. First-run routing gaat via `initialLocation` in `main()`, niet via GoRouter redirect.

`AppShell` bevat ook geen redirect logica — dat stond in het CONTEXT.md als "AppShell r51" maar die logica bestaat niet in de huidige codebase. De AppShell toont gewoon de shell met bottom nav.

### Approach

De bestaande aanpak is de juiste: `main()` berekent `initialLocation` voordat de app start. De setup-wizard check is een extra conditie:

```dart
// In main() na ObjectBox init:
final isSetupComplete = await settingsDao.getBool(SettingsKeys.setupCompleted) ?? false;
if (!isSetupComplete) {
  initialLocation = '/setup-wizard';
} else if (hasProjects && savedKey.isNotEmpty) {
  initialLocation = '/';
} else {
  initialLocation = '/chat/new';
}
```

Geen GoRouter `redirect:` nodig — `initialLocation` is voldoende voor first-run, want de wizard is een one-time flow.

### Key Files

- `flutter_module/lib/main.dart` — initialLocation logica
- `flutter_module/lib/core/router/app_router.dart` — `/setup-wizard` route toevoegen

---

## 8. GitHub CLI auth flow

### Current State

`url_launcher: ^6.3.0` staat in `pubspec.yaml` (r40). `launchUrl(uri, mode: LaunchMode.externalApplication)` patroon is al gebruikt in `setup_screen.dart` (r55) en `byok_settings.dart` (r158).

GitHub CLI `gh auth login --web` opent zelf een browser. Maar in een terminal sessie is dit interactief — de wizard moet dit anders aanpakken.

**`gh auth login --web` flow**:
1. `gh` genereert een one-time code + URL
2. Opent browser (of vraagt gebruiker dat te doen)
3. Wacht tot OAuth callback
4. Dit is een interactieve process die terminal input/output vereist

### Approach

Via `SoulAwareness.runCommand()` is dit niet direct mogelijk omdat `gh auth login` interactief is en wacht op browser callback. Betere aanpak:

1. Wizard toont instructie-stap: "We starten GitHub CLI authenticatie"
2. Gebruik `sendInput` (niet `runCommand`) om `gh auth login --web\n` naar de awareness sessie te sturen
3. Terminal sheet openen zodat gebruiker de auth code ziet: `TerminalBridgeApi().openTerminalSheet()`
4. Wizard wacht met "Ik heb ingelogd" knop — trust-based verificatie (zoals HyperOS stap)
5. Na klik: wizard gaat naar volgende stap

Verificatie na auth: `runCommand('gh', ['auth', 'status'])` — exit code 0 = success. Maar dit vereist OSC 133 en een non-interactive commando.

**Alternatief (eenvoudiger)**: Wizard toont instructies als chat-berichten + knop "Open terminal" die sheet opent. Gebruiker voert zelf `gh auth login --web` uit. Wizard heeft "Ik heb dit gedaan" knop.

### Key Files

- `flutter_module/lib/generated/terminal_bridge.g.dart` — `openTerminalSheet()`, `sendInput()`
- `flutter_module/lib/ui/setup_wizard/setup_wizard_screen.dart` — GitHub stap

---

## 9. API Key invoer (ONBR-03)

### Current State

`ApiKeyService` (`flutter_module/lib/services/auth/api_key_service.dart`) is volledig klaar:
- `validateFormat(key)` — client-side format check
- `validateAndSaveKey(key)` — format + API call via `count_tokens` + opslaan in `flutter_secure_storage`
- `saveAnthropicKey(key)` — direct opslaan zonder validatie
- Backed door Android Keystore via `flutter_secure_storage`

`SetupScreen` (`flutter_module/lib/ui/setup/setup_screen.dart`) heeft al een volledige API key invoer UI met paste knop, obscure toggle, validator. Dit is herbruikbaar als widget in de wizard.

### Approach

Hergebruik `ApiKeyService.validateAndSaveKey()` direct in `SetupWizardNotifier`. Geen nieuwe Java code nodig. De UI kan een vereenvoudigde versie van `SetupScreen` zijn ingebed als wizard-stap widget.

### Key Files

- `flutter_module/lib/services/auth/api_key_service.dart` — direct hergebruiken
- `flutter_module/lib/ui/setup/setup_screen.dart` — referentie voor UI patterns

---

## Validatie Architectuur

Per requirement:

| Req | Validatie |
|-----|-----------|
| ONBR-01 | Profiel keuze UI getoond op eerste start |
| ONBR-02 | `pkg install` output verschijnt als berichten in wizard, CommandResult.completed = true na finish |
| ONBR-03 | `ApiKeyService.validateAndSaveKey()` retourneert null (= success); `ApiKeyService.hasAnthropicKey()` = true na wizard |
| ONBR-04 | `gh auth status` exit 0 na auth; of trust-based knop |
| ONBR-05 | `SystemBridgeApi().getDeviceInfo().manufacturer == 'xiaomi'` — stap verschijnt/verdwijnt op basis hiervan |
| ONBR-06 | `.bashrc` bevat OSC 133 PROMPT_COMMAND na wizard; verificeren met `grep` via `runCommand` |
| ONBR-07 | "Je omgeving is klaar" scherm verschijnt als laatste stap; `setup_completed = true` in SettingsDao |

**Herstart test**: App verwijderen (of `SettingsDao` leegmaken) → wizard verschijnt. App na wizard herstarten → wizard verschijnt **niet** (setup_completed = true).

---

## Critical Pitfalls

1. **`pkg install` is interactief zonder `-y`**: Altijd `-y` flag meegeven. Zonder `-y` wacht pkg op gebruikersbevestiging en blokkeert de OSC 133 completion detectie forever.

2. **OSC 133 dependency**: De wizard-installatie via `SoulAwareness.runCommand()` vereist dat OSC 133 geconfigureerd is in de shell. Maar dat is wat ONBR-06 configureert. Kip-en-ei probleem: vóór OSC 133 config is `runCommand()` unreliable (timeout na 30s). **Oplossing**: Gebruik `sendInput()` voor de shell config stap (geen completion detection nodig), of schrijf config via Java file I/O (Pigeon methode) vóór de installatie-stap.

3. **Awareness sessie beschikbaarheid**: `SoulAwareness.initialize()` creëert de dedicated sessie. Als Phase 9 AWAR-03 nog niet volledig geïmplementeerd is, werkt `runCommand()` niet correct. Wizard moet graceful degraderen naar timeout-based flow.

4. **Shell escaping voor .bashrc schrijven**: De OSC 133 string bevat backslashes en escape sequences. Shell-based schrijven (echo >> .bashrc) is foutgevoelig. Gebruik Java file I/O (optie B) of Python oneliners.

5. **`gh auth login --web` is interactief**: Dit is geen fire-and-forget commando. De wizard moet de terminal sheet openen en trust-based "Ik heb dit gedaan" gebruiken, niet proberen de auth flow automatisch te detecteren.

6. **SettingsDao beschikbaar na ObjectBox init**: De setup_completed check in `main()` vereist dat `SoulDatabase` al geopend is. ObjectBox init staat vóór de check (r22–27 in main.dart) — volgorde is correct. Maar `SettingsDao` gaat via Drift, niet ObjectBox. `SoulDatabase` heeft zowel Drift als ObjectBox — controleren of beide geïnitialiseerd zijn vóór de check.

7. **Back-button tijdens installatie**: Gebruiker mag de wizard niet afsluiten tijdens actieve package installatie. `PopScope`/`WillPopScope` gebruiken om back-button te blokkeren in de installatie-stap.

8. **Herstart na wizard**: Na `setup_completed = true` opslaan én `context.go('/')`, zal de gebruiker de AppShell zien. Als er nog geen API key is (wizard stap overgeslagen), werkt SOUL chat niet. Wizard-completion logica moet controleren of minimaal de installatie succesvol was — API key en GitHub zijn optioneel per spec (skippable).

---

## RESEARCH COMPLETE
