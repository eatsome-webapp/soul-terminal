# Phase 1: Foundation - Context

**Gathered:** 2026-03-19
**Status:** Ready for planning

<domain>
## Phase Boundary

Werkende SOUL Terminal APK met correcte branding (package name, app naam, icoon, theming), sharedUserId verwijderd, targetSdk verhoogd, en geautomatiseerde CI/CD pipeline via GitHub Actions. Terminal functioneel identiek aan Termux — geen feature toevoegingen in deze fase.

</domain>

<decisions>
## Implementation Decisions

### sharedUserId
- Verwijderen uit AndroidManifest.xml — geen plugin compatibiliteit nodig
- Voorkomt signing key lock-in (pitfall P4 uit research)
- SOUL Terminal is self-contained, geen Termux plugin apps

### Namespace strategie
- Java namespace `com.termux` en `com.termux.shared` BEHOUDEN — niet wijzigen
- Alleen `applicationId` wijzigen naar `com.soul.terminal` in app/build.gradle
- `namespace` in build.gradle bestanden NIET wijzigen (voorkomt duizenden compile errors — pitfall M2)
- manifestPlaceholders wijzigen: TERMUX_PACKAGE_NAME → `com.soul.terminal`, TERMUX_APP_NAME → `SOUL Terminal`

### SDK versies
- targetSdk verhogen van 28 naar 34 (Play Store vereiste)
- minSdk verhogen van 21 naar 24 (vereenvoudigt desugaring, verliest <1% devices)
- desugar_jdk_libs upgraden naar 2.1.3

### Versioning
- Eigen versioning: versionName `1.0.0`, versionCode `1`
- Clean break van Termux versioning (was 0.118.0 / code 118)
- Eigen release cycle onafhankelijk van upstream

### Rebranding scope
- TermuxConstants.java: TERMUX_APP_NAME → "SOUL Terminal", TERMUX_PACKAGE_NAME → "com.soul.terminal"
- app/build.gradle: manifestPlaceholders aanpassen
- strings.xml: XML entities wijzigen (2 regels)
- Launcher icons: alle mipmap densities vervangen met SOUL Terminal icoon
- APK output naam: `termux-app_` → `soul-terminal_`
- UI theming: kleuren aanpassen aan SOUL branding

### CI/CD
- debug_build.yml aanpassen voor SOUL Terminal (APK namen, triggers)
- Release signing workflow toevoegen met keystore via GitHub Secrets
- Debug keystore (testkey_untrusted.jks) behouden voor development builds
- Bootstrap download laten zoals het is (Termux repos) — eigen bootstrap is Phase 2

### Claude's Discretion
- Exacte SOUL Terminal kleurschema (kan later verfijnd worden)
- Adaptive icon XML ontwerp
- Workflow trigger branches

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Rebranding instructies
- `termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java` regels 294-323 — Inline commentaar documenteert exact welke bestanden bij package rename moeten wijzigen
- `.planning/research/PITFALLS.md` — Pitfalls P4 (sharedUserId), M2 (namespace vs applicationId), en preventiestrategieen

### Build configuratie
- `app/build.gradle` — applicationId, namespace, manifestPlaceholders, signing config, APK output namen
- `termux-shared/build.gradle` — namespace, maven publication config
- `.planning/research/STACK.md` — SDK versie aanbevelingen, dependency upgrades

### CI/CD
- `.github/workflows/debug_build.yml` — Bestaande build workflow (aanpassen, niet vervangen)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `debug_build.yml`: Werkende CI/CD workflow — aanpassen voor SOUL Terminal
- `testkey_untrusted.jks`: Debug signing keystore — behouden voor dev builds
- XML entities in strings.xml: Slechts 2 regels aanpassen dekt alle string references

### Established Patterns
- manifestPlaceholders in build.gradle sturen AndroidManifest.xml waarden aan — sharedUserId, package name, app name
- TermuxConstants.java is de single source of truth voor package name en app name — alle andere code refereert hieraan
- Adaptive icons (anydpi-v26) + raster fallbacks (hdpi t/m xxxhdpi)

### Integration Points
- `TermuxConstants.java` lijn 352: TERMUX_PACKAGE_NAME — wijziging propageert automatisch naar alle afgeleide paden
- `app/build.gradle` lijn 54-55: manifestPlaceholders — wijziging propageert naar AndroidManifest.xml
- `strings.xml` entities: wijziging propageert naar alle strings die &TERMUX_APP_NAME; gebruiken

</code_context>

<specifics>
## Specific Ideas

- APK moet naast bestaande Termux installeerbaar zijn (ander applicationId = ander app)
- Na rebranding moet terminal 100% functioneel identiek zijn aan Termux
- Bootstrap download mag tijdelijk nog van Termux repos komen — eigen bootstrap is Phase 2

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 01-foundation*
*Context gathered: 2026-03-19*
