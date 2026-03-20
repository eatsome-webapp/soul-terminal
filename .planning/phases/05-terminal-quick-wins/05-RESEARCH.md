# Phase 5: Terminal Quick Wins — Research

**Researched:** 2026-03-20
**Status:** Complete

---

## TERM-04: Scrollback Buffer 2000 → 20000

### File
`terminal-emulator/src/main/java/com/termux/terminal/TerminalEmulator.java`

### Current values (lines 149-151)
```java
public static final int TERMINAL_TRANSCRIPT_ROWS_MIN = 100;
public static final int TERMINAL_TRANSCRIPT_ROWS_MAX = 50000;
public static final int DEFAULT_TERMINAL_TRANSCRIPT_ROWS = 2000;
```

### Required change
Line 151: change `2000` → `20000`

```java
public static final int DEFAULT_TERMINAL_TRANSCRIPT_ROWS = 20000;
```

### Notes
- `TERMINAL_TRANSCRIPT_ROWS_MAX` is 50000, so 20000 is safely within bounds.
- The user can still override this via `terminal-transcript-rows` in `~/.termux/termux.properties`. The default is only used when no user override exists (via `TermuxSharedProperties.getTerminalTranscriptRowsInternalPropertyValueFromValue()`).
- No side effects — this is a scalar constant with no dependencies.

---

## TERM-05: Extra Keys Layout for Claude Code

### File
`termux-shared/src/main/java/com/termux/shared/termux/settings/properties/TermuxPropertyConstants.java`

### Current value (line 329)
```java
public static final String DEFAULT_IVALUE_EXTRA_KEYS = "[['ESC','/',{key: '-', popup: '|'},'HOME','UP','END','PGUP'], ['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]"; // Double row
```

### Required change
Line 329: replace with SOUL/Claude Code optimized layout.

```java
public static final String DEFAULT_IVALUE_EXTRA_KEYS = "[['ESC','TAB','CTRL','C','D','Z','UP'], ['HOME','END','LEFT','DOWN','RIGHT','CTRL','ALT']]"; // Claude Code optimized
```

### Extra keys JSON format
- Outer array = rows. Each inner array = keys in that row.
- Each key is either a plain string (key name) or a JSON object `{key: 'NAME', popup: 'OTHER_NAME', display: 'label'}`.
- Valid key names come from `ExtraKeysConstants.PRIMARY_KEY_CODES_FOR_STRINGS`: `ESC`, `TAB`, `HOME`, `END`, `PGUP`, `PGDN`, `INS`, `DEL`, `BKSP`, `UP`, `LEFT`, `RIGHT`, `DOWN`, `ENTER`, `F1`–`F12`, `SPACE`.
- Special keys handled by `TermuxTerminalExtraKeys`: `CTRL`, `ALT`, `SHIFT`, `FN` — these are modifier toggles (not in PRIMARY_KEY_CODES but handled by `TerminalExtraKeys`).
- String literals like `C`, `D`, `Z`, `L` are sent as literal characters. Combined with CTRL held down they produce Ctrl+C, Ctrl+D, Ctrl+Z, Ctrl+L.

### Exact target layout per CONTEXT.md decisions
Row 1 (Claude Code shortcuts): `ESC`, `TAB`, `CTRL+C`, `CTRL+D`, `CTRL+Z`, `CTRL+L`, `UP`
Row 2 (navigation): `HOME`, `END`, `LEFT`, `DOWN`, `RIGHT`, `CTRL`, `ALT`

For Ctrl+C/D/Z/L as dedicated buttons, use the macro syntax:
```
{macro: 'CTRL C', display: '^C'}
{macro: 'CTRL D', display: '^D'}
{macro: 'CTRL Z', display: '^Z'}
{macro: 'CTRL L', display: '^L'}
```

**Final target value:**
```java
public static final String DEFAULT_IVALUE_EXTRA_KEYS = "[[\'ESC\',\'TAB\',{macro:\'CTRL C\',display:\'^C\'},{macro:\'CTRL D\',display:\'^D\'},{macro:\'CTRL Z\',display:\'^Z\'},{macro:\'CTRL L\',display:\'^L\'},\'UP\'],[\'HOME\',\'END\',\'LEFT\',\'DOWN\',\'RIGHT\',\'CTRL\',\'ALT\']]";
```

### User override safety
`TermuxSharedProperties.getExtraKeysInternalPropertyValueFromValue(String value)` (line 527-528):
```java
return SharedProperties.getDefaultIfNullOrEmpty(value, TermuxPropertyConstants.DEFAULT_IVALUE_EXTRA_KEYS);
```
The default is only used when `value` is null or empty — i.e., when the user has no `extra-keys` entry in `~/.termux/termux.properties`. User overrides are fully preserved.

### Fallback behavior
`TermuxTerminalExtraKeys.setExtraKeys()` (line 71): if JSON parsing fails, falls back to `DEFAULT_IVALUE_EXTRA_KEYS`. So the new value must be valid JSON — the macro syntax is standard and tested in the existing codebase examples.

---

## TERM-06: SOUL Color Theme as Default

### File
`terminal-emulator/src/main/java/com/termux/terminal/TerminalColorScheme.java`

### Current values (line 60)
```java
// COLOR_INDEX_DEFAULT_FOREGROUND, COLOR_INDEX_DEFAULT_BACKGROUND and COLOR_INDEX_DEFAULT_CURSOR:
0xffffffff, 0xff000000, 0xffffffff};
```
- Foreground: `0xffffffff` = white
- Background: `0xff000000` = black
- Cursor: `0xffffffff` = white

### Required change (line 60)
```java
0xffE0E0E0, 0xff0F0F23, 0xff6C63FF};
```
- Foreground `#E0E0E0` → `0xffE0E0E0`
- Background `#0F0F23` → `0xff0F0F23`
- Cursor `#6C63FF` → `0xff6C63FF`

### ARGB format confirmation
All values in `DEFAULT_COLORSCHEME` use `0xffRRGGBB` format (full alpha = 0xff). The last 3 entries map to `TextStyle.COLOR_INDEX_FOREGROUND` (256), `COLOR_INDEX_BACKGROUND` (257), `COLOR_INDEX_CURSOR` (258).

### User override safety
`TerminalColorScheme.updateWith(Properties props)` (line 72): if a `~/.termux/colors.properties` file exists, its values overwrite the defaults for the specific keys (`foreground`, `background`, `cursor`, `color0`–`color255`). The ANSI 16 colors (indices 0–15) are **not changed** — only the last 3 entries. This means existing syntax highlighting in vim/neovim is unaffected.

### Side effect: cursor color auto-set
`setCursorColorForBackground()` (lines 115-124) is called when no `cursor` property exists in the user properties file. It checks perceived brightness of background and sets cursor to white or black accordingly. Since our background `#0F0F23` has low brightness, this method would set cursor to white — but since we set cursor in the hardcoded DEFAULT_COLORSCHEME array and `setCursorColorForBackground()` is only called from `updateWith()` (when loading a user properties file), our default is applied before that. If the user has a colors.properties without a `cursor` key, `setCursorColorForBackground()` will override our cursor with white — acceptable behavior.

---

## TERM-07: SOUL Colors in App Chrome

### Files requiring changes

#### 1. `termux-shared/src/main/res/values/colors.xml`
New SOUL color entries to add:
```xml
<color name="soul_bg">#0F0F23</color>
<color name="soul_fg">#E0E0E0</color>
<color name="soul_accent">#6C63FF</color>
<color name="soul_accent_dim">#2A2A4A</color>
```

These can then be referenced in both themes.xml files. Adding to termux-shared so they are accessible from both the app module and any future shared components (colors.xml in app module is currently empty).

#### 2. `app/src/main/res/values/themes.xml` (light theme, lines 19-47)
Current values and required changes:

| Attribute | Current value | Required value |
|-----------|--------------|---------------|
| `colorPrimary` | `@color/black` | `@color/soul_accent` |
| `colorPrimaryVariant` | `@color/black` | `@color/soul_accent` |
| `android:windowBackground` | `@color/black` | `@color/soul_bg` |
| `termuxActivityDrawerBackground` | `@color/white` | `@color/soul_bg` |
| `termuxActivityDrawerImageTint` | `@color/black` | `@color/soul_fg` |
| `extraKeysButtonTextColor` | `@color/white` | `@color/soul_fg` |
| `extraKeysButtonActiveTextColor` | `@color/red_400` | `@color/soul_accent` |
| `extraKeysButtonBackgroundColor` | `@color/black` | `@color/soul_bg` |
| `extraKeysButtonActiveBackgroundColor` | `@color/grey_500` | `@color/soul_accent_dim` |

#### 3. `app/src/main/res/values-night/themes.xml` (dark theme, lines 10-38)
Same attributes, same changes (identical to light — SOUL theme is always dark):

| Attribute | Current value | Required value |
|-----------|--------------|---------------|
| `colorPrimary` | `@color/black` | `@color/soul_accent` |
| `colorPrimaryVariant` | `@color/black` | `@color/soul_accent` |
| `android:windowBackground` | `@color/black` | `@color/soul_bg` |
| `termuxActivityDrawerBackground` | `@color/black` | `@color/soul_bg` |
| `termuxActivityDrawerImageTint` | `@color/white` | `@color/soul_fg` |
| `extraKeysButtonTextColor` | `@color/white` | `@color/soul_fg` |
| `extraKeysButtonActiveTextColor` | `@color/red_400` | `@color/soul_accent` |
| `extraKeysButtonBackgroundColor` | `@color/black` | `@color/soul_bg` |
| `extraKeysButtonActiveBackgroundColor` | `@color/grey_500` | `@color/soul_accent_dim` |

### Attribute definitions
- `extraKeysButton*` attrs defined in: `termux-shared/src/main/res/values/attrs.xml` (lines 3-6)
- `termuxActivityDrawer*` attrs defined in: `app/src/main/res/values/attrs.xml` (lines 3-4)
- Both use `format="reference"` — they must reference a `@color/` resource, not a hardcoded hex.

### Theme hierarchy
```
Theme.MaterialComponents (dark) / Theme.MaterialComponents.Light.DarkActionBar (light)
  └── Theme.BaseActivity.DayNight.DarkActionBar / .NoActionBar  [termux-shared themes.xml]
        └── Theme.TermuxApp.DayNight.NoActionBar  [app themes.xml]
              └── Theme.TermuxActivity.DayNight.NoActionBar  [app themes.xml]  ← applied to TermuxActivity
```
Only `Theme.TermuxActivity.DayNight.NoActionBar` needs changes (both values/ and values-night/ versions). The `buttonBarButtonStyle` items reference `TermuxActivity.Drawer.ButtonBarStyle.Light/Dark` from `styles.xml` — these set `android:textColor` to black/white respectively, no changes needed there.

### `extra-keys-text-all-caps` consideration
`KEY_EXTRA_KEYS_TEXT_ALL_CAPS` defaults to `true` (in `TERMUX_DEFAULT_TRUE_BOOLEAN_BEHAVIOUR_PROPERTIES_LIST`). This means button labels like `^C`, `^D` will be uppercased. Since `^C` is already uppercase, this is not a problem. The CONTEXT.md defers this decision to implementer — recommendation is to leave `true` (default) since it has no visible impact on our chosen labels.

---

## Risks and Considerations

### Risk 1: soul_bg conflicts with existing windowBackground in terminal
The terminal background is set both by `android:windowBackground` (app chrome) and by `TerminalColorScheme` (terminal rendering). Setting both to `#0F0F23` is correct and intentional — they will match exactly.

### Risk 2: `colorPrimary` change affects dialog button tint
`colorPrimary` (`#6C63FF`) will be used for Material dialog button text color. This is acceptable — purple buttons on dark background are visible and on-brand.

### Risk 3: DayNight vs night qualifier
The app uses `DayNight` themes. In day mode, `values/themes.xml` is used; in night mode, `values-night/themes.xml` overrides it. Since SOUL theme is always dark, both should have identical values — confirmed in design decision.

### Risk 4: `buttonBarButtonStyle` in light theme
The light theme uses `TermuxActivity.Drawer.ButtonBarStyle.Light` which sets `android:textColor` to `@color/black`. After changing `termuxActivityDrawerBackground` to `soul_bg` (#0F0F23), black text on dark background is invisible. Fix: change `buttonBarButtonStyle` in `values/themes.xml` to use the Dark variant. The CONTEXT.md does not explicitly cover this — include in implementation plan.

### Risk 5: Extra keys JSON escaping in Java string
The macro syntax uses single quotes in JSON (standard in Termux extra keys format). Existing codebase comment on line 328 shows single-row format with single quotes works. The implementation must properly escape the Java string literal.

---

## Validation Architecture

### TERM-04 (scrollback)
1. Build and install APK via GitHub Actions.
2. In terminal: run `yes | head -25000 > /tmp/test.txt && cat /tmp/test.txt` — generates 25000 lines.
3. Scroll up — should reach line 1 without hitting the buffer limit.
4. Alternative: `seq 1 25000` and verify line 1 is reachable.

### TERM-05 (extra keys)
1. Build and install APK.
2. Open terminal — extra keys bar should show Row 1: `ESC TAB ^C ^D ^Z ^L ↑` and Row 2: `HOME END ← ↓ → CTRL ALT`.
3. Tap `^C` — should send Ctrl+C (interrupt running process).
4. Tap `^D` — should send Ctrl+D (EOF).
5. Tap `ESC` — should send Escape (Claude Code menu navigation).
6. Verify user override: add `extra-keys = [[ESC]]` to `~/.termux/termux.properties`, restart — should show only ESC row.

### TERM-06 (terminal colors)
1. Build and install APK.
2. Open terminal — background should be `#0F0F23` (dark navy), text `#E0E0E0` (light grey), cursor `#6C63FF` (purple).
3. Run `ls --color` — ANSI colors should work normally (they are unchanged).
4. Verify user override: create `~/.termux/colors.properties` with `background=#000000` — terminal background should switch to black.

### TERM-07 (app chrome)
1. Build and install APK.
2. Verify terminal background matches drawer background (`#0F0F23`).
3. Open drawer — background should be `#0F0F23`, icons `#E0E0E0`.
4. Tap a modifier key (CTRL) in extra keys — active state should show purple (`#6C63FF`) text on `#2A2A4A` background.
5. Check app in both day and night system mode — should look identical (both dark).

---

## File Summary

| File | Change type | Lines affected |
|------|-------------|----------------|
| `terminal-emulator/src/main/java/com/termux/terminal/TerminalEmulator.java` | Constant change | 151 |
| `terminal-emulator/src/main/java/com/termux/terminal/TerminalColorScheme.java` | 3 int values | 60 |
| `termux-shared/src/main/java/com/termux/shared/termux/settings/properties/TermuxPropertyConstants.java` | String constant | 329 |
| `termux-shared/src/main/res/values/colors.xml` | Add 4 color entries | after line 23 |
| `app/src/main/res/values/themes.xml` | 9 attribute values | 21, 24, 39, 40, 43-46 |
| `app/src/main/res/values-night/themes.xml` | 9 attribute values | 12, 15, 30, 31, 34-37 |

---

## Research Complete
