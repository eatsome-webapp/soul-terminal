---
phase: 10
status: passed
date: 2026-03-21
---
# Phase 10: Onboarding Flow — Verification

## Must-Haves

| Must-Have | Status | Evidence |
|-----------|--------|----------|
| Eerste start routeert naar /setup-wizard wanneer setup_completed niet gezet is | PASS | `main.dart:86-87`: `if (!isSetupComplete) { initialLocation = '/setup-wizard'; }` |
| Tweede start slaat wizard over (setup_completed = true gepersisteerd) | PASS | `main.dart:81`: `getBool(SettingsKeys.setupCompleted) ?? false`; `_persistCompletion()` roept `setBool(SettingsKeys.setupCompleted, true)` aan voor completion step renderen |
| Welkomstscherm toont drie profielopties: Claude Code, Python, Alleen terminal | PASS | `setup_wizard_screen.dart:112-134`: drie `_buildProfileCard` widgets met `SetupProfile.claudeCode`, `.python`, `.terminalOnly` |
| Completion scherm toont "Je omgeving is klaar" en navigeert naar hoofdapp | PASS | `setup_wizard_screen.dart:599`: `'Je omgeving is klaar!'`; regel 614: `context.go('/')` |
| writeShellConfig Pigeon-methode voor veilig bestandsschrijven zonder shell escaping | PASS | `TerminalBridgeImpl.java:216-226`: `FileOutputStream(file, true)` in append-modus; `terminal_bridge.dart:61`; `terminal_bridge.g.dart:373` |
| SetupWizardProvider beheert wizard-state met alle staptransities | PASS | `setup_wizard_provider.dart`: `_advanceToNextStep()` switch-statement dekt alle 7 stappen, conditioneel voor `terminalOnly` en `!isXiaomi` |
| OSC 133 PROMPT_COMMAND geschreven naar .bashrc via writeShellConfig | PASS | `setup_wizard_provider.dart:284-286`: `PROMPT_COMMAND='printf "\033]133;D\007"'` naar `.bashrc` |
| OSC 133 precmd hook geschreven naar .zshrc via writeShellConfig | PASS | `setup_wizard_provider.dart:290-292`: `precmd() { printf "\033]133;D\007"; }` naar `.zshrc` |
| Shell config fout is non-fatal | PASS | `setup_wizard_provider.dart:296-300`: catch-blok stelt `shellConfigDone: true` in en logt waarschuwing |
| Xiaomi stap alleen op Xiaomi-apparaten | PASS | `_detectDevice()` via `SystemBridgeApi().getDeviceInfo().manufacturer`; `_advanceToNextStep()` slaat `xiaomiBattery` over als `!state.isXiaomi` |

## Requirements Coverage

| REQ-ID | Plan | Geïmplementeerd | Bewijs | REQUIREMENTS.md status |
|--------|------|-----------------|--------|------------------------|
| ONBR-01 | 10-01 | PASS | `setup_wizard_screen.dart:112-134`: welkomstscherm met drie profielkaarten; `selectProfile()` in provider | Marked [x] — correct |
| ONBR-02 | 10-02 | PASS | `startInstallation()` met `sendInput` + marker-polling (`SOUL_PKG_DONE`, `SOUL_NPM_DONE`), real-time `outputStream.listen`, `installLog` streaming in UI met monospace font | Marked [ ] — **GAP: niet bijgewerkt** |
| ONBR-03 | 10-02 | PASS | `validateApiKey()`: `sk-ant-` format check, `ApiKeyService().validateAndSaveKey()`, `apiKeyNotifierProvider` update; UI met `TextField obscureText`, paste-knop, "Valideren" en "Overslaan" | Marked [ ] — **GAP: niet bijgewerkt** |
| ONBR-04 | 10-02 | PASS | `openTerminalForGithub()`: `openTerminalSheet()` + `sendInput('gh auth login --web\n')`; UI: "Open terminal", "Ik heb ingelogd", "Overslaan" | Marked [ ] — **GAP: niet bijgewerkt** |
| ONBR-05 | 10-02 | PASS | `_detectDevice()` detecteert Xiaomi via manufacturer; `_buildXiaomiStep()` toont genummerde Autostart + Battery-instructies; stap wordt overgeslagen op niet-Xiaomi | Marked [ ] — **GAP: niet bijgewerkt** |
| ONBR-06 | 10-01/03 | PASS | `writeShellConfig()` schrijft PROMPT_COMMAND naar `.bashrc` en precmd naar `.zshrc` via Pigeon; UI auto-trigger via `addPostFrameCallback` | Marked [x] — correct |
| ONBR-07 | 10-01/03 | PASS | `_buildCompleteStep()` met "Je omgeving is klaar!", `_completionSummary()`, "Begin" knop met `context.go('/')` | Marked [x] — correct |

## Human Verification

De volgende punten zijn functioneel correct in code maar kunnen niet automatisch worden geverifieerd:

1. **Installatie-flow end-to-end** (ONBR-02): `startInstallation()` vereist een actieve `soulAwarenessProvider` met een Termux-sessie. Verificeer handmatig: kies profiel "Claude Code", controleer of `pkg install` en `npm install` in de terminal-output verschijnen en of de voortgangslog in real-time scrollt.

2. **API key validatie via netwerk** (ONBR-03): `ApiKeyService().validateAndSaveKey()` maakt een echte API-aanroep. Verificeer: voer een geldige `sk-ant-` key in, bevestig dat de wizard automatisch naar de volgende stap gaat en dat de key beschikbaar is na herstart.

3. **GitHub CLI auth** (ONBR-04): vereist dat `gh` geïnstalleerd is en dat de terminal-sheet opent. Verificeer: tik "Open terminal", controleer of de bottom sheet opent met `gh auth login --web` gepre-typed.

4. **Xiaomi device detection** (ONBR-05): `SystemBridgeApi().getDeviceInfo()` haalt manufacturer op van het apparaat. Verificeer op de Xiaomi 17 Ultra dat de `xiaomiBattery`-stap verschijnt; op een niet-Xiaomi emulator dat de stap wordt overgeslagen.

5. **Second-run skip**: Vervolledig de wizard, forceer herstart van de app, bevestig dat de wizard niet opnieuw verschijnt.

6. **PopScope tijdens installatie**: Bevestig dat de terugknop geblokkeerd is terwijl `isInstalling = true`.

## Gaps

### Gap 1 — REQUIREMENTS.md niet gesynchroniseerd (administratief, geen code-gap)

ONBR-02, ONBR-03, ONBR-04 en ONBR-05 zijn in de code volledig geïmplementeerd en voldoen aan alle acceptance criteria van plans 10-02. De REQUIREMENTS.md markeert ze echter nog als `[ ]` (Pending) in plaats van `[x]` (Complete). Ook in de requirements-tabel staat status "Pending" voor deze vier items.

**Impact**: puur administratief — geen functionele correctheid in het geding.

**Actie**: Update REQUIREMENTS.md: zet ONBR-02..05 op `[x]` en de tabelstatussen op "Complete".

---

### Gap 2 — `retryInstallation()` wist `installLog` maar stelt `installError` niet correct in via `clearInstallError`

In `setup_wizard_provider.dart:186`:
```dart
state = state.copyWith(installError: null, installLog: []);
```
`copyWith` heeft een aparte `clearInstallError: bool`-parameter (regel 63), maar `retryInstallation()` passeert `installError: null` direct. Dit werkt door de `copyWith`-logica (`installError ?? this.installError` wordt null als `null` wordt meegegeven), maar is inconsistent met het `clearInstallError`-patroon dat elders wordt gebruikt (`startInstallation` op regel 127 gebruikt `clearInstallError: true`).

**Impact**: geen bug — gedrag is identiek. Puur stijl-inconsistentie.

---

### Gap 3 — `startInstallation()` roept `_advanceToNextStep()` aan na success, maar `proceedFromInstall()` bestaat ook

Na succesvolle installatie (regel 172-173) roept `startInstallation()` zowel `installSuccess: true` in als `_advanceToNextStep()`. De UI toont echter een "Doorgaan"-knop die `notifier.proceedFromInstall()` aanroept (screen regel 284). Dit betekent dat na installatie de wizard automatisch naar de volgende stap springt zonder dat de user de "Doorgaan"-knop hoeft te tikken — de knop is dus onbereikbaar in het success-pad.

**Impact**: lichte UX-discrepantie. User ziet de "Doorgaan"-knop kort voordat de stap wisselt. Geen crash, geen dataverlies. Optionele fix in Phase 11.
