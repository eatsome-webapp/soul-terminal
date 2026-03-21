---
plan: 07-01
title: "CoordinatorLayout refactor + BottomSheet with drag handle"
status: complete
completed: "2026-03-21"
commits:
  - bc3281f0
  - f50bf14c
---

# Summary: Plan 07-01

## Wat gedaan

### Task 07-01-01 — activity_termux.xml refactor (commit bc3281f0)

- Root element vervangen: `TermuxActivityRootView` (LinearLayout subclass) → `CoordinatorLayout`
- `flutter_container` FrameLayout naar fullscreen achtergrond (match_parent, geen visibility toggle)
- Terminal hiërarchie gewrapped in `LinearLayout` met `BottomSheetBehavior`:
  - id: `terminal_sheet_container`
  - peekHeight: 48dp
  - halfExpandedRatio: 0.4
  - hideable: true
  - fitToContents: false
  - skipCollapsed: false
- Drag handle toegevoegd: 48dp FrameLayout (#0F0F23) met 40×4dp pill-indicator (#6C63FF)
- `activity_termux_bottom_space_view` verwijderd (niet meer nodig met adjustPan)
- Drawable `sheet_drag_handle_pill.xml` aangemaakt

### Task 07-01-02 — TermuxActivity.java refactor (commit f50bf14c)

- `TermuxActivityRootView mTermuxActivityRootView` veld verwijderd
- `View mTermuxActivityBottomSpaceView` veld verwijderd
- `boolean mIsFlutterVisible` veld verwijderd
- `BottomSheetBehavior<View> mBottomSheetBehavior` veld toegevoegd
- `setupBottomSheet()` methode toegevoegd:
  - Initialiseert BottomSheetBehavior op STATE_COLLAPSED
  - BottomSheetCallback voor focus-request bij STATE_EXPANDED
  - IME inset listener via ViewCompat.setOnApplyWindowInsetsListener
  - OnBackPressedCallback: expanded/half → collapsed; collapsed → finishActivityIfNotFinishing()
- `addTermuxActivityRootViewGlobalLayoutListener()` / `removeTermuxActivityRootViewGlobalLayoutListener()` verwijderd
- `toggleFlutterView()` en `isFlutterVisible()` verwijderd
- `setSoulToggleButtonView()` aangepast: toggle sheet state (collapsed ↔ half-expanded)
- Command palette item "Toggle Flutter view" → "Toggle terminal sheet"
- Deprecated `onBackPressed()` override verwijderd
- `onSaveInstanceState` uitgebreid met sheet_state persistentie
- Sheet state restore in `onCreate()` na `setupBottomSheet()`

### Task 07-01-03 — TermuxTerminalViewClient.java fix (commit f50bf14c)

- Dead code verwijderd: `mActivity.getTermuxActivityRootView().setIsRootViewLoggingEnabled(...)` op regel 105
- Geen andere referenties naar `toggleFlutterView` of `isFlutterVisible` gevonden

### Task 07-01-04 — getBottomSheetBehavior() accessor (commit f50bf14c)

- `public BottomSheetBehavior<View> getBottomSheetBehavior()` toegevoegd voor Phase 8/9 gebruik

## Beslissingen

- **adjustPan** stond al in AndroidManifest.xml — geen wijziging nodig
- **TermuxActivityRootView** klasse zelf blijft staan (verwijdering in aparte cleanup pass) — gerefereerd vanuit TermuxActivityRootView.java zelf, maar niet meer vanuit TermuxActivity
- **onSaveInstanceState** al aanwezig, uitgebreid (geen override conflict)
- **Command palette cleanup** in 07-01-02 gedaan (plan specificeerde dit voor 07-03-03, maar vroeg verwijderen voorkomt compilatiefout)

## CI Status

Push naar GitHub op 2026-03-21. CI-resultaat pending bij afsluiting van dit plan.
