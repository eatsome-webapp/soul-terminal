---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: — Foundation
status: unknown
last_updated: "2026-03-22T12:58:24.898Z"
progress:
  total_phases: 12
  completed_phases: 10
  total_plans: 46
  completed_plans: 41
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-20)

**Core value:** Een native terminal die naadloos integreert met SOUL — terminal + AI brain in één app.
**Current focus:** Phase 12 — profile-pack-system

## Current Position

Phase: 12 (profile-pack-system) — EXECUTING
Plan: 4 of 6

## v1.1 Phase Overview

| # | Phase | Status | Requirements |
|---|-------|--------|-------------|
| 5 | Terminal Quick Wins | Pending | TERM-04..07 (4) |
| 6 | App Merge | Pending | MERG-01..09 (9) |
| 7 | Bottom Sheet Layout | Pending | LAYT-01..06 (6) |
| 8 | Session Management | Complete | SESS-01..06 (6) |
| 9 | SOUL Terminal Awareness | Pending | AWAR-01..08 (8) |
| 10 | Onboarding Flow | Complete | ONBR-01..07 (7) |
| 11 | UX Polish | Pending | UXPL-01..07 (7) |

## Accumulated Context

### From v1.0

- Pigeon interface nesting: outer class is container, interface genest, setUp() statisch
- android.nonTransitiveRClass=false — bestaande code gebruikt cross-module R class referenties
- android.defaults.buildfeatures.buildconfig=true — AGP 8.x compatibility
- Java 17 alleen in app module
- flutter pub get only (no flutter build aar) — source inclusion via settings.gradle
- ListView + BaseAdapter (niet RecyclerView) — geen androidx.recyclerview dependency
- TermuxSession is com.termux.shared.shell.TermuxSession
- Bootstrap: moderne format (2025+), geen SYMLINKS.txt, arm64-v8a only

### From v1.1 Research

- `windowSoftInputMode="adjustPan"` + `ViewCompat.setOnApplyWindowInsetsListener` voor IME in BottomSheet (CP-1)
- Dedicated `BottomSheetDragHandleView` + `NestedScrollingChild3` in TerminalView voor touch conflict (CP-2)
- HyperOS detectie bij onboarding voor Xiaomi battery/autostart instructies (CP-3)
- `Handler(Looper.getMainLooper()).post{}` wrapper voor Pigeon calls vanuit PTY reader thread (CP-4)
- OSC 133 `\033]133;D\007` voor commando-klaar detectie, configureren via onboarding (CP-5)
- Security: gestructureerde command API (`runCommand(executable, args[])`) vóór AI→terminal live (SM-1)
- AWAR-05 whitelist moet geïmplementeerd zijn vóór AWAR-01/02 live gaan
- `ViewPager2:1.1.0` voor sessie-tabs (vervangt deprecated ViewPager v1)
- `datastore-preferences:1.1.5` voor API key opslag (EncryptedSharedPreferences is deprecated)
- `RenderEffect` blur API 31+ — al beschikbaar in bestaande dependencies
- ProviderScope refactoring (MERG-04) is de zwaarste merge taak
- Pigeon moet ^26.x zijn voor compatibiliteit met drift_dev ^2.31.0 (analyzer constraint conflict)

### From 06-06

- UncontrolledProviderScope pattern: ProviderContainer aangemaakt in main() vóór runApp(), store override vóór eerste widget render
- SoulBridgeApi geïmplementeerd in root SoulApp widget — langste lifecycle, altijd actief
- Init-volgorde: ObjectBox → ProviderContainer → API key → OpenClaw → Notifications → ForegroundService → route check → SentryConfig.init(runApp)

### From 06-07

- EXTRA_DART_DEFINES env var voor dart-defines in add-to-app CI context (niet --dart-define flags)
- NDK build tasks moeten expliciet afhangen van downloadBootstraps (release build volgorde issue)
- Release build signing vereist KEYSTORE_BASE64 secret configuratie in GitHub repo
- Debug CI build GROEN: soul-terminal_v1.0.0+047fa33-soul-terminal-github-debug_arm64-v8a.apk

### From 07-01

- CoordinatorLayout is root van activity_termux.xml (id: activity_termux_root_view — zelfde ID voor minimale downstream impact)
- flutter_container is fullscreen achtergrond (match_parent, altijd visible, geen toggle meer)
- terminal_sheet_container: LinearLayout met BottomSheetBehavior — peekHeight=48dp, halfExpandedRatio=0.4, hideable=true, fitToContents=false
- sheet_drag_handle: 48dp FrameLayout (#0F0F23) + pill View (#6C63FF) als eerste child van sheet
- TermuxActivityRootView klasse bestaat nog als Java file maar is niet meer gerefereerd vanuit TermuxActivity
- setupBottomSheet() in TermuxActivity: sheet init + IME inset listener + OnBackPressedCallback
- getBottomSheetBehavior() public accessor beschikbaar voor Phase 8/9
- onSaveInstanceState slaat "sheet_state" op; onCreate herstelt na process death

### From 07-03

- Back button callback: null-safe `getDrawer()` check + STATE_DRAGGING/SETTLING treated as non-collapsed
- BottomSheetCallback calls `mTerminalView.updateSize()` on all stable states (not DRAGGING/SETTLING) to debounce PTY resize
- TermuxActivityRootView.onGlobalLayout() stubbed — old IME workaround replaced by WindowInsetsCompat on sheet container
- Phase 07 COMPLETE — all 6 LAYT requirements delivered (LAYT-01..06)

### From 07-02

- `NestedScrollingChild3` in TerminalView via `NestedScrollingChildHelper` — alle 15 methoden gedelegeerd
- `startNestedScroll` in `onScroll()` bewaakt door `!scrolledWithFinger` (niet in ACTION_DOWN) — vroegste scroll-hook in GestureAndScaleRecognizer
- TerminalView consumeert eigen scrolls — `startNestedScroll` signaleert alleen BottomSheetBehavior om niet te intercepten
- `windowSoftInputMode="adjustPan"` op TermuxActivity voor correcte IME handling in bottom sheet

### From 08-01

- TabLayout in session_tab_bar_container (36dp) tussen drag handle en terminal content
- TerminalViewClient interface heeft geen onTouchEvent — swipe detector via OnTouchListener op TerminalView
- tabSelectedListener tijdelijk verwijderd tijdens removeAllTabs/addTab rebuild om recursieve switchToSession te voorkomen
- termuxSessionListNotifyUpdated() roept alleen updateSessionTabs() aan — notifyDataSetChanged verwijderd
- Drawer gelocked met LOCK_MODE_LOCKED_CLOSED in setupSessionTabBar() — conflicteert niet met horizontale swipe
- getSessionTabLayout() en getSessionSwipeDetector() accessors beschikbaar voor Phase 8 plan 02/03

### From 08-02

- Long-press op tab via `((ViewGroup) tabLayout.getChildAt(0)).getChildAt(i)` — tab view index na addTab
- Session close via `finishIfRunning()` — onSessionFinished callback handelt removal af (niet directe removal)
- checkAndScrollToSession() volledig gestript — ListView weg, tab bar doet selectie via setCurrentSession()
- settings_tab_button toegevoegd aan session_tab_bar_container — settings altijd bereikbaar ondanks gelocked drawer
- setTermuxSessionsListView() en setNewSessionButtonView() null-safe bewaard voor backward compat

### From 08-03

- Pigeon HostApi: 7 methoden totaal (4 oud + closeSession, switchSession, renameSession)
- Pigeon FlutterApi: 3 methoden totaal (onTerminalOutput, onSessionChanged, onSessionListChanged)
- TerminalBridgeImpl: setActivity(TermuxActivity) setter pattern — geen constructor break
- setupPigeonBridges() nu echte implementatie: registreert HostApi, slaat SoulBridgeApi op als mSoulBridgeApi
- termuxSessionListNotifyUpdated() vuurt onSessionListChanged af — centrale hook voor alle sessiewijzigingen
- Pigeon code handmatig gegenereerd (cmd-proxy token unavailable) — exact v22.7.0 patroon gevolgd
- Phase 08 COMPLETE — alle 6 SESS requirements (SESS-01..06) geleverd

### From 10-02

- sendInput + echo marker polling voor terminal completion vóór OSC 133 (wizard install fase): `sendInput('cmd && echo SOUL_PKG_DONE')` + `_waitForMarker('SOUL_PKG_DONE')`
- outputStream.listen subscription aangemaakt in startInstallation, gecancelled in finally
- apiKeyNotifierProvider.notifier.setKey() direct na validateAndSaveKey — app ziet key zonder restart
- proceedFromInstall() als public accessor voor _advanceToNextStep() na installSuccess

### From 10-03

- writeShellConfig(): aparte bash (PROMPT_COMMAND) en zsh (precmd) OSC 133 configs via Pigeon — com.soul.terminal home path
- Shell config failure is non-fatal: shellConfigDone=true ook bij fout, log in installLog
- _persistCompletion() private methode, async aangeroepen vanuit _advanceToNextStep voor state update naar complete
- completeSetup() is public no-op — persistence al gedaan vóór complete screen rendert
- _advanceToNextStep() refactored naar switch statement — deterministische overgangen, geen loop-met-skip
- selectProfile() roept nu _advanceToNextStep() aan ipv inline step toewijzing
- Phase 10 COMPLETE — alle 7 ONBR requirements (ONBR-01..07) geleverd

### From 10-01

- writeShellConfig: Java FileOutputStream(file, true) append mode — geen shell escaping nodig voor OSC 133 escape sequences
- Setup wizard .g.dart handmatig gegenereerd (cmd-proxy niet beschikbaar) — exact patroon van soul_awareness_service.g.dart gevolgd
- terminalOnly skip logic: _advanceToNextStep() itereert stappen centraal, slaat `installing` over voor terminalOnly profiel
- Xiaomi detectie via SystemBridgeApi().getDeviceInfo() in build() — async zonder blocking, sets isXiaomi flag

### From 11-02

- PromptInterceptor: 200ms debounce + mPromptDialogShowing guard — voorkomt dubbele dialogs bij snel scrollen
- ANSI escape stripping vóór regex match op laatste non-empty transcript regel
- AlertDialog "Ja"/"Nee" schrijft `y\n`/`n\n` via session.write() — slaat STATE_HIDDEN sheet check over
- getPromptInterceptor() public accessor in TermuxActivity, teardown() in onDestroy()

### From 11-04

- onConfigurationChanged re-inflate pattern: setContentView → rebindViewsAfterLayoutChange → conditional setupBottomSheet → setupSessionTabBar → re-attach Flutter
- mSheetBackCallback stored as field + .remove() before re-registering — prevents duplicate back callbacks on portrait restore
- landscape layout: horizontal LinearLayout, flutter 60% / terminal 40%, no BottomSheetBehavior
- isLandscape() public accessor used as guard in setSoulToggleButtonView + applyBlurForOffset
- announceForAccessibility called on mTerminalView (sheet states) and mSessionTabLayout (tab selection)
- Phase 11 COMPLETE — UXPL-01..07 all delivered

### From 11-03

- triggerHaptic(HAPTIC_TICK/HAPTIC_CLICK) public helper: API 29+ predefined effects, 26-28 oneshot, pre-26 performHapticFeedback
- applyBlurEffect @RequiresApi(S) split — roept setRenderEffect aan, los van applyBlurForOffset
- onSlide callback niet meer no-op: roept applyBlurForOffset(slideOffset) aan
- flutter_container blur 0-10px (API 31+) / dark scrim #00-#80000000 (pre-31) als sheet opent
- GestureDetector op sheet_drag_handle: fling >1500dp/s snapped naar STATE_EXPANDED/COLLAPSED
- OnTouchListener return false — BottomSheetBehavior blijft drag events ontvangen
- UXPL-03, UXPL-04, UXPL-05 geleverd

### From 12-02

- ProfileEntry.compareVersions(): YYYY.MM.DD-rN format — string compare voor datum, int.tryParse voor revisie (r10 > r2)
- readInstalledVersionFromFile() statisch + puur File I/O — geen Pigeon bridge, veilig in background isolate
- Manifest cache: `/data/data/com.soul.terminal/cache/profile-packs/manifest-cache.json`
- checkForUpdates() slaat profileId over als localVersion == null (niet geïnstalleerd)

### From 12-01

- Profile pack build: timestamp marker → apt-get install → delta capture (newer than marker) → zip met SYMLINKS.txt → metadata.json sidecar
- metadata.json sidecar pattern: build script schrijft sha256/size/filename, workflow leest via jq — geen fragiele stdout parsing
- profile_pack_build.yml: QEMU aarch64 via docker/setup-qemu-action@v3, bootstrap downloaden via gh release download, softprops/action-gh-release@v2
- manifest.json schemaVersion 2: manifestUrl (top-level), maintainer + repository per profile voor community profiles
- ProfileManifest.manifestUrl field; ProfileEntry.maintainer + repository met optional defaults ('') — backward compatible met v1

### From 12-04

- _installViaProfilePack: Stopwatch start na manifest fetch, log pack name + version vóór download, elapsed seconds op completion
- _installViaPkg: pkg update -y vóór pkg install, [N/M] step counters, time estimates, timeout 10min per stap (was 5min)
- Fallback catch: twee log regels ("Snelle installatie niet beschikbaar" + "Terugvallen op handmatige installatie via pkg...")
