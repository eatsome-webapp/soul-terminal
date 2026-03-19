---
phase: 4
plan: A
title: "Kitty Keyboard Protocol (Modes 1+2)"
wave: 1
depends_on: []
autonomous: true
requirements: [TERM-01]
files_modified:
  - terminal-emulator/src/main/java/com/termux/terminal/TerminalEmulator.java
  - terminal-emulator/src/main/java/com/termux/terminal/KeyHandler.java
  - terminal-view/src/main/java/com/termux/view/TerminalView.java
---

# Plan 04-A: Kitty Keyboard Protocol (Modes 1+2)

<objective>
Implement Kitty keyboard protocol modes 1 (disambiguate escape codes) and 2 (report event types) in the terminal emulator, so that applications like Neovim and Helix can detect and activate the protocol via standard CSI queries, and modifier keys are correctly reported using the Kitty CSI u encoding format.
</objective>

<tasks>

<task id="04-A-01">
<title>Add Kitty mode state and CSI = u / CSI ? u / CSI > u handlers to TerminalEmulator</title>
<read_first>
- terminal-emulator/src/main/java/com/termux/terminal/TerminalEmulator.java
</read_first>
<action>
In `TerminalEmulator.java`:

1. Add a new ESC state constant after `ESC_CSI_EXCLAMATION` (line 81):
   ```java
   private static final int ESC_CSI_EQUALS = 20;
   ```

2. Add a new instance variable after `mCursorStyle` (around line 155):
   ```java
   /** Kitty keyboard protocol mode flags. Bit 0 = disambiguate (mode 1), bit 1 = report event types (mode 2). */
   private int mKittyKeyboardMode = 0;
   ```

3. Add a public getter after the existing `isCursorKeysApplicationMode()` / `isKeypadApplicationMode()` methods:
   ```java
   /** Returns the current Kitty keyboard protocol mode flags. 0 = disabled. */
   public int getKittyKeyboardMode() {
       return mKittyKeyboardMode;
   }
   ```

4. In the `doCsi(int b)` method, add a new case for `'='` to route to the new state:
   ```java
   case '=':
       continueSequence(ESC_CSI_EQUALS);
       break;
   ```
   This goes after the existing `case '*':` block (around line 1456).

5. In the main `processCodePoint()` switch on `mEscapeState`, add a new case block for `ESC_CSI_EQUALS` (after the `ESC_CSI_ARGS_ASTERIX` block, around line 876):
   ```java
   case ESC_CSI_EQUALS:
       if (b == 'u') {
           // CSI = flags u — set Kitty keyboard mode flags
           int flags = getArg0(0);
           mKittyKeyboardMode = flags & 0x03; // Only support bits 0 and 1 (modes 1+2)
           finishSequence();
       } else {
           parseArg(b);
       }
       break;
   ```

6. In `doCsi(int b)`, modify the existing `case 'u':` (which currently handles `case 't': case 'u':` at line 860-863 inside the `ESC_CSI_ARGS_SPACE` block) — this is NOT the right place. Instead, find the TOP-LEVEL `doCsi` method. The `case 'u'` we need is NOT in `doCsi` currently (the one at line 861 is inside `ESC_CSI_ARGS_SPACE`). We need to ADD a new `case 'u':` in the main `doCsi(int b)` switch:
   ```java
   case 'u':
       // CSI ? u handled via ESC_CSI_QUESTIONMARK, CSI > u handled below
       // CSI u alone: Restore cursor (SC) — already handled elsewhere
       break;
   ```
   Actually, looking at the code flow: `CSI ? u` goes through ESC_CSI_QUESTIONMARK state. Add handling there.

7. In `doCsiQuestionMark(int b)`, add a case for `'u'`:
   ```java
   case 'u':
       // CSI ? u — query Kitty keyboard mode flags
       mSession.write("\033[?" + mKittyKeyboardMode + "u");
       break;
   ```

8. In `doCsiBiggerThan(int b)`, add a case for `'u'`:
   ```java
   case 'u':
       // CSI > u — reset/pop Kitty keyboard mode flags (simplified: just reset to 0)
       mKittyKeyboardMode = 0;
       break;
   ```

9. In `doCsiBiggerThan(int b)`, add a case for `'q'`:
   ```java
   case 'q':
       // CSI > 0 q — XTVERSION query
       if (getArg0(0) == 0) {
           mSession.write("\033P>|SOUL Terminal 1.0\033\\");
       }
       break;
   ```

10. In the `reset()` method, add `mKittyKeyboardMode = 0;` to reset Kitty mode on terminal reset.
</action>
<acceptance_criteria>
- TerminalEmulator.java contains `private static final int ESC_CSI_EQUALS = 20;`
- TerminalEmulator.java contains `private int mKittyKeyboardMode = 0;`
- TerminalEmulator.java contains `public int getKittyKeyboardMode()`
- TerminalEmulator.java contains `mKittyKeyboardMode = flags & 0x03;`
- TerminalEmulator.java contains `mSession.write("\033[?" + mKittyKeyboardMode + "u");`
- TerminalEmulator.java contains `mSession.write("\033P>|SOUL Terminal 1.0\033\\");`
- TerminalEmulator.java contains `case ESC_CSI_EQUALS:`
</acceptance_criteria>
</task>

<task id="04-A-02">
<title>Add Kitty CSI u key encoding method to KeyHandler</title>
<read_first>
- terminal-emulator/src/main/java/com/termux/terminal/KeyHandler.java
</read_first>
<action>
In `KeyHandler.java`, add a new public static method `getKittyCode` after the existing `getCode` method. This method encodes keys using the Kitty keyboard protocol CSI u format.

```java
/**
 * Get Kitty keyboard protocol encoded escape sequence for the given key.
 *
 * @param keyCode  Android KeyEvent keyCode
 * @param keyMode  Bitmask of KEYMOD_SHIFT, KEYMOD_CTRL, KEYMOD_ALT
 * @param eventType 1=press (default), 2=repeat, 3=release
 * @param kittyFlags Current Kitty mode flags (bit 0=disambiguate, bit 1=report events)
 * @return The escape sequence string, or null if this key should fall through to standard handling
 */
public static String getKittyCode(int keyCode, int keyMode, int eventType, int kittyFlags) {
    if (kittyFlags == 0) return null;

    int unicode = mapKeyCodeToKittyNumber(keyCode);
    if (unicode == 0) return null;

    // Calculate Kitty modifier value: shift=1, alt=2, ctrl=4 (then +1 for parameter)
    int kittyMod = 0;
    if ((keyMode & KEYMOD_SHIFT) != 0) kittyMod |= 1;
    if ((keyMode & KEYMOD_ALT) != 0) kittyMod |= 2;
    if ((keyMode & KEYMOD_CTRL) != 0) kittyMod |= 4;
    int modParam = kittyMod + 1; // Kitty spec: modifier parameter = bitmask + 1

    boolean reportEvents = (kittyFlags & 0x02) != 0;

    // Build the CSI sequence
    // Format: CSI unicode-key-code ; modifiers:event-type u
    // If no modifiers and press event, can omit modifier parameter
    // For functional keys that use ~ terminator, use ~ instead of u
    boolean isFunctionalTilde = isTildeKey(keyCode);
    char terminator = isFunctionalTilde ? '~' : 'u';

    StringBuilder sb = new StringBuilder("\033[");
    sb.append(unicode);

    boolean hasModifier = modParam > 1;
    boolean hasEvent = reportEvents && eventType > 1;

    if (hasModifier || hasEvent) {
        sb.append(';');
        sb.append(modParam);
        if (hasEvent) {
            sb.append(':');
            sb.append(eventType);
        }
    }
    sb.append(terminator);

    return sb.toString();
}

/**
 * Map Android keyCode to Kitty keyboard protocol key number.
 * Returns the Unicode codepoint for printable keys, or the Kitty functional key number.
 * Returns 0 if the key is not mapped.
 */
private static int mapKeyCodeToKittyNumber(int keyCode) {
    switch (keyCode) {
        case KEYCODE_ESCAPE: return 27;
        case KEYCODE_ENTER: return 13;
        case KEYCODE_TAB: return 9;
        case KEYCODE_DEL: return 127; // Backspace
        case KEYCODE_INSERT: return 2;
        case KEYCODE_FORWARD_DEL: return 3; // Delete
        case KEYCODE_DPAD_LEFT: return 57419;
        case KEYCODE_DPAD_RIGHT: return 57421;
        case KEYCODE_DPAD_UP: return 57416;
        case KEYCODE_DPAD_DOWN: return 57424;
        case KEYCODE_PAGE_UP: return 57425;
        case KEYCODE_PAGE_DOWN: return 57426;
        case KEYCODE_MOVE_HOME: return 57415;
        case KEYCODE_MOVE_END: return 57423;
        case KEYCODE_F1: return 57364;
        case KEYCODE_F2: return 57365;
        case KEYCODE_F3: return 57366;
        case KEYCODE_F4: return 57367;
        case KEYCODE_F5: return 57368;
        case KEYCODE_F6: return 57369;
        case KEYCODE_F7: return 57370;
        case KEYCODE_F8: return 57371;
        case KEYCODE_F9: return 57372;
        case KEYCODE_F10: return 57373;
        case KEYCODE_F11: return 57374;
        case KEYCODE_F12: return 57375;
        default: return 0;
    }
}

/**
 * Returns true if this keyCode uses the ~ terminator in Kitty protocol (legacy functional keys).
 * In our implementation we use 'u' for all keys for simplicity.
 */
private static boolean isTildeKey(int keyCode) {
    return false; // Use CSI u format for all keys (Kitty spec allows this)
}
```

Also add the missing import at the top of the file:
```java
import static android.view.KeyEvent.KEYCODE_TAB;
import static android.view.KeyEvent.KEYCODE_PAGE_UP;
import static android.view.KeyEvent.KEYCODE_PAGE_DOWN;
```
(Check which of these are already imported and only add the missing ones.)
</action>
<acceptance_criteria>
- KeyHandler.java contains `public static String getKittyCode(int keyCode, int keyMode, int eventType, int kittyFlags)`
- KeyHandler.java contains `private static int mapKeyCodeToKittyNumber(int keyCode)`
- KeyHandler.java contains `case KEYCODE_ESCAPE: return 27;`
- KeyHandler.java contains `case KEYCODE_F1: return 57364;`
- KeyHandler.java contains `int kittyMod = 0;`
- KeyHandler.java contains `sb.append(';');` within getKittyCode method
</acceptance_criteria>
</task>

<task id="04-A-03">
<title>Route key events through Kitty encoder in TerminalView</title>
<read_first>
- terminal-view/src/main/java/com/termux/view/TerminalView.java
</read_first>
<action>
In `TerminalView.java`:

1. Modify `handleKeyCode(int keyCode, int keyMod)` (around line 837) to check for Kitty mode before falling through to the standard `KeyHandler.getCode()`:

   Before the existing line:
   ```java
   String code = KeyHandler.getCode(keyCode, keyMod, term.isCursorKeysApplicationMode(), term.isKeypadApplicationMode());
   ```

   Add:
   ```java
   // Try Kitty keyboard protocol encoding first
   int kittyMode = term.getKittyKeyboardMode();
   if (kittyMode > 0) {
       String kittyCode = KeyHandler.getKittyCode(keyCode, keyMod, 1, kittyMode);
       if (kittyCode != null) {
           mTermSession.write(kittyCode);
           return true;
       }
   }
   ```

2. Modify `onKeyUp(int keyCode, KeyEvent event)` (around line 857) to send release events when Kitty mode 2 is active. After the existing client callback check and before the `super.onKeyUp()` call, add:

   ```java
   // Send Kitty key release event if mode 2 (report event types) is active
   if (mTermSession != null) {
       TerminalEmulator term = mTermSession.getEmulator();
       if (term != null && (term.getKittyKeyboardMode() & 0x02) != 0) {
           int keyMod = 0;
           if (event.isAltPressed()) keyMod |= KeyHandler.KEYMOD_ALT;
           if (event.isShiftPressed()) keyMod |= KeyHandler.KEYMOD_SHIFT;
           if (event.isCtrlPressed()) keyMod |= KeyHandler.KEYMOD_CTRL;
           String kittyCode = KeyHandler.getKittyCode(keyCode, keyMod, 3, term.getKittyKeyboardMode());
           if (kittyCode != null) {
               mTermSession.write(kittyCode);
               return true;
           }
       }
   }
   ```

3. Add needed import if not already present:
   ```java
   import com.termux.terminal.KeyHandler;
   ```
</action>
<acceptance_criteria>
- TerminalView.java contains `term.getKittyKeyboardMode()`
- TerminalView.java contains `KeyHandler.getKittyCode(keyCode, keyMod, 1, kittyMode)`
- TerminalView.java contains `KeyHandler.getKittyCode(keyCode, keyMod, 3, term.getKittyKeyboardMode())`
- TerminalView.java contains `int kittyMode = term.getKittyKeyboardMode();`
</acceptance_criteria>
</task>

<task id="04-A-04">
<title>Add Kitty mode support for printable characters with modifiers</title>
<read_first>
- terminal-emulator/src/main/java/com/termux/terminal/KeyHandler.java
- terminal-view/src/main/java/com/termux/view/TerminalView.java
</read_first>
<action>
In `TerminalView.java`, in the `onKeyDown` method (around line 699), there is handling for printable characters via `getUnicodeChar()`. When Kitty mode 1 is active and a printable character has modifiers (Ctrl, Alt, Shift beyond just producing the character), it should be encoded as `CSI codepoint ; modifiers u`.

Find the section in `onKeyDown` where `event.getUnicodeChar(metaState)` is used and a character is written to the terminal. Before the standard character write path (typically near the end of onKeyDown where `mTermSession.writeCodePoint` is called), add a Kitty encoding check:

In the `onKeyDown` method, after the `handleKeyCode` call block but before the unicode character handling, add:

```java
// Kitty keyboard protocol: encode printable chars with modifiers as CSI codepoint ; mod u
if (mTermSession != null) {
    TerminalEmulator termForKitty = mTermSession.getEmulator();
    if (termForKitty != null && (termForKitty.getKittyKeyboardMode() & 0x01) != 0) {
        int unicodeChar = event.getUnicodeChar(0); // Unmodified character
        if (unicodeChar > 0 && unicodeChar != event.getUnicodeChar(event.getMetaState())) {
            // Character is modified — encode with Kitty protocol
            int keyMod = 0;
            if (event.isAltPressed()) keyMod |= KeyHandler.KEYMOD_ALT;
            if (event.isShiftPressed()) keyMod |= KeyHandler.KEYMOD_SHIFT;
            if (event.isCtrlPressed()) keyMod |= KeyHandler.KEYMOD_CTRL;
            int kittyMod = 0;
            if ((keyMod & KeyHandler.KEYMOD_SHIFT) != 0) kittyMod |= 1;
            if ((keyMod & KeyHandler.KEYMOD_ALT) != 0) kittyMod |= 2;
            if ((keyMod & KeyHandler.KEYMOD_CTRL) != 0) kittyMod |= 4;
            if (kittyMod > 0) {
                String seq = "\033[" + unicodeChar + ";" + (kittyMod + 1) + "u";
                mTermSession.write(seq);
                return true;
            }
        }
    }
}
```

Place this before the existing code that writes printable characters. The exact location depends on the current code structure — it must be after the `handleKeyCode` check returns false and before the fallthrough to `writeCodePoint`.
</action>
<acceptance_criteria>
- TerminalView.java contains `"\033[" + unicodeChar + ";" + (kittyMod + 1) + "u"`
- TerminalView.java contains `termForKitty.getKittyKeyboardMode()`
- TerminalView.java contains `event.getUnicodeChar(0)` in the Kitty encoding block
</acceptance_criteria>
</task>

</tasks>

<verification>
1. Build the app via GitHub Actions — `./gradlew assembleDebug` must succeed
2. Install the APK and open a terminal session
3. Run `printf '\033[?u'` — should receive response `\033[?0u` (Kitty mode not yet activated)
4. Run `printf '\033[=1u'` to activate mode 1, then `printf '\033[?u'` — response should be `\033[?1u`
5. Run `printf '\033[>0q'` — response should contain `SOUL Terminal 1.0`
6. In Neovim: `:checkhealth` should report Kitty keyboard protocol as active
7. Normal shell usage (arrows, F-keys, Tab, Enter) must still work correctly when Kitty mode is NOT active
8. Run `printf '\033[>u'` to reset — `printf '\033[?u'` should respond `\033[?0u`
</verification>

<must_haves>
- Kitty mode flags are stored per-emulator and reset on terminal reset
- CSI = N u sets mode, CSI ? u queries mode, CSI > u resets mode
- XTVERSION response identifies as "SOUL Terminal 1.0"
- Special keys (arrows, F1-F12, Home, End, etc.) encoded as CSI kitty-number ; modifiers u when Kitty mode active
- Key release events sent when mode 2 is active and onKeyUp fires
- Standard key handling is unaffected when Kitty mode is 0 (no regression)
</must_haves>
