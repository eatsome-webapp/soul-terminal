---
phase: 06-app-merge
plan: "06"
subsystem: ui
tags: [flutter, riverpod, objectbox, pigeon, android-manifest, sentry]

requires:
  - phase: 06-05
    provides: flutter_module met volledige SOUL services, Pigeon bridge, providers

provides:
  - main.dart met SOUL init-flow (ObjectBox → API key → OpenClaw → Notifications → ForegroundService → Sentry)
  - UncontrolledProviderScope met ProviderContainer.overrideWithValue(store)
  - SoulBridgeApi implementatie in SoulApp widget
  - AndroidManifest met READ_CONTACTS, READ_CALENDAR, ForegroundService, NotificationListener
affects: [07-bottom-sheet, 08-session-management]

tech-stack:
  added: []
  patterns:
    - "UncontrolledProviderScope pattern: ProviderContainer aangemaakt vóór runApp(), store override before first widget render"
    - "SoulBridgeApi in root SoulApp widget zodat bridge actief is voor hele app lifecycle"

key-files:
  created: []
  modified:
    - flutter_module/lib/main.dart
    - app/src/main/AndroidManifest.xml

key-decisions:
  - "SoulBridgeApi geïmplementeerd in SoulApp (root StatefulWidget) in plaats van aparte BridgeTestScreen — root widget heeft langste lifecycle"
  - "Geen SoulInitWidget nodig: SOUL main.dart init-flow werkt direct in main() vóór runApp()"
  - "CI debug_build.yml groen na push — alle merged code compileert correct"

patterns-established:
  - "Init-volgorde: ObjectBox → ProviderContainer → API key → OpenClaw → Notifications → ForegroundService → route check → SentryConfig.init(runApp)"
  - "ProviderContainer aangemaakt in main() vóór runApp() — UnimplementedError nooit bereikt"

requirements-completed: ["MERG-03", "MERG-04", "MERG-07"]

duration: 9min
completed: 2026-03-21
---

# Phase 06 Plan 06: main.dart herschrijven + AndroidManifest merge Summary

**SOUL init-flow (ObjectBox → ProviderContainer → API key → OpenClaw → Notifications → ForegroundService → Sentry) als UncontrolledProviderScope root, SoulBridgeApi in SoulApp, AndroidManifest met SOUL permissions en services — CI groen**

## Performance

- **Duration:** 9 min
- **Started:** 2026-03-21T06:01:01Z
- **Completed:** 2026-03-21T06:10:12Z
- **Tasks:** 4 (+ 1 runtime verificatie)
- **Files modified:** 2

## Accomplishments
- main.dart volledig herschreven: BridgeTestScreen verwijderd, exacte SOUL init-volgorde geïmplementeerd
- UncontrolledProviderScope met ProviderContainer.overrideWithValue(objectBoxStoreProvider) — store aangemaakt vóór runApp()
- SoulBridgeApi geïmplementeerd in SoulApp (setUp in initState, null in dispose)
- AndroidManifest: READ_CONTACTS + READ_CALENDAR permissions + ForegroundService + NotificationListener service
- CI debug_build.yml GROEN — APK artifact geproduceerd

## Task Commits

1. **Task 06.1 + 06.2: main.dart herschrijven** - `7ac6acb7` (feat)
2. **Task 06.3: AndroidManifest merge** - `047fa336` (feat)
3. Task 06.4: CI verificatie — groen, geen extra commit
4. Task 06.5: Runtime verificatie (API key persistentie) — handmatig op device

## Files Created/Modified
- `flutter_module/lib/main.dart` - Volledig herschreven met SOUL init-flow, UncontrolledProviderScope, SoulBridgeApi
- `app/src/main/AndroidManifest.xml` - READ_CONTACTS, READ_CALENDAR, ForegroundService, NotificationListener toegevoegd

## Decisions Made
- SoulBridgeApi in `SoulApp` root widget (niet in BridgeTestScreen of aparte widget) — root heeft langste lifecycle en is altijd actief
- Geen aparte `SoulInitWidget` nodig: init flow werkt puur in `main()` vóór runApp(), simpeler dan de plan-instructie suggereerde
- CI was al gepushed door eerdere automatische push — build was groen

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Taak 06.1 en 06.2 gecombineerd in één commit**
- **Found during:** Task 06.1 implementatie
- **Issue:** Taak 06.2 (objectBoxStoreProvider override) is exact dezelfde code als onderdeel van taak 06.1 — beide beschrijven hetzelfde patroon
- **Fix:** Gecombineerd in één commit, beide acceptance criteria in één keer voldaan
- **Files modified:** flutter_module/lib/main.dart
- **Verification:** Beide acceptance criteria sets gepasseerd
- **Committed in:** 7ac6acb7

**2. [Rule 3 - Blocking] SoulInitWidget niet geïmplementeerd (vereenvoudigd)**
- **Found during:** Task 06.1 implementatie
- **Issue:** Plan suggereerde een SoulInitWidget als loading screen. SOUL main.dart heeft dit echter NIET — init draait synchroon in main() vóór runApp(). Toevoegen zou complexiteit toevoegen zonder voordeel.
- **Fix:** Directe SOUL init-flow aangehouden (KRITIEK instructie in plan: "kopieer de exacte init-flow")
- **Files modified:** flutter_module/lib/main.dart
- **Verification:** Acceptatie criteria alle aanwezig, CI groen
- **Committed in:** 7ac6acb7

---

**Total deviations:** 2 (1 samenvoeging, 1 vereenvoudiging)
**Impact on plan:** Vereenvoudiging is correcter — de SOUL main.dart heeft geen SoulInitWidget. Plan criteria zijn allemaal voldaan.

## Issues Encountered
- cmd-proxy pad: proot-distro heeft absolute paden nodig (niet `/home/jelle/...` maar `/data/data/com.termux/...`)
- dart analyze meldt 94 info/warnings (geen errors) — pre-existente issues in de codebase

## User Setup Required
None - geen externe service configuratie nodig. CI draait automatisch.

## Next Phase Readiness
- main.dart met volledige SOUL init-flow gereed
- AndroidManifest met alle benodigde permissions en services
- CI groen — APK artifact beschikbaar
- Runtime verificatie API key persistentie (taak 06.5) kan na APK-installatie op device

---
*Phase: 06-app-merge*
*Completed: 2026-03-21*
