---
phase: 06-app-merge
plan: 01
subsystem: ui
tags: [flutter, dart, riverpod, objectbox, drift, anthropic_sdk_dart, pigeon]

# Dependency graph
requires:
  - phase: 05-terminal-quick-wins
    provides: flutter_module with Pigeon bridge scaffolding
provides:
  - 237 SOUL app Dart source files in flutter_module/lib/
  - ObjectBox generated files (model + store) in flutter_module/lib/
  - SOUL assets (default_intervention_config.yaml) in flutter_module/assets/
  - Merged pubspec.yaml with all 52 SOUL production + dev dependencies
affects: [06-app-merge, 07-bottom-sheet-layout]

# Tech tracking
tech-stack:
  added: [flutter_riverpod, drift, objectbox, anthropic_sdk_dart, mcp_dart, sentry_flutter, go_router, freezed, xterm, envied]
  patterns: [riverpod code generation (@riverpod), drift DAOs, objectbox HNSW vectors, freezed immutable models]

key-files:
  created:
    - flutter_module/lib/core/ (di, router, theme, utils, constants, sentry_config)
    - flutter_module/lib/models/ (conversation, decision, intervention, project, etc.)
    - flutter_module/lib/services/ (ai, agentic, database, memory, vessels, platform, etc.)
    - flutter_module/lib/ui/ (chat, agentic, conversations, decisions, settings, etc.)
    - flutter_module/lib/objectbox-model.json
    - flutter_module/lib/objectbox.g.dart
    - flutter_module/assets/config/default_intervention_config.yaml
  modified:
    - flutter_module/pubspec.yaml

key-decisions:
  - "soul_core is dead code (empty library stub) — no imports found, nothing to copy"
  - "pigeon: ^22.7.0 retained as runtime dependency (not just dev dep)"
  - "objectbox.g.dart placed at flutter_module/lib/ root for correct relative import from main.dart"

patterns-established:
  - "Source from soul-app is copied verbatim — no package rename yet (handled in later plans)"
  - "flutter_module/lib/generated/ preserved throughout all copy operations"

requirements-completed: [MERG-01, MERG-02]

# Metrics
duration: 2min
completed: 2026-03-20
---

# Phase 6 Plan 01: Code Copy & Dependency Merge Summary

**237 SOUL Dart files, ObjectBox schema, intervention config assets, and all 52 dependencies merged into flutter_module — foundation for app merge complete**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-20T22:21:43Z
- **Completed:** 2026-03-20T22:24:06Z
- **Tasks:** 5 (4 code tasks + 1 no-op verification task)
- **Files modified:** 264

## Accomplishments
- Copied all 237 SOUL app Dart source files (core, models, services, ui) to flutter_module/lib/
- Copied ObjectBox generated files (objectbox-model.json + objectbox.g.dart) to flutter_module/lib/
- Copied default_intervention_config.yaml to flutter_module/assets/config/
- Merged complete pubspec.yaml with 41 production deps + 8 dev deps, SDK ^3.11.1, preserved module: section

## Task Commits

Each task was committed atomically:

1. **Task 1: Copy SOUL app Dart source tree** - `c3b91219` (feat)
2. **Task 2: Copy ObjectBox generated files** - `9179b1aa` (feat)
3. **Task 3: Merge soul_core stub** - no commit (soul_core is dead code, no imports found)
4. **Task 4: Copy SOUL app assets** - `31902fd3` (feat)
5. **Task 5: Merge pubspec.yaml** - `401d534c` (feat)

**Plan metadata:** (docs commit, see below)

## Files Created/Modified
- `flutter_module/lib/core/` - di, router, theme, utils, constants, sentry_config
- `flutter_module/lib/models/` - conversation, decision, intervention, project, mood_state, profile_trait, etc.
- `flutter_module/lib/services/` - ai (claude_service, prompt_composer, layers), agentic (engine, tools), database (drift daos + tables), memory, vessels (openclaw, agent_sdk), platform, etc.
- `flutter_module/lib/ui/` - chat, agentic, conversations, decisions, onboarding, settings, shell, terminal, vessels
- `flutter_module/lib/objectbox-model.json` - ObjectBox entity schema
- `flutter_module/lib/objectbox.g.dart` - ObjectBox store code
- `flutter_module/assets/config/default_intervention_config.yaml` - Intervention config
- `flutter_module/pubspec.yaml` - All 52 SOUL dependencies merged

## Decisions Made
- soul_core (`~/soul-app/packages/soul_core/lib/soul_core.dart`) is an empty library stub with no exports — confirmed zero imports in copied code, skipped entirely
- pigeon: ^22.7.0 kept as runtime dep (required for Pigeon generated code in flutter_module/lib/generated/)
- objectbox.g.dart placed at lib/ root — correct location for relative import from main.dart

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- flutter_module/lib/ now contains the full SOUL app source tree
- pubspec.yaml has all dependencies needed for pub get
- Next plan (06-02) will handle import path migration (package:soul_app/ → flutter_module package references)
- Pigeon generated files in flutter_module/lib/generated/ remain untouched

---
*Phase: 06-app-merge*
*Completed: 2026-03-20*
