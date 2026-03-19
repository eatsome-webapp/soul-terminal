# Roadmap: SOUL Terminal

**Milestone:** v1.0
**Granularity:** coarse
**Created:** 2026-03-19

## Phase Overview

| # | Phase | Goal | Requirements | Success Criteria |
|---|-------|------|--------------|------------------|
| 1 | Foundation | Werkende branded APK met CI/CD | REBR-01..06, CICD-01, CICD-02 | 4 |
| 2 | Bootstrap Pipeline | Eigen packages met com.soul.terminal prefix | BOOT-01..05, CICD-04 | 3 |
| 3 | Flutter Integration | Flutter module + Pigeon bridge in terminal app | FLUT-01..05, PIGB-01..05, CICD-03 | 5 |
| 4 | Terminal Enhancements | Geavanceerde terminal features | TERM-01..03 | 3 |

## Phase Details

### Phase 1: Foundation
**Goal:** Een werkende SOUL Terminal APK met correcte branding, package name, en geautomatiseerde builds.
**Requirements:** REBR-01, REBR-02, REBR-03, REBR-04, REBR-05, REBR-06, CICD-01, CICD-02
**Dependencies:** none

**Success Criteria:**
1. APK installeert als `com.soul.terminal` naast bestaande Termux zonder conflict
2. Launcher toont "SOUL Terminal" met custom icon en SOUL kleurschema
3. GitHub Actions bouwt automatisch een gesignde APK bij elke push
4. Terminal werkt identiek aan Termux (shell, tabs, extra keys, alle bestaande features)

### Phase 2: Bootstrap Pipeline
**Goal:** Alle packages herbouwd met `com.soul.terminal` prefix en serveerbaar via eigen apt repository.
**Requirements:** BOOT-01, BOOT-02, BOOT-03, BOOT-04, BOOT-05, CICD-04
**Dependencies:** Phase 1 (branded APK nodig om bootstrap te testen)

**Success Criteria:**
1. `pkg install python` (of ander package) installeert vanuit eigen repository met correcte prefix
2. Bootstrap packages laden succesvol bij eerste app start (geen Termux fallback)
3. GitHub Actions workflow kan handmatig getriggerd worden om bootstrap packages te rebuilden

### Phase 3: Flutter Integration
**Goal:** Flutter module embedded in terminal app met werkende Pigeon bridge — AI kan terminal aansturen.
**Requirements:** FLUT-01, FLUT-02, FLUT-03, FLUT-04, FLUT-05, PIGB-01, PIGB-02, PIGB-03, PIGB-04, PIGB-05, CICD-03
**Dependencies:** Phase 1 (werkende APK), Phase 2 niet vereist (bootstrap is parallel track)

**Success Criteria:**
1. Toggle-knop wisselt tussen terminal-fullscreen en Flutter-fullscreen zonder lag
2. Flutter module kan een commando uitvoeren in de terminal en het resultaat ontvangen via Pigeon
3. Terminal output streamt naar Flutter met max 10 updates/sec (debounced)
4. cmd-proxy is volledig vervangen door Pigeon bridge voor Claude Code communicatie
5. CI/CD bouwt Flutter module + Gradle in twee stages succesvol

### Phase 4: Terminal Enhancements
**Goal:** Terminal features die power users verwachten — keyboard protocol, notificaties, command palette.
**Requirements:** TERM-01, TERM-02, TERM-03
**Dependencies:** Phase 1 (werkende APK). Kan parallel met Phase 2 en 3.

**Success Criteria:**
1. Neovim/Helix herkent Kitty keyboard protocol en modifier keys werken correct
2. Terminal commando's kunnen Android notificaties triggeren via OSC9 escape sequence
3. Command palette opent met fuzzy search over sessies, commands en history

---
*Created: 2026-03-19*
