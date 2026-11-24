# DevOS Architecture: Light-Only Theme Specification

DevOS is light-only. Do not add dark mode, theme toggles, or `DayNight` parents. All colors come from `lib/core/theme/` and `lib/core/constants/app_colors.dart`.

## Core Principles
1. **Single Theme Only**: The application renders identically across all operating systems regardless of the host system's brightness or dark mode preferences.
2. **Native Platform Lock**:
   - **Android**: Non-DayNight theme parents (`Theme.Light.NoTitleBar`) in `styles.xml`, `android:forceDarkAllowed` set to `false`, and `values-night/` eliminated.
   - **iOS**: `UIUserInterfaceStyle` locked to `Light` in `Info.plist`.
   - **Web**: `<meta name="color-scheme" content="light">` in `index.html` and manifest colors set to `#D6BDBD` / `#352554`.
   - **Desktop**: Windows runner enforces `DWMWA_USE_IMMERSIVE_DARK_MODE = FALSE`; macOS locks window appearance to Aqua.
3. **No Dynamic Theme Branching**:
   - `ThemeMode.light` is hardcoded.
   - Do not use `isDark`, `ThemeMode.dark`, `ThemeMode.system`, `darkTheme`, or `MediaQuery.platformBrightnessOf(context)`.
4. **Deliberate Dark Brand Surfaces**:
   - Specific dark purple banners (`#352554` / `#2E1065`), crimson buttons (`#8F0030`), and code badges (`#0EA358`) are intentional brand surfaces *within* the light design system. All text pairings on them must maintain minimum WCAG 2.1 AA/AAA contrast ratios (4.5:1 for normal text, 3:1 for large text / UI controls).

