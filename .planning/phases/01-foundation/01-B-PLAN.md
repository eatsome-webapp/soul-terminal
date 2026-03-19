---
phase: 1
plan: B
wave: 1
depends_on: []
autonomous: true
requirements: [REBR-03, REBR-04]
files_modified:
  - app/src/main/res/drawable/ic_foreground.xml
  - app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
  - app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml
  - app/src/main/res/mipmap-mdpi/ic_launcher.png
  - app/src/main/res/mipmap-mdpi/ic_launcher_round.png
  - app/src/main/res/mipmap-hdpi/ic_launcher.png
  - app/src/main/res/mipmap-hdpi/ic_launcher_round.png
  - app/src/main/res/mipmap-xhdpi/ic_launcher.png
  - app/src/main/res/mipmap-xhdpi/ic_launcher_round.png
  - app/src/main/res/mipmap-xxhdpi/ic_launcher.png
  - app/src/main/res/mipmap-xxhdpi/ic_launcher_round.png
  - app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
  - app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png
  - app/src/main/res/values/colors.xml
  - app/src/main/res/values/styles.xml
---

# Plan 01-B: Launcher Icon & UI Theming

<objective>
Create a SOUL Terminal branded launcher icon (adaptive + raster fallbacks) and update the UI color scheme to SOUL branding.
</objective>

<tasks>

<task id="1">
<title>Create SOUL Terminal foreground icon drawable</title>
<read_first>
- app/src/main/res/drawable/ic_foreground.xml
</read_first>
<action>
Replace `app/src/main/res/drawable/ic_foreground.xml` with a new vector drawable representing SOUL Terminal. Design: a terminal prompt symbol `>_` (chevron + underscore cursor) in white on a transparent background, centered in the 108x108dp adaptive icon canvas with content within the 72x72dp safe zone.

The vector XML should:
- Use `android:width="108dp"` and `android:height="108dp"`
- Use `android:viewportWidth="108"` and `android:viewportHeight="108"`
- Draw a `>_` terminal prompt shape using `<path>` elements with white fill (`#FFFFFF`)
- Keep the design within x:18-90, y:18-90 (the 72dp safe zone)
</action>
<acceptance_criteria>
- [ ] File app/src/main/res/drawable/ic_foreground.xml exists and is valid XML
- [ ] grep -q 'viewportWidth="108"' app/src/main/res/drawable/ic_foreground.xml
- [ ] grep -q 'viewportHeight="108"' app/src/main/res/drawable/ic_foreground.xml
- [ ] grep -q '#FFFFFF\|#ffffff' app/src/main/res/drawable/ic_foreground.xml (white paths)
</acceptance_criteria>
</task>

<task id="2">
<title>Update adaptive icon background color</title>
<read_first>
- app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
- app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml
- app/src/main/res/values/colors.xml
</read_first>
<action>
1. In `app/src/main/res/values/colors.xml`, add a color:
   `<color name="soul_icon_background">#1A1A2E</color>` (dark navy — SOUL brand)

2. In `app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`, change the background from `@android:color/black` to `@color/soul_icon_background`

3. In `app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml`, change the background from `@android:color/black` to `@color/soul_icon_background`
</action>
<acceptance_criteria>
- [ ] grep -q 'soul_icon_background' app/src/main/res/values/colors.xml
- [ ] grep -q '#1A1A2E' app/src/main/res/values/colors.xml
- [ ] grep -q '@color/soul_icon_background' app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
- [ ] grep -q '@color/soul_icon_background' app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml
</acceptance_criteria>
</task>

<task id="3">
<title>Generate raster icon fallbacks</title>
<read_first>
- app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
</read_first>
<action>
Generate PNG icons for the SOUL Terminal icon at all required densities. The icon should be a `>_` terminal prompt (white) on dark navy (#1A1A2E) background.

Create/replace these files (all density variants):
- mipmap-mdpi/ic_launcher.png (48x48px) + ic_launcher_round.png (48x48px)
- mipmap-hdpi/ic_launcher.png (72x72px) + ic_launcher_round.png (72x72px)
- mipmap-xhdpi/ic_launcher.png (96x96px) + ic_launcher_round.png (96x96px)
- mipmap-xxhdpi/ic_launcher.png (144x144px) + ic_launcher_round.png (144x144px)
- mipmap-xxxhdpi/ic_launcher.png (192x192px) + ic_launcher_round.png (192x192px)

Since we cannot run image generation tools locally, generate these as simple solid-color PNGs using a script, or use ImageMagick/Python if available. The round variants should be circular-cropped versions.

Alternative: If image generation is not possible, create a minimal placeholder PNG (the adaptive icon on API 26+ will be the primary icon for 95%+ of devices). Document that proper PNGs should be generated via Android Studio Image Asset tool later.
</action>
<acceptance_criteria>
- [ ] File app/src/main/res/mipmap-mdpi/ic_launcher.png exists
- [ ] File app/src/main/res/mipmap-hdpi/ic_launcher.png exists
- [ ] File app/src/main/res/mipmap-xhdpi/ic_launcher.png exists
- [ ] File app/src/main/res/mipmap-xxhdpi/ic_launcher.png exists
- [ ] File app/src/main/res/mipmap-xxxhdpi/ic_launcher.png exists
- [ ] File app/src/main/res/mipmap-mdpi/ic_launcher_round.png exists
- [ ] File app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png exists
</acceptance_criteria>
</task>

<task id="4">
<title>Update UI theme colors to SOUL branding</title>
<read_first>
- app/src/main/res/values/styles.xml
- app/src/main/res/values/colors.xml
</read_first>
<action>
Update the color scheme in `colors.xml` and/or `styles.xml` to reflect SOUL branding:

1. In `colors.xml`, add/update these SOUL brand colors:
   - `<color name="soul_primary">#6C63FF</color>` (purple — primary accent)
   - `<color name="soul_primary_dark">#1A1A2E</color>` (dark navy — status bar, backgrounds)
   - `<color name="soul_accent">#00D9FF</color>` (cyan — accents, highlights)
   - `<color name="soul_background">#0F0F23</color>` (near-black — terminal background)
   - `<color name="soul_surface">#16213E</color>` (dark blue — cards, surfaces)

2. In `styles.xml`, update the app theme's primary colors to reference the SOUL colors:
   - `colorPrimary` → `@color/soul_primary`
   - `colorPrimaryDark` → `@color/soul_primary_dark`
   - `colorAccent` → `@color/soul_accent`

Note: Only change the theme colors. Do NOT change terminal emulator colors (those are user-configurable via Termux:Styling/properties file).
</action>
<acceptance_criteria>
- [ ] grep -q 'soul_primary' app/src/main/res/values/colors.xml
- [ ] grep -q '#6C63FF' app/src/main/res/values/colors.xml
- [ ] grep -q 'soul_accent' app/src/main/res/values/colors.xml
- [ ] grep -q '@color/soul_primary' app/src/main/res/values/styles.xml
</acceptance_criteria>
</task>

</tasks>

<verification>
1. All mipmap directories contain ic_launcher.png and ic_launcher_round.png
2. Adaptive icon XMLs reference the new foreground drawable and SOUL background color
3. styles.xml references SOUL brand colors
4. Build compiles without resource errors
</verification>

<must_haves>
- Custom SOUL Terminal vector foreground icon (not Termux default)
- Adaptive icon background uses SOUL brand dark navy (#1A1A2E)
- Raster fallback PNGs exist at all 5 densities (mdpi through xxxhdpi)
- UI theme uses SOUL brand colors (purple primary, cyan accent, dark navy status bar)
- Terminal emulator colors are NOT modified (user-configurable)
</must_haves>
