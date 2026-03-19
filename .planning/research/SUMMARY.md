# Research Summary: SOUL Terminal

*Synthesized: 2026-03-19*

---

## Key Findings

1. **Forking Termux is the right call** — ~15 core terminal features are inherited for free (shell, tabs, SSH, foreground service, clipboard, extra keys, colors). Building from scratch would cost months. The strategic risk is keeping upstream merge compatibility.

2. **Bootstrap pipeline is the hardest problem** — Every Termux binary has `/data/data/com.termux/` hardcoded. All packages must be recompiled for `com.soul.terminal`. This requires a full `termux-packages` fork, Docker-based cross-compilation, a custom apt repository, and SHA-256 checksum updates in `app/build.gradle`. It is the largest single effort in the project.

3. **Flutter embedding is mature but has known traps** — FlutterFragment + FlutterEngineCache is the correct pattern. Three critical gotchas: plugins are not auto-registered (must call `GeneratedPluginRegistrant.registerWith(engine)` manually), engines leak if created per-fragment (use singleton cache), and pre-warming in `Application.onCreate()` is required to avoid terminal startup delay.

4. **Rebranding must be surgical** — Change exactly three files: `TermuxConstants.java` (line 352), `app/build.gradle` (applicationId + manifestPlaceholders), and `strings.xml` (XML entity). Do NOT rename Java namespaces — keep `com.termux.*` internally to avoid thousands of compilation errors. Changing namespace and applicationId independently is intentional.

5. **Pigeon is the correct bridge** — Type-safe, generated code for both sides. Replaces manual MethodChannel and eventually replaces cmd-proxy for Claude Code communication. Design the interface contract (TerminalBridge, SoulBridge, SystemBridge) before writing any platform channel code.

6. **targetSdk must be raised to 34** — Current is 28, Play Store requires 34+. Termux upstream stays at 28 intentionally to avoid scoped storage restrictions, but SOUL Terminal needs Play Store distribution. Also upgrade `desugar_jdk_libs` to 2.1.3.

7. **Terminal output streaming needs rate-limiting** — `TerminalSessionClient.onTextChanged()` fires on every screen update. Direct Pigeon passthrough floods the bridge. Debounce to max 10 updates/sec; host pushes diffs, Flutter does not poll.

---

## Recommended Stack

| Layer | Choice | Notes |
|-------|--------|-------|
| Build | AGP 8.13.2 + Gradle 9.2.1 | Keep — AGP 9.x not yet stable with Flutter add-to-app |
| Target API | 34 (raise from 28) | Play Store requirement |
| Min API | 24 (raise from 21) | Simplifies desugaring; drops <1% device share |
| Flutter embedding | FlutterFragment + FlutterEngineCache | Industry standard, single engine singleton |
| Bridge | Pigeon 26.2.x | Type-safe, generated, bidirectional |
| Host language | Java (keep) | Kotlin adds build complexity, upstream merge risk |
| Flutter state | Riverpod + @riverpod codegen | Consistent with SOUL app |
| Key upgrades | `desugar_jdk_libs` 2.1.3, `androidx.core` 1.18.0 | High priority |
| CI | GitHub Actions — two-stage build | Flutter AAR first, then `./gradlew assembleRelease` |

---

## Table Stakes vs Differentiators

### Table Stakes (inherited free from Termux)
Shell, package manager, multiple sessions, persistent sessions, copy/paste, extra keys row, configurable fonts, true color, Unicode, SSH, foreground service, storage access, URL detection, share text.

### Tier 1 Differentiators (must ship)
- **SOUL AI overlay** (FlutterFragment) — the killer feature, AI in the terminal
- **Pigeon bridge** — terminal output to AI, AI commands to terminal, replaces cmd-proxy
- **Custom branding** — name, icon, theme (already started)
- **Custom bootstrap pipeline** — own packages with `com.soul.terminal` prefix

### Tier 2 Differentiators (competitive edge, parallel track)
- Kitty keyboard protocol — Neovim/Helix require it, Termux lacks it
- OSC9 desktop notifications — low effort, high value
- Command palette — Flutter UI, fuzzy search over commands/history
- Split panes — native, no tmux required
- Session restore

### Tier 3 Differentiators (long-term moat, after Pigeon bridge)
- AI command suggestions, AI error explanation, smart history, context-aware autocomplete

### Anti-features (explicitly not building)
Own terminal emulator library, iOS, plugin APKs, GUI file manager, built-in IDE, multi-device sync, root-only features, AccessibilityService, persona selector UI.

---

## Architecture

Five components with clean boundaries:

| Component | Language | Role | Coupling |
|-----------|----------|------|---------|
| `terminal-emulator/` | Java | Pure terminal emulation (VT, ANSI, PTY) | No Android, no Flutter |
| `terminal-view/` | Java | Android View rendering terminal session | Only knows TerminalSession |
| `termux-shared/` | Java | Constants, paths, settings (rebranding pivot point) | Cross-module glue |
| `app/` | Java | TermuxActivity + TermuxService + FlutterFragment host | Orchestrates all |
| Flutter module | Dart | SOUL AI brain, chat UI, memory layer | Talks only via Pigeon |

**Integration:** FlutterFragment lives inside TermuxActivity. A layout toggle switches between terminal-fullscreen, Flutter-fullscreen, or split view. One `FlutterEngine` singleton, pre-warmed in `Application.onCreate()`.

**Pigeon interfaces:**
- `TerminalBridge` (Flutter → Host): executeCommand, readTerminalBuffer, createSession, sendInput
- `SoulBridge` (Host → Flutter): onTerminalOutput, onSessionChanged, onAppLifecycleChanged
- `SystemBridge` (Flutter → Host): readContacts, readCalendar, showNotification, getDeviceInfo

**For TermuxService access:** Start with Flutter → Pigeon → Activity → Service binding. Migrate to direct Service binding only when background processing is needed.

---

## Critical Pitfalls

| ID | Pitfall | Phase | Impact |
|----|---------|-------|--------|
| P1 | Bootstrap binaries have `/data/data/com.termux` hardcoded — must recompile ALL packages | Bootstrap | Catastrophic if ignored |
| P2 | FlutterFragment does not auto-register plugins — call `GeneratedPluginRegistrant.registerWith(engine)` manually | Flutter embedding | All plugin calls fail silently |
| P3 | New FlutterEngine per fragment = memory leak (issues #168658, #36898) — use singleton cache | Flutter embedding | OOM crashes |
| P4 | `sharedUserId` locks signing key forever — decide before first public APK, consider removing it | Rebranding | Can never recover without data loss |
| M2 | Changing Java `namespace` ≠ changing `applicationId` — change only applicationId, keep `com.termux.*` namespaces | Rebranding | Thousands of compile errors if done wrong |
| B1 | `build-bootstraps.sh` on master is broken — use `infra-improvs` branch | Bootstrap | Silent build failures |
| B3 | Bootstrap checksums hardcoded in `app/build.gradle` — must update after every rebuild | Bootstrap | Gradle build fails |
| B5 | Custom packages require own apt repository — Termux's repo won't serve `com.soul.terminal` binaries | Bootstrap | `pkg install` broken for users |

---

## Build Order Recommendation

```
Phase 1: Rebranding (days)
  Change TermuxConstants.java L352, app/build.gradle applicationId,
  strings.xml entity, sharedUserId decision, signing key strategy.
  Output: working SOUL Terminal APK identical to Termux functionally.

Phase 2: CI/CD Pipeline (days, parallel with Phase 1)
  GitHub Actions workflows: debug APK build, release signing via secrets.
  Separate workflow for bootstrap builds (rare) vs app builds (frequent).
  Output: automated APK builds on push.

Phase 3: Bootstrap Pipeline (weeks — largest effort)
  Fork termux-packages, change properties.sh prefix, build aarch64 packages
  using run-docker.sh + infra-improvs branch, update checksums, set up apt repo.
  Output: SOUL Terminal installs own packages with com.soul.terminal prefix.

Phase 4: Flutter Module Skeleton (1 week)
  flutter create --template module, settings.gradle source dependency,
  FlutterEngine pre-warm in TermuxApplication, empty FlutterFragment in TermuxActivity,
  toggle button, GeneratedPluginRegistrant call.
  Output: Flutter placeholder UI visible alongside terminal.

Phase 5: Pigeon Bridge (1-2 weeks)
  Define pigeons/soul_api.dart schema, generate Java/Dart code,
  implement TerminalBridge (Java host), SoulBridge (Flutter), debounced output streaming.
  Output: Flutter can execute commands and receive terminal output.

Phase 6: SOUL Brain Integration (weeks)
  Migrate claude_service, soul_brain, memory layer into Flutter module.
  Chat UI, Claude API, Drift + ObjectBox.
  Output: full SOUL AI interface inside the terminal app.

Phase 7: Terminal Enhancements (parallel with 4-6, independent)
  Kitty keyboard protocol, OSC9 notifications, command palette, split panes.
  No Flutter dependency — pure terminal-emulator/terminal-view work.
```

**Critical path:** Rebranding → Bootstrap → Flutter skeleton → Pigeon → SOUL brain.
Phase 3 (Bootstrap) is the longest and blocks nothing else — can be done in parallel with Phases 4-7 if the team (Claude) parallelizes.

---

## Open Questions

| # | Question | Options | Blocker for |
|---|----------|---------|-------------|
| 1 | **sharedUserId**: keep with `com.soul.terminal`, or remove entirely? | Remove (cleaner, no plugin compat needed) vs keep | Phase 1 — must decide before first APK |
| 2 | **targetSdk 34 vs 35**: 34 is minimum, 35 enforces edge-to-edge UI | Start at 34, upgrade to 35 when UI is ready (recommended) | Phase 1 |
| 3 | **minSdk 21 vs 24**: 24 simplifies desugaring but diverges from upstream | 24 recommended (drops <1% devices, enables cleaner desugaring) | Phase 1 |
| 4 | **Flutter module location**: sibling dir (`../soul_flutter_module/`) or subdirectory (`flutter_module/`)? | Subdirectory simpler for mono-repo (recommended) | Phase 4 |
| 5 | **Bootstrap hosting**: GitHub Releases or external CDN for apt repo? | GitHub Releases is free and easy for v1 | Phase 3 |
| 6 | **FlutterEngine pre-warm vs lazy**: pre-warm adds 40MB from start | Pre-warm recommended (Xiaomi 17 Ultra has 16GB RAM) | Phase 4 |
| 7 | **cmd-proxy replacement timeline**: Pigeon bridge eventually replaces it | Pigeon replaces after Phase 5; cmd-proxy stays until then | Phase 5 |
