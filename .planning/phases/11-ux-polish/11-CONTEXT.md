# Phase 11: UX Polish - Context

**Gathered:** 2026-03-21
**Status:** Ready for planning

<domain>
## Phase Boundary

Finale polish voor open source lancering. Parallel-safe — raakt geen gedeelde architectuur van andere fasen. Bevat: interactieve terminal output (path long-press, y/n prompt interception), sheet physics (velocity-based expand), visuele effecten (blur), haptic feedback, landscape layout, en accessibility (content descriptions + TalkBack).

</domain>

<decisions>
## Implementation Decisions

### Path detection & interaction (UXPL-01)
- Long-press op terminal output detecteert bestandspaden via regex op `getWordAtLocation()` resultaat
- Ondersteunde formaten: absolute (`/path/to/file`), relative (`./path`), home-relative (`~/path`)
- Context menu met "Kopieer pad" en "Open" opties (AlertDialog of PopupMenu)
- "Open" optie alleen beschikbaar als pad bestaat op het device (file existence check)
- Niet-bestaande paden: alleen "Kopieer pad" optie
- Integreert in bestaand `onLongPress()` in TermuxTerminalViewClient (momenteel returns false)

### Y/N prompt interception (UXPL-02)
- Regex detectie op terminal output voor Claude Code prompts: `[y/N]`, `[Y/n]`, `(yes/no)` patronen aan einde van regel
- Native Android AlertDialog met vraag-tekst als message, Yes/No knoppen
- Dialog verschijnt automatisch wanneer prompt gedetecteerd — geen user actie nodig om te triggeren
- Antwoord wordt als `y\n` of `n\n` naar terminal gestuurd via sendInput na dialog dismiss
- Alleen actief voor interactieve prompts — niet voor output dat toevallig y/n bevat (context-aware regex)

### Sheet physics (UXPL-03)
- Velocity threshold: 1500 dp/s voor auto-expand (standaard Material fling drempel)
- Fling omhoog boven threshold vanuit elke niet-expanded state → altijd full screen
- Fling omlaag boven threshold → collapse naar peek state
- Material standard decelerate interpolator voor animatie
- Integreert in bestaande BottomSheetCallback in TermuxActivity

### Visual effects — blur (UXPL-04)
- `RenderEffect.createBlurEffect()` op flutter_container (SOUL chat view achter sheet)
- Lichte blur: radius 10px — SOUL chat subtiel zichtbaar
- Progressief: blur intensiteit schaalt mee met sheet slide offset (0 bij peek, max bij expanded)
- API < 31 fallback: semi-transparante donkere scrim (`#80000000`) over flutter_container
- Blur wordt berekend in `onSlide()` callback van BottomSheetBehavior

### Haptic feedback (UXPL-05)
- Events die haptics triggeren: sheet state changes (expand/collapse/peek), tab switch, long-press op pad
- Subtiele intensiteit: `VibrationEffect.EFFECT_TICK` voor sheet state changes, `EFFECT_CLICK` voor tab switch
- Altijd aan — geen configuratie toggle (subtiel genoeg om niet te storen)
- `VibrationEffect` API 26+ (min SDK is al ≥26), `performHapticFeedback` als universele fallback
- Integreert in bestaande `onStateChanged()` callback en tab selection listener

### Landscape layout (UXPL-06)
- SOUL chat 60% links, terminal 40% rechts als side panel (geen bottom sheet in landscape)
- Automatische transitie via `onConfigurationChanged()` — configChanges handelt orientation
- Vaste 60/40 split — niet resizable in v1.1
- Session tab bar bovenaan terminal side panel, zelfde positie als portrait
- Aparte `res/layout-land/activity_termux.xml` met horizontale LinearLayout of ConstraintLayout
- TerminalView.updateSize() wordt aangeroepen bij orientation change

### Accessibility (UXPL-07)
- Content descriptions op alle interactieve elementen: sheet drag handle ("Terminal openen"), tabs (sessienaam), + knop ("Nieuwe sessie"), settings knop, terminal view ("Terminal output")
- TalkBack announcements: sheet state changes, sessie switches, y/n prompt dialog verschijning
- Focus volgorde: SOUL chat eerst → sheet handle → tabs → terminal content (natuurlijke volgorde)
- `AccessibilityLiveRegion.POLITE` op terminal view — kondigt nieuwe output aan zonder te onderbreken
- `announceForAccessibility()` bij sheet state transitions en sessie wisselingen

### Claude's Discretion
- Exacte regex patronen voor pad detectie en y/n prompt matching
- Context menu implementatie (PopupMenu vs AlertDialog) voor pad interactie
- Precieze blur radius curve (lineair vs eased) bij sheet slide
- Landscape layout implementatie (LinearLayout vs ConstraintLayout)
- Haptic feedback timing (bij state start of state settle)
- Hoe terminal side panel in landscape visueel gescheiden wordt van SOUL chat
- Welke accessibility strings hardcoded vs in strings.xml

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Terminal view (path detection, haptics)
- `terminal-view/src/main/java/com/termux/view/TerminalView.java` — Touch handling, `getColumnAndRow()` (r559), long-press haptic (r267), NestedScrollingChild3
- `app/src/main/java/com/termux/app/terminal/TermuxTerminalViewClient.java` — `onLongPress()` (r368, returns false), `onSingleTapUp()` URL detection (r184-197), `getWordAtLocation()` usage
- `terminal-view/src/main/java/com/termux/view/GestureAndScaleRecognizer.java` — Gesture detection, long-press support (r54-56)

### Sheet layout (velocity, blur, haptics)
- `app/src/main/java/com/termux/app/TermuxActivity.java` — `setupBottomSheet()` (r684-707), BottomSheetCallback `onStateChanged()`/`onSlide()`, GestureDetector fling (r768-789), velocity thresholds (r769-770)
- `app/src/main/res/layout/activity_termux.xml` — CoordinatorLayout + sheet: drag handle → tab bar → terminal content, flutter_container als achtergrond

### Session tabs (haptics, landscape)
- `app/src/main/java/com/termux/app/TermuxActivity.java` — Tab selection listener, `setupSessionTabBar()`

### Pigeon bridge (y/n prompt response)
- `app/src/main/java/com/termux/bridge/TerminalBridgeImpl.java` — `sendInput()` method voor terminal input
- `app/src/main/java/com/termux/bridge/SoulBridgeController.java` — Output streaming, `onTerminalTextChanged()` — basis voor prompt detectie

### Prior phase decisions
- `.planning/phases/07-bottom-sheet-layout/07-CONTEXT.md` — Sheet states, touch conflict, deferred items (velocity, blur, haptics, landscape) naar Phase 11
- `.planning/phases/08-session-management/08-CONTEXT.md` — Tab bar design, SOUL kleuren
- `.planning/phases/05-terminal-quick-wins/05-CONTEXT.md` — SOUL kleurthema waarden

### Permissions
- `app/src/main/AndroidManifest.xml` — `android.permission.VIBRATE` al gedeclareerd (r29), `configChanges="orientation|screenSize"` op activity

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **getWordAtLocation()**: Bestaande methode in TerminalScreen — levert woord op tap/long-press positie, herbruikbaar voor pad detectie
- **URL detection pattern**: `TermuxUrlUtils.extractUrls()` in onSingleTapUp — zelfde patroon toepasbaar voor paden
- **BottomSheetCallback**: Al geconfigureerd met `onStateChanged()` en `onSlide()` — hooks voor velocity, blur, haptics
- **GestureDetector fling**: Al aanwezig met velocity thresholds (SWIPE_MIN_DISTANCE=120, SWIPE_THRESHOLD_VELOCITY=200) — herbruikbaar patroon
- **HapticFeedbackConstants.LONG_PRESS**: Al in gebruik in TerminalView (r267) — bewezen patroon
- **VIBRATE permission**: Al in AndroidManifest — geen nieuwe permissie nodig
- **Material 1.12.0**: Bevat alle Material components (CoordinatorLayout, BottomSheet, TabLayout)
- **configChanges="orientation"**: Activity handelt orientation changes zelf — geen restart, geschikt voor dynamische layout switch

### Established Patterns
- **Java only**: Alle Android code is Java, geen Kotlin
- **Layout via XML**: Hoofd-layout in activity_termux.xml — landscape variant als res/layout-land/
- **Handler(Looper.getMainLooper()).post{}**: Voor UI updates vanuit achtergrond threads (CP-4)
- **Debounced output**: SoulBridgeController pattern met Handler + postDelayed — herbruikbaar voor prompt detectie

### Integration Points
- **TermuxTerminalViewClient.onLongPress()**: Pad detectie hook (momenteel returns false)
- **BottomSheetCallback.onSlide()**: Blur intensiteit + haptic triggers
- **BottomSheetCallback.onStateChanged()**: Haptic feedback + accessibility announcements
- **SoulBridgeController.onTerminalTextChanged()**: Y/N prompt detectie in output stream
- **onConfigurationChanged()**: Landscape layout switch trigger
- **activity_termux.xml**: Content descriptions toevoegen aan alle views
- **res/layout-land/activity_termux.xml**: Nieuw bestand voor landscape layout

</code_context>

<specifics>
## Specific Ideas

- Velocity-based expand was expliciet deferred vanuit Phase 7 — moet aanvoelen als "snel vegen = altijd full screen"
- Blur moet SOUL chat subtiel zichtbaar houden — geen volledige witte/zwarte overlay
- Haptics moeten subtiel zijn — EFFECT_TICK, niet zware vibratie patronen
- Landscape 60/40 split: beide views tegelijk zichtbaar, geen toggle meer nodig
- Y/N prompt interception specifiek voor Claude Code workflow — de primaire use case van SOUL Terminal
- Path long-press moet werken op zowel absolute paden in compiler errors als relatieve paden in `ls` output

</specifics>

<deferred>
## Deferred Ideas

- Resizable landscape split (user versleept de scheidslijn) — v2
- Customizable haptic intensity/patterns — v2
- Path detection met syntax highlighting — v2
- Multi-line prompt interception (niet alleen y/n) — v2 (AUTO-01)

</deferred>

---

*Phase: 11-ux-polish*
*Context gathered: 2026-03-21*
