---
phase: 06-app-merge
plan: 04
subsystem: ui
tags: [flutter, dart, services, ai, agentic, vessels, openclaw, foreground-service]

requires:
  - phase: 06-03
    provides: database layer, models, generated Drift code

provides:
  - 112 service source files in flutter_module/lib/services/
  - ai/ layer (ClaudeService, SoulBrain, domains, layers)
  - agentic/ engine (MCP manager, tools, WAL)
  - memory/ services (VectorStore, EmbeddingService)
  - chat/, demo/, monitoring/, success/ services
  - platform/ services (ForegroundServiceManager soul_foreground/ID 256, LocalNotificationService)
  - vessels/ services (OpenClaw, Agent SDK, VesselManager)

affects: [06-05, 06-06]

tech-stack:
  added: []
  patterns:
    - "Services gekopieerd zonder .g.dart/.freezed.dart — generated files worden apart geregenereerd"
    - "ForegroundServiceManager channel ID soul_foreground en serviceId 256 — geen conflict met Termux IDs 1-10"

key-files:
  created:
    - flutter_module/lib/services/ai/claude_service.dart
    - flutter_module/lib/services/ai/domains/
    - flutter_module/lib/services/ai/layers/
    - flutter_module/lib/services/agentic/
    - flutter_module/lib/services/memory/vector_store.dart
    - flutter_module/lib/services/chat/offline_message_queue.dart
    - flutter_module/lib/services/demo/demo_mode_service.dart
    - flutter_module/lib/services/monitoring/
    - flutter_module/lib/services/success/
    - flutter_module/lib/services/platform/foreground_service_manager.dart
    - flutter_module/lib/services/platform/local_notification_service.dart
    - flutter_module/lib/services/vessels/vessel_manager.dart
    - flutter_module/lib/services/vessels/openclaw/openclaw_client.dart
  modified: []

key-decisions:
  - "Source files gekopieerd zoals ze zijn — geen package:soul_app/ imports gevonden, geen aanpassingen nodig"
  - "Generated files (.g.dart, .freezed.dart) uitgesloten — worden later geregenereerd via build_runner"
  - "foreground_service_manager.dart al correct geconfigureerd: channelId soul_foreground, serviceId 256"

patterns-established:
  - "Services layer volledig losgekoppeld van package:soul_app/ — direct importeerbaar in flutter_module"

requirements-completed: ["MERG-01", "MERG-06", "MERG-09"]

duration: 8min
completed: 2026-03-21
---

# Phase 6 Plan 04: Services layer kopiëren — alle 112 service files

**112 Dart service source files gekopieerd naar flutter_module/lib/services/ verdeeld over ai, agentic, chat, demo, memory, monitoring, platform, success en vessels subdirectories — CI build groen**

## Performance

- **Duration:** 8 min
- **Started:** 2026-03-21T05:41:13Z
- **Completed:** 2026-03-21T05:49:40Z
- **Tasks:** 4
- **Files modified:** 112

## Accomplishments

- ai/ service laag met ClaudeService, SoulBrain, domains/ (6 files) en layers/ (8 files)
- agentic/ engine met MCP manager, tools (7 tools), WAL en project context
- platform/ services inclusief ForegroundServiceManager (soul_foreground channel, serviceId 256) en LocalNotificationService
- vessels/ layer met OpenClaw (10 files), Agent SDK (2 files), VesselManager en VesselInterface
- 0 package:soul_app/ imports — direct bruikbaar in flutter_module

## Task Commits

Elke taak atomisch gecommit:

1. **Task 04.1: ai/ en agentic/ services** - `9df7053f` (feat)
2. **Task 04.2: memory/, chat/, demo/, monitoring/, success/ services** - `ec5bfb6c` (feat)
3. **Task 04.3: platform/ services** - `a9d8cd95` (feat)
4. **Task 04.4: vessels/ services** - `bb30d52f` (feat)

## Files Created/Modified

- `flutter_module/lib/services/ai/` — 15 files (ClaudeService, BriefingEngine, CostTracker, etc.)
- `flutter_module/lib/services/ai/domains/` — 6 domain files
- `flutter_module/lib/services/ai/layers/` — 8 layer files
- `flutter_module/lib/services/agentic/` — 4 root + 3 mcp/ + 7 tools/ = 14 files
- `flutter_module/lib/services/memory/` — 7 files
- `flutter_module/lib/services/chat/` — 1 file
- `flutter_module/lib/services/demo/` — 3 files
- `flutter_module/lib/services/monitoring/` — 2 files (ci_status.freezed.dart en .g.dart uitgesloten)
- `flutter_module/lib/services/success/` — 6 files
- `flutter_module/lib/services/platform/` — 7 files
- `flutter_module/lib/services/vessels/` — 3 root + 2 agent_sdk/ + 3 models/ + 10 openclaw/ = 18 files (zonder models/vessel_task.dart die geen freezed heeft)

## Decisions Made

- Source files gekopieerd zonder wijzigingen — geen package:soul_app/ imports aangetroffen
- .g.dart en .freezed.dart bestanden bewust uitgesloten — worden later gegenereerd via build_runner
- ForegroundServiceManager was al correct geconfigureerd met soul_foreground channel ID en serviceId 256

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None

## User Setup Required

None - geen externe service configuratie vereist.

## Next Phase Readiness

- Services layer compleet (112 files), klaar voor plan 06-05 (UI layer)
- CI build groen — main.dart ongewijzigd (BridgeTestScreen importeert geen service files)

---
*Phase: 06-app-merge*
*Completed: 2026-03-21*
