---
plan: 11-01
title: "Path detection & long-press interaction"
status: complete
completed: "2026-03-21"
commit: add45363
---

# Summary: Plan 11-01

## What was done

Implemented long-press path detection in `TermuxTerminalViewClient.java`:

- Added `PATH_PATTERN` static regex matching absolute paths (`/...`), relative paths (`./...`, `../...`), and home-relative paths (`~/...`)
- Replaced stub `onLongPress()` (returned false unconditionally) with full implementation:
  - Reads word at tap location via `getWordAtLocation()`
  - Strips trailing `:` / `,` and line:col suffixes (compiler error format)
  - Matches against PATH_PATTERN; falls through to default text selection on no match
  - Resolves `~/` via `System.getenv("HOME")`
  - Fires `performHapticFeedback(LONG_PRESS)` since returning `true` skips TerminalView's own haptic
  - Shows `PopupMenu` with "Kopieer pad" always; "Open" only when `File.exists()`
- `showPathContextMenu()` handles:
  - Copy: writes to ClipboardManager, shows "Pad gekopieerd" toast
  - Open: uses `FileProvider.getUriForFile()` with `FLAG_GRANT_READ_URI_PERMISSION`

## Files modified

- `app/src/main/java/com/termux/app/terminal/TermuxTerminalViewClient.java`

## Requirements delivered

- UXPL-01: Long-press on file paths in terminal output shows context menu
