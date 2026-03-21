---
plan: 11-02
title: "Y/N prompt interception"
status: complete
completed_at: "2026-03-21"
commits:
  - 5ae3a2ea  # feat(ux): add PromptInterceptor for y/n dialog detection
  - 33280a6e  # feat(ux): wire PromptInterceptor into TermuxActivity
  - 9dc6ebb8  # feat(ux): call PromptInterceptor from onTextChanged
---

# Summary: Plan 11-02 — Y/N prompt interception

## What was done

3 tasks, 3 atomic commits.

### Task 1: PromptInterceptor class
Created `app/src/main/java/com/termux/app/terminal/PromptInterceptor.java`:
- Regex pattern covers `[y/N]`, `[Y/n]`, `[yes/no]`, `(yes/no)`, `[Y/N]`
- ANSI escape code stripping before match
- 200ms debounce via `Handler.postDelayed`
- `mPromptDialogShowing` guard against duplicate dialogs
- Only active when bottom sheet is not `STATE_HIDDEN`
- AlertDialog with "Ja" / "Nee" buttons sending `y\n` / `n\n` via `session.write()`
- TalkBack `announceForAccessibility` on dialog open

### Task 2: TermuxActivity wiring
- Field `mPromptInterceptor` added after `mSoulBridgeController`
- Initialized in `onCreate()` after `setupBottomSheet()`
- Public accessor `getPromptInterceptor()` added
- `teardown()` called in `onDestroy()`

### Task 3: onTextChanged hook
- `PromptInterceptor.checkForPrompt(changedSession)` called in `onTextChanged()` after the `SoulBridgeController` block

## Decisions

- No changes to plan — implementation matched spec exactly
- `Bevestiging vereist` appears twice in PromptInterceptor (announceForAccessibility + setTitle), acceptance criterion said ≥1 which passes

## Files modified

- `app/src/main/java/com/termux/app/terminal/PromptInterceptor.java` (new)
- `app/src/main/java/com/termux/app/TermuxActivity.java`
- `app/src/main/java/com/termux/app/terminal/TermuxTerminalSessionActivityClient.java`
