---
phase: 03-flutter-integration
plan: 03-A
subsystem: infra
tags: [gradle, agp, kotlin, android, build-tools, appcompat]

# Dependency graph
requires:
  - phase: 02-bootstrap-pipeline
    provides: fork repo met werkende CI baseline
provides:
  - AGP 8.3.2 + Gradle 8.5 build toolchain
  - Kotlin Gradle plugin 1.9.22 (prerequisite voor Flutter embedding)
  - Java 17 source/target compatibility
  - Namespace in alle 4 modules (AGP 8.x vereiste)
  - Theme.Termux + Theme.Termux_Black als AppCompat styles
  - AndroidX appcompat 1.6.1 + fragment 1.6.2 dependencies
affects:
  - 03-B (Flutter module toevoegen)
  - 03-C (TermuxActivity migratie naar FragmentActivity)

# Tech tracking
tech-stack:
  added:
    - AGP 8.3.2
    - Gradle 8.5
    - Kotlin Gradle plugin 1.9.22
    - androidx.appcompat:appcompat:1.6.1
    - androidx.fragment:fragment:1.6.2
  patterns:
    - namespace in android {} block in plaats van package in AndroidManifest
    - lint {} block in plaats van lintOptions {}
    - packaging {} block in plaats van packagingOptions {}

key-files:
  created: []
  modified:
    - gradle/wrapper/gradle-wrapper.properties
    - build.gradle
    - app/build.gradle
    - termux-shared/build.gradle
    - terminal-emulator/build.gradle
    - terminal-view/build.gradle
    - app/src/main/res/values/styles.xml
    - app/src/main/AndroidManifest.xml
    - gradle.properties

key-decisions:
  - "android.nonTransitiveRClass=false — bestaande code gebruikt com.termux.R cross-module, true zou alle imports breken"
  - "android.defaults.buildfeatures.buildconfig=true — AGP 8.x disabled BuildConfig generatie standaard"
  - "Java 17 op alle modules voor AGP 8.x + Kotlin plugin compatibility"
  - "package attribuut verwijderd uit app AndroidManifest.xml — namespace in build.gradle is nu de bron"

patterns-established:
  - "Alle submodules hebben namespace in android {} block"
  - "AppCompat styles voor TermuxActivity (dot-notatie in XML = underscore in R.style Java)"

requirements-completed: []

# Metrics
duration: 20min
completed: 2026-03-19
---

# Plan 03-A: Gradle/AGP Upgrade + Kotlin Plugin — Summary

**AGP upgrade van 4.2.2 naar 8.3.2 met Gradle 8.5, Kotlin plugin, Java 17, namespace migratie, en AppCompat theme definitie als fundament voor Flutter embedding**

## Performance

- **Duration:** 20 min
- **Started:** 2026-03-19T10:00:00Z
- **Completed:** 2026-03-19T10:20:00Z
- **Tasks:** 10
- **Files modified:** 9

## Accomplishments
- AGP 4.2.2 → 8.3.2 + Gradle 7.2 → 8.5 upgrade compleet
- Kotlin Gradle plugin 1.9.22 toegevoegd (vereist voor Flutter embedding)
- Java 17 source/target compatibility op app module
- Namespace property in alle 4 Android modules (AGP 8.x requirement)
- Deprecated DSL gemigreerd: lintOptions → lint, packagingOptions → packaging
- Theme.Termux + Theme.Termux_Black gedefinieerd als AppCompat.NoActionBar descendants
- AndroidX appcompat + fragment dependencies toegevoegd

## Task Commits

Elke taak atomair gecommit:

1. **03-A-01: Gradle wrapper naar 8.5** - `9fa95e5` (build)
2. **03-A-02: AGP 8.3.2 + Kotlin plugin root** - `494dfa2` (build)
3. **03-A-03: Kotlin Android plugin app** - `a0dc147` (build)
4. **03-A-04: Java 17 compatibility** - `256f68e` (build)
5. **03-A-05: lintOptions → lint** - `2e7d9bb` (build)
6. **03-A-06: packagingOptions → packaging** - `3bc581b` (build)
7. **03-A-07: namespace alle modules + AndroidManifest** - `8b470d5` (build)
8. **03-A-08: Theme.Termux + Theme.Termux_Black** - `13d6e91` (feat)
9. **03-A-09: AndroidX appcompat + fragment deps** - `1b9f288` (build)
10. **03-A-10: gradle.properties AGP 8.x properties** - `afd8220` (build)

## Files Created/Modified
- `gradle/wrapper/gradle-wrapper.properties` — gradle-7.2 → gradle-8.5
- `build.gradle` — AGP 4.2.2 → 8.3.2, Kotlin plugin 1.9.22 toegevoegd
- `app/build.gradle` — Kotlin plugin, Java 17, lint/packaging migratie, namespace, appcompat/fragment deps
- `termux-shared/build.gradle` — namespace "com.termux.shared"
- `terminal-emulator/build.gradle` — namespace "com.termux.terminal"
- `terminal-view/build.gradle` — namespace "com.termux.view"
- `app/src/main/AndroidManifest.xml` — package attribuut verwijderd
- `app/src/main/res/values/styles.xml` — Theme.Termux + Theme.Termux_Black toegevoegd
- `gradle.properties` — nonTransitiveRClass=false, buildconfig=true

## Decisions Made
- `android.nonTransitiveRClass=false` — bestaande code gebruikt cross-module R class referenties; `true` zou alle imports breken
- `android.defaults.buildfeatures.buildconfig=true` — preserveert BuildConfig generatie (AGP 8.x default off)
- Java 17 alleen in app module gewijzigd — submodules worden in aparte plan(nen) bijgewerkt indien nodig

## Deviations from Plan
None — plan exact uitgevoerd als geschreven.

## Issues Encountered
None.

## User Setup Required
None — geen externe service configuratie vereist.

## Next Phase Readiness
- Build toolchain klaar voor Flutter module integratie (Plan 03-B)
- AppCompat styles aanwezig voor FragmentActivity migratie (Plan 03-C)
- Kotlin plugin aanwezig, geen Kotlin source files nodig voor embedding
- CI zal valideren of AGP 8.3.2 build succeeds

---
*Phase: 03-flutter-integration*
*Completed: 2026-03-19*
