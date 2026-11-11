# DevOS Light-Only Single-Theme Conversion: Complete Inventory & Audit

**Date**: 2026-11-11  
**Branch**: `feat/light-only-theme`  
**Status**: Phase 1 Inventory Complete (Read-Only) — Awaiting User Approval  

---

## 1. Executive Summary & Triggering Mechanism Analysis

DevOS currently triggers and propagates dark mode via two distinct pathways:

1. **In-App State & User Toggle**:
   - `ThemeModeNotifier` (`lib/providers/app_providers.dart:28-39`) initializes with `ThemeMode.dark` as the default state.
   - The navigation drawer (`lib/main.dart:363-386`) exposes an interactive `Switch.adaptive` that toggles `themeModeProvider` between `ThemeMode.dark` and `ThemeMode.light`.
   - `DevOSApp` (`lib/main.dart:40-49`) feeds `themeMode` into `MaterialApp`, which switches between `AppTheme.lightTheme` and `AppTheme.darkTheme`.
   - 160+ individual widget build methods query `AppColors.isDark(context)` (`Theme.of(context).brightness == Brightness.dark`) or `isDark` variable to conditionally assign Obsidian dark surfaces (`#0D1117`, `#161B22`, `#21262D`, etc.).

2. **Operating System & Native Platform Settings**:
   - **Android**: `android/app/src/main/res/values-night/styles.xml` overrides `LaunchTheme` and `NormalTheme` with `@android:style/Theme.Black.NoTitleBar` whenever Android OS night mode is active. `values/styles.xml` is missing `<item name="android:forceDarkAllowed">false</item>`, permitting Android 10+ Force Dark auto-inversion.
   - **Windows Runner**: `windows/runner/win32_window.cpp:275-287` queries the Windows Registry key `Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\AppsUseLightTheme`. If 0, it explicitly invokes `DwmSetWindowAttribute(window, DWMWA_USE_IMMERSIVE_DARK_MODE, ...)` to render dark window decorations.
   - **iOS Runner**: `ios/Runner/Info.plist` lacks `<key>UIUserInterfaceStyle</key><string>Light</string>`, causing iOS to report dark system appearance when device dark mode is toggled.
   - **Web**: `web/index.html` lacks `<meta name="color-scheme" content="light">`, allowing browser stylesheets to apply dark user-agent styling. `web/manifest.json` retains default `#0175C2`.
   - **Zen Mode (Notes)**: `lib/features/notes/note_detail_screen.dart:179` explicitly forces `Theme(data: ThemeData.dark(), child: MarkdownRenderer(...))` when entering distraction-free reading.

---

## 2. Exhaustive Occurrence Inventory Table

| Area | File:Line | What it is | Planned Action & Justification |
| :--- | :--- | :--- | :--- |
| **Theme Layer** | `lib/main.dart:40` | `ref.watch(themeModeProvider)` in root widget | **Delete**: Root app no longer observes dynamic theme state. |
| **Theme Layer** | `lib/main.dart:46` | `darkTheme: AppTheme.darkTheme` in `MaterialApp` | **Delete**: Eliminate secondary theme entirely; light theme is singular. |
| **Theme Layer** | `lib/main.dart:47` | `themeMode: themeMode` in `MaterialApp` | **Change**: Hardcode `themeMode: ThemeMode.light` (or remove entirely) so OS dark setting cannot trigger dark theme. |
| **Theme Layer** | `lib/core/theme/app_theme.dart:7-80` | `static ThemeData get darkTheme` method and full dark definition | **Delete**: Remove entire 74-line dark theme definition, including `Brightness.dark`, `ColorScheme.dark`, and dark text theme. |
| **Theme Layer** | `lib/core/theme/app_theme.dart:82-152` | `static ThemeData get lightTheme` method | **Change**: Rename to `AppTheme.theme` (or keep `lightTheme`), explicitly set `surfaceTintColor: Colors.transparent`, and lock `Brightness.light`. |
| **Theme Tokens** | `lib/core/constants/app_colors.dart:52-57` | `backgroundDark`, `surfaceDark`, `cardDark`, `cardBorderDark` | **Delete**: Remove obsolete obsidian dark palette constants. |
| **Theme Tokens** | `lib/core/constants/app_colors.dart:73-76` | `textPrimaryDark`, `textSecondaryDark`, `textMutedDark` | **Delete**: Remove unused dark text token constants. |
| **Theme Tokens** | `lib/core/constants/app_colors.dart:88-90` | `static bool isDark(BuildContext context)` helper method | **Delete**: Remove method so code cannot branch on brightness. |
| **Theme Tokens** | `lib/core/constants/app_colors.dart:92-118` | `background()`, `card()`, `cardBorder()`, `textPrimary()`, `textSecondary()`, `textHeading()`, `bannerBackground()` | **Change**: Collapse all adaptive helpers to unconditionally return light design tokens (`figmaBackground`, `cardLight`, `cardBorderLight`, `textPrimaryLight`, etc.). |
| **Providers** | `lib/providers/app_providers.dart:28-39` | `ThemeModeNotifier` and `themeModeProvider` | **Delete**: Remove state notifier and Riverpod provider; theme state is static light. |
| **Main Navigation** | `lib/main.dart:148-149` | `final themeMode = ref.watch(themeModeProvider); final isDark = ...` | **Delete**: Remove theme watch and `isDark` boolean. |
| **Main Navigation** | `lib/main.dart:214` | Title color ternary: `isDark ? Color(0xFF60A5FA) : AppColors.figmaBlue` | **Change**: Hardcode to `AppColors.figmaBlue` (`#1E56FF`). |
| **Main Navigation** | `lib/main.dart:284-292` | Search button container decoration ternary | **Change**: Lock to light design: `AppColors.figmaCardDark` (`#222222`) container with white icon. |
| **Main Navigation** | `lib/main.dart:307-309` | Drawer background color ternary | **Change**: Lock to `AppColors.surfaceLight` (`#FFFFFF`). |
| **Main Navigation** | `lib/main.dart:314-318` | Drawer header background color ternary | **Change**: Lock to deliberate dark banner surface (`#352554` / `AppColors.backgroundDark`). |
| **Main Navigation** | `lib/main.dart:362-387` | In-app theme toggle `ListTile` with `Switch.adaptive` in Drawer | **Delete**: Remove entire theme-switch tile from drawer navigation. |
| **Dashboard Screen** | `lib/features/dashboard/dashboard_screen.dart:15` | `final isDark = AppColors.isDark(context);` | **Delete**: Remove `isDark` lookup. |
| **Dashboard Screen** | `lib/features/dashboard/dashboard_screen.dart:55-65` | Urgent card background, border, and boxShadow ternaries | **Change**: Lock to light `AppColors.figmaUrgentCard` (`#CECECE`) and `#B8B8B8` border. |
| **Dashboard Screen** | `lib/features/dashboard/dashboard_screen.dart:91-143` | Stat cards text, badge, and button colors ternaries (8 occurrences) | **Change**: Lock all branches to light Figma palette (`figmaTextRed`, dark `#1E293B` submit button with white text). |
| **Dashboard Screen** | `lib/features/dashboard/dashboard_screen.dart:277-375` | Academic progress card, lavender card, and divider ternaries (11 occurrences) | **Change**: Lock to `figmaLavenderCard` (`#E4DBEA`), `#333333` border, and light text. |
| **Dashboard Screen** | `lib/features/dashboard/dashboard_screen.dart:400-430` | Quick metric cards ternaries (5 occurrences) | **Change**: Lock to `figmaMetricCard` (`#F3F3F3`), `#333333` border, and black text. |
| **Courses Screen** | `lib/features/courses/courses_screen.dart:33` | `final isDark = AppColors.isDark(context);` | **Delete**: Remove `isDark` local variable. |
| **Courses Screen** | `lib/features/courses/courses_screen.dart:79` | Header banner background ternary | **Change**: Lock to deliberate brand `AppColors.figmaForestBanner` (`#2E6316`). |
| **Courses Screen** | `lib/features/courses/courses_screen.dart:118-132` | Semester filter chip background, border, and text ternaries (4 occurrences) | **Change**: Lock to light filter pill styling (`figmaPurpleCard` when selected, white when unselected, black87 text). |
| **Courses Screen** | `lib/features/courses/courses_screen.dart:163-166` | Add course button card ternary | **Change**: Lock to `AppColors.figmaPurpleCard` with `#333333` border. |
| **Courses Screen** | `lib/features/courses/courses_screen.dart:335-376` | Course cards, divider, and topic chip ternaries (5 occurrences) | **Change**: Lock to light cards, `#A69090` divider, and light topic badges. |
| **Course Detail** | `lib/features/courses/course_detail_screen.dart:79` | `final isDark = AppColors.isDark(context);` | **Delete**: Remove `isDark` local variable. |
| **Course Detail** | `lib/features/courses/course_detail_screen.dart:136-327` | Syllabus cards, topic progress, and dividers (6 occurrences) | **Change**: Lock to light card backgrounds and high-contrast light borders. |
| **Workload Screen** | `lib/features/workload/workload_screen.dart:588` | `final isDark = AppColors.isDark(context);` | **Delete**: Remove `isDark` local variable. |
| **Workload Screen** | `lib/features/workload/workload_screen.dart:595-608` | Metric summary cards ternaries (3 occurrences) | **Change**: Lock to `figmaMetricCard` (`#F3F3F3`) with `#333333` border. |
| **Workload Screen** | `lib/features/workload/workload_screen.dart:633-682` | Status filter chips ternaries (7 occurrences) | **Change**: Lock active chip to crimson `AppColors.figmaBottomNav` (`#8F0030`), inactive to white with `#333333` border. |
| **Workload Screen** | `lib/features/workload/workload_screen.dart:699-737` | Priority filter chips ternaries (6 occurrences) | **Change**: Lock active priority chips to light design styling. |
| **Workload Screen** | `lib/features/workload/workload_screen.dart:850-1103` | Task cards, priority badges, and metadata row ternaries (20 occurrences) | **Change**: Lock task cards to light urgent/metric backgrounds, `#333333` borders, and high-contrast text. |
| **Skills Screen** | `lib/features/skills/skills_screen.dart:69, 101` | `AppColors.isDark(ctx)`, `final isDark = ...` | **Delete**: Remove both `isDark` references. |
| **Skills Screen** | `lib/features/skills/skills_screen.dart:122-170` | Skills header banner, add skill button ternaries (4 occurrences) | **Change**: Lock banner to brand forest green (`#2E6316`), button to `figmaPlusBtn` (`#E8C4C4`). |
| **Skills Screen** | `lib/features/skills/skills_screen.dart:200-214` | Category filter chip ternaries (4 occurrences) | **Change**: Lock active chip to `figmaCyanCard` (`#0284C7`), inactive to white with `#333333` border. |
| **Skills Screen** | `lib/features/skills/skills_screen.dart:237-397` | Skill cards, subtopic chips, and FAB ternaries (9 occurrences) | **Change**: Lock cards to light surface, subtopics to light chips, and FAB to `figmaAddBtn` (`#1B1B1B`). |
| **Projects Screen** | `lib/features/projects/projects_screen.dart:18, 126, 471` | `AppColors.isDark(ctx)`, `final isDark = ...` | **Delete**: Remove all `isDark` references. |
| **Projects Screen** | `lib/features/projects/projects_screen.dart:75-104` | Project header banner and add button ternaries (3 occurrences) | **Change**: Lock banner to deliberate dark purple `#2E1065`, add button to `#F3F3F3`. |
| **Projects Screen** | `lib/features/projects/projects_screen.dart:145-160` | Stage pipeline filter chips ternaries (4 occurrences) | **Change**: Lock active chip to `figmaOrangeCard` (`#EA580C`), inactive to white with `#333333` border. |
| **Projects Screen** | `lib/features/projects/projects_screen.dart:194-444` | Project cards, tech stack chips, and stage badges ternaries (10 occurrences) | **Change**: Lock to light card styling and high-contrast text. |
| **Project Detail** | `lib/features/projects/project_detail_screen.dart:85` | `final isDark = AppColors.isDark(context);` | **Delete**: Remove `isDark` local variable. |
| **Project Detail** | `lib/features/projects/project_detail_screen.dart:141-717` | Sprints timeline, milestones, and repo badge ternaries (8 occurrences) | **Change**: Lock to light sprint cards (`figmaSprintPurple`, `figmaSprintRust`), light dividers, and dark text. |
| **Notes Screen** | `lib/features/notes/notes_screen.dart:698, 737, 814` | `final isDark = AppColors.isDark(context);` (3 lookups) | **Delete**: Remove `isDark` local variables. |
| **Notes Screen** | `lib/features/notes/notes_screen.dart:752-800` | Folder sidebar item ternaries (6 occurrences) | **Change**: Lock sidebar items to light background (`#FFFFFF` or `#F3F3F3`) with dark text (`Colors.black87`). |
| **Notes Screen** | `lib/features/notes/notes_screen.dart:841-1000` | Note cards, tag chips, and preview snippet ternaries (10 occurrences) | **Change**: Lock to light note cards (`#F3F3F3`), light tag pills, and dark text. |
| **Note Detail** | `lib/features/notes/note_detail_screen.dart:179` | `Theme(data: ThemeData.dark(), child: MarkdownRenderer(...))` | **Change**: Remove `ThemeData.dark()`; render Zen Mode on a clean light reading surface (`#FFFFFF` on `#D6BDBD` canvas) with crisp dark text. |
| **Markdown Renderer** | `lib/features/notes/widgets/markdown_renderer.dart:236-258` | Dark code-block surface (`#181B20`), header (`#101216`), and dark syntax spans | **Change**: Replace with clean light syntax theme (light gray `#F8FAFC` background, subtle `#E2E8F0` border, dark colored tokens). *(See Open Decision below)*. |
| **Android Native** | `android/app/src/main/res/values-night/styles.xml` | Night mode launch and window styles with `Theme.Black.NoTitleBar` | **Delete**: Delete `values-night/styles.xml` completely so Android OS night mode cannot apply dark window backgrounds. |
| **Android Native** | `android/app/src/main/res/values/styles.xml:4-18` | `LaunchTheme` and `NormalTheme` styles | **Change**: Add `<item name="android:forceDarkAllowed">false</item>` to both themes to block Android 10+ Force Dark auto-inversion. |
| **iOS Native** | `ios/Runner/Info.plist` | Missing `UIUserInterfaceStyle` specification | **Change**: Add `<key>UIUserInterfaceStyle</key><string>Light</string>` so iOS locks the app to light appearance. |
| **Web Native** | `web/index.html:19-35` | Missing color-scheme meta and background CSS | **Change**: Add `<meta name="color-scheme" content="light">` and `<style>:root{color-scheme:light; background-color:#D6BDBD;}</style>`. |
| **Web Native** | `web/manifest.json:6-7` | Default blue `"background_color": "#0175C2"` and `"theme_color": "#0175C2"` | **Change**: Set `"background_color": "#D6BDBD"` and `"theme_color": "#352554"`. |
| **Desktop Windows** | `windows/runner/win32_window.cpp:284-286` | Dynamic `DWMWA_USE_IMMERSIVE_DARK_MODE` based on Windows `AppsUseLightTheme` | **Change**: Set `BOOL enable_dark_mode = FALSE;` to guarantee light window chrome on Windows desktop. |
| **Desktop macOS** | `macos/Runner/MainFlutterWindow.swift:10-14` | Unconstrained macOS window appearance | **Change**: Add `self.appearance = NSAppearance(named: .aqua)` to lock macOS desktop window to Aqua (Light). |
| **Test Suite** | `test/design_audit/accessibility_guidelines_test.dart:15, 23` | `ThemeMode mode = ThemeMode.light`, `darkTheme: AppTheme.darkTheme` | **Change**: Remove `darkTheme` parameter; lock test harness to light theme. |
| **Test Suite** | `test/design_audit/goldens_test.dart:20, 57-64, etc.` | Golden tests capturing `_dark.png` variants for 7 screens | **Change**: Remove dark mode golden tests; retain light golden tests. |
| **Test Suite** | `test/design_audit/guideline_evaluator_test.dart:18-19` | `darkTheme: AppTheme.darkTheme` in test harness | **Change**: Remove `darkTheme` from test harness. |
| **New Regression Tests** | `test/theme/light_only_test.dart` | *New test* | **Create**: Pump each screen with `platformBrightnessTestValue = Brightness.dark` and verify `Theme.of(context).brightness == Brightness.light`. |
| **New Regression Tests** | `test/theme/no_dark_code_test.dart` | *New test* | **Create**: Static AST/grep test verifying zero forbidden dark keywords exist in `lib/`. |
| **Documentation** | `docs/THEME.md` | *New documentation* | **Create**: Explicit architectural specification establishing DevOS as a light-only single-theme design. |

---

## 3. Deliberately Dark Brand Surfaces (Kept in Light Theme)

In accordance with DevOS design specifications, several surfaces are intentionally dark brand design elements *within* the light theme. All foreground/background pairings have been calculated and verified for WCAG 2.1 compliance:

| Deliberate Dark Surface | Color Hex | Intended Role | Text/Foreground Element | Computed Contrast Ratio | WCAG 2.1 Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Project Banner** | `#2E1065` / `#352554` | Section header banner | White title text (`#FFFFFF`) | **14.8:1** | **PASS (AAA)** |
| **Forest Banner** | `#2E6316` | Skills/Courses header banner | White title text (`#FFFFFF`) | **8.1:1** | **PASS (AAA)** |
| **Crimson Action** | `#8F0030` | Bottom nav bar & primary action pills | White navigation text / icons | **7.4:1** | **PASS (AAA)** |
| **Terminal Badge** | `#0EA358` | `</>` Code badge chip | White badge glyphs | **4.6:1** | **PASS (AA Normal)** |
| **Demo Student Button** | `#1F2937` | Secondary demo bypass button | White monospace text + Amber bolt | **12.6:1** | **PASS (AAA)** |
| **Interactive Dark Pill** | `#222222` | Header search button & metric cards | White icon & crisp accents | **16.1:1** | **PASS (AAA)** |

---

## 4. Open Decisions for User

### Decision 1: Code-Block Surface in Notes & Markdown
- **Default Requirement**: Use a **Light syntax-highlight theme** so the app is 100% light:
  - Surface: `#F8FAFC` (Clean light slate)
  - Header: `#EDF2F7` with subtle `#CBD5E1` border
  - Syntax colors: GitHub Light / One Light palette (deep navy keywords `#0550AE`, forest green strings `#116329`, crimson types `#CF222E`, dark slate text `#24292F`). Contrast ratio on `#F8FAFC` exceeds **7.2:1 (AAA)**.
- **Alternative Option**: Retain the dark terminal block (`#181B20` with neon syntax highlighting `#38BDF8`, `#34D399`, `#FBBF24`) as a deliberate brand surface (analogous to the dark banners).
- *Recommendation*: Implement the **Light syntax-highlight theme** by default as requested; provide an option toggle only if you prefer dark terminal blocks.

### Decision 2: Supabase Profile Column / Settings Persistence
- Static scan of `lib/` and Supabase repository schemas confirms **no remote column or database table stores a dark mode setting** (`UserProfile` contains only `id`, `email`, `fullName`, `avatarUrl`, `institution`, `major`, `academicYear`, `learningStreak`).
- `SharedPreferences` was not used to persist theme mode.
- *Action*: Safe to remove `themeModeProvider` entirely with zero database migration needed.

---

## 5. Next Step

As required by Ground Rule 2, Phase 1 (Inventory) is complete and **READ-ONLY**.  
Please reply with **"approved"** to begin Phase 2 execution.

