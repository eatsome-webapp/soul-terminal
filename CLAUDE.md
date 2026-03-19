# SOUL Terminal — Termux Fork

## Project Overview
SOUL Terminal is a fork of termux/termux-app, rebranded and extended to become the terminal layer of the SOUL ecosystem. End goal: embed a Flutter module (SOUL AI brain) directly into the terminal app via FlutterFragment — one APK, one app.

## Tech Stack
- **Base**: Termux (Java/Android) — terminal-emulator, terminal-view, termux-shared
- **Build**: Gradle, Android SDK
- **Future**: Flutter module (add-to-app), Pigeon for Flutter↔Kotlin bridge
- **CI/CD**: GitHub Actions — never build locally
- **Bootstrap**: Custom termux-packages fork with com.soul.terminal prefix

## Development Environment
- Same as parent SOUL project (Xiaomi 17 Ultra, Termux, Claude Code in proot)
- This is an Android/Java/Gradle project, NOT Flutter (yet)
- GitHub Actions for APK builds

## Directory Structure
```
app/                    # Main Android app module
terminal-emulator/      # Terminal emulation library
terminal-view/          # Terminal rendering (View)
termux-shared/          # Shared constants, utils, settings
.planning/              # GSD project management
.github/workflows/      # CI/CD
```

## Key Files for Rebranding
- `termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java` — package name, app name, paths
- `app/build.gradle` — namespace, manifestPlaceholders
- `app/src/main/res/values/strings.xml` — app display name
- `termux-shared/build.gradle` — namespace

## Never Do
- Never run gradle/builds locally — always GitHub Actions
- Never change terminal-emulator internals unless absolutely necessary (upstream merge risk)
- Never use com.termux package name — always com.soul.terminal
- Never break Termux plugin compatibility without explicit decision

## Important Context
- 31 todos in `.planning/todos/pending/` covering rebranding, bootstrap, Flutter module, terminal features
- Bootstrap pipeline requires a fork of termux/termux-packages with modified properties.sh
- Flutter module embedding uses add-to-app pattern (FlutterFragment), NOT PlatformView
- Pigeon bridge will eventually replace cmd-proxy for Claude Code ↔ proot-distro communication
