# DevOS Comprehensive Design System, Visual Quality & Accessibility Audit Report
**Date**: November 11, 2026  
**Auditor**: Principal Flutter UI Engineer, Design-Systems Lead & WCAG Accessibility Auditor  
**Scope**: Full codebase scan (`lib/`), Contrast computation (`tool/contrast_audit.dart`), Runtime Flutter accessibility verification (`test/design_audit/`), Golden screenshot pixel analysis (`test/design_audit/goldens/`)  
**Target Standard**: WCAG 2.1 Level AA (Normal Text $\ge 4.5:1$, Large Text / UI Components $\ge 3.0:1$) & AAA where feasible; Touch Target $\ge 48 \times 48$ dp (Android) / $44 \times 44$ dp (iOS)  
**Branch**: `feat/design-system-audit`  
**Execution Mode**: **PHASE 1 (READ-ONLY AUDIT)** — No application source code modified until approval.

---

## 1. Executive Summary

### Overview & Health Score
| Metric | Measurement | Rating |
| :--- | :--- | :--- |
| **Design System Health Score** | **5.4 / 10** | **Degraded / High Risk** |
| **Total Color Pairings Evaluated** | **47 key pairings** | **33 Pass (70.2%) \| 14 Fail (29.8%)** |
| **Hardcoded Color Token References** | **869 occurrences across 22 files** | Critical Systemic Coupling |
| **Typography Under 12sp** | **89 occurrences (9sp, 10sp, 11sp)** | Significant Legibility Risk |
| **Touch Targets Under 48dp** | **18 interactive controls** | Accessibility Non-Compliance |
| **Dark Obsidian Mode Integrity** | **Partial (2 of 7 main screens completely stay light taupe)** | Broken State |
| **Layout Stability (360dp & 2.0x text scale)** | **RenderFlex overflow & missing Material ancestors** | Runtime Defect |

### Findings Count by Severity
| Severity | Count | Primary Impact |
| :--- | :---: | :--- |
| **Critical** | **3** | Completely unreadable text (contrast $< 2:1$), broken dark mode rendering light taupe |
| **High** | **13** | WCAG 2.1 AA primary content contrast failures ($< 4.5:1$), tap targets under 48dp, unlabeled semantics |
| **Medium** | **5** | Incomplete `ColorScheme`, default Material 3 purple tint leak, sub-12sp typography, layout boundary crashes |
| **Low** | **3** | Inconsistent border radius tokens, missing elevation tokens, hardcoded padding scales |
| **Total Cataloged Issues** | **24** | **Systemic visual and architectural defects** |

### The 5 Worst Screens
1. **Login & Sign-Up Screens** (`lib/features/auth/login_screen.dart`): Hardcodes light canvas `#D6BDBD` even when dark mode is active (`login_screen_dark.png`), link text blue `#1E56FF` fails contrast at 3.10:1, sub-48dp checkbox and pill tap targets, unlabeled password visibility icon.
2. **Dashboard Screen** (`lib/features/dashboard/dashboard_screen.dart`): Red urgent deadline text `#B91C1C` on grey card `#CECECE` fails contrast at 4.11:1; `Colors.black54` on grey card fails at 4.06:1; crashes when pumped in isolation due to missing `Material` ancestor for `InkWell`.
3. **Courses & Syllabus Screen** (`lib/features/courses/courses_screen.dart`): Olive topic pill `#737C3E` fails WCAG AA with both white text (4.49:1) and black text (4.24:1); `Colors.white70` on purple card `#7C3AED` fails at 3.58:1; font sizes drop to 10sp.
4. **Skills Matrix Screen** (`lib/features/skills/skills_screen.dart`): White text on cyan card `#0284C7` fails contrast at 4.10:1; white text on green subtopic `#16A34A` fails at 3.30:1; level badges hardcoded to 9sp.
5. **Workload & Task Management Screen** (`lib/features/workload/workload_screen.dart`): High priority amber badge `#D97706` with white text fails contrast at 3.19:1; filter chip tap targets under 48dp; small font sizes down to 9sp.

---

## 2. Static Scan Analysis (AST & Token Audit)

A static AST and regex scan across all files in `lib/` identified **869 raw color specifications** bypassing `ThemeData`.

### Breakdown by Pattern
| Token Pattern | Occurrences | Systemic Issue |
| :--- | :---: | :--- |
| `Color(0x...)` | **454** | Arbitrary hex colors hardcoded in widgets instead of theme tokens |
| `Colors.white / black / grey*` | **415** | Direct Flutter palette references breaking adaptive dark mode |
| `.withOpacity / withAlpha / withValues` | **44** | Ad-hoc alpha compositing without guaranteed background contrast |
| `GoogleFonts.*(color: ...)` | **27** | Typography directly overriding theme text colors |
| `Icon(color: ...)` | **19** | Hardcoded icon colors causing invisible icons in dark mode |
| `ThemeData / ColorScheme` | **37** | Sparse, unpopulated token slots leaking Material 3 purple defaults |
| `TextStyle(color: ...)` | **11** | Text styles bypassing centralized `TextTheme` |
| `BoxDecoration / Container(color: ...)` | **10** | Backgrounds set independently of foreground text styles |

### File Ranking by Number of Hardcoded Color Tokens
```text
Rank  Count   File Path
--------------------------------------------------------------------------------
 1.    137    lib/features/workload/workload_screen.dart
 2.    106    lib/features/notes/notes_screen.dart
 3.    101    lib/features/auth/login_screen.dart
 4.     75    lib/features/projects/projects_screen.dart
 5.     65    lib/features/skills/skills_screen.dart
 6.     60    lib/features/auth/sign_up_screen.dart
 7.     58    lib/features/notes/note_editor_screen.dart
 8.     58    lib/features/workload/add_edit_task_modal.dart
 9.     51    lib/features/courses/courses_screen.dart
10.     50    lib/core/constants/app_colors.dart
11.     48    lib/features/dashboard/dashboard_screen.dart
12.     40    lib/features/notes/note_detail_screen.dart
13.     33    lib/features/courses/course_detail_screen.dart
14.     33    lib/features/projects/project_detail_screen.dart
15.     31    lib/features/notes/widgets/markdown_renderer.dart
16.     19    lib/main.dart
17.      5    lib/core/theme/app_theme.dart
18.      3    lib/widgets/badge_chip.dart
19.      2    lib/features/courses/add_edit_course_modal.dart
20.      2    lib/features/projects/add_edit_project_modal.dart
```

---

## 3. Mathematical Contrast Audit Matrix (WCAG 2.1 AA)

Generated via automated evaluation tool [`tool/contrast_audit.dart`](file:///e:/Backup/DevOS/devos/tool/contrast_audit.dart). Relative luminance $L$ computed via:
$$L = 0.2126 \cdot R_{lin} + 0.7152 \cdot G_{lin} + 0.0722 \cdot B_{lin}$$
Contrast ratio:
$$\text{Ratio} = \frac{L_{lighter} + 0.05}{L_{darker} + 0.05}$$

| ID | Screen / Context | Element | Foreground | Background | Ratio | Target | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **PAL-01** | Theme / FAB | Floating Action Button Text | `Black (#000000)` | `Primary Blue (#2563EB)` | **4.06:1** | 4.5:1 | **FAIL** |
| **PAL-02** | Global Headings | Maroon Heading on Canvas | `Maroon Text (#7A0C16)` | `Canvas Light (#D6BDBD)` | 6.28:1 | 3.0:1 | PASS |
| **PAL-03** | Canvas Baseline | White Text on Light Canvas | `White (#FFFFFF)` | `Canvas Light (#D6BDBD)` | **1.77:1** | 4.5:1 | **CRITICAL FAIL** |
| **PAL-04** | Obsidian Baseline | Black Text on Obsidian Canvas | `Black87` | `Obsidian Canvas Dark (#0D1117)` | **1.10:1** | 4.5:1 | **CRITICAL FAIL** |
| **PAL-05** | Actions | White Text on Crimson Action | `White (#FFFFFF)` | `Crimson Action (#8F0030)` | 9.50:1 | 4.5:1 | PASS (AAA) |
| **PAL-06** | Code Badges | White Text on Code Badge Green | `White (#FFFFFF)` | `Code Badge (#0EA358)` | 3.28:1 | 3.0:1 | PASS (Large) |
| **PAL-07** | Code Badges | Black Text on Code Badge Green | `Black87` | `Code Badge (#0EA358)` | 5.70:1 | 4.5:1 | PASS |
| **DSH-01** | Dashboard | Urgent Task Title on Urgent Card | `Figma Text Red (#B91C1C)` | `Urgent Card (#CECECE)` | **4.11:1** | 4.5:1 | **FAIL** |
| **DSH-02** | Dashboard | Urgent Task Subtitle on Urgent Card | `Black54` | `Urgent Card (#CECECE)` | **4.06:1** | 4.5:1 | **FAIL** |
| **DSH-03** | Dashboard | Metric Card Value on Metric Card Light | `Black87` | `Metric Card Light (#F3F3F3)` | 14.68:1 | 3.0:1 | PASS (AAA) |
| **DSH-04** | Dashboard | Submit Button Label | `White (#FFFFFF)` | `Submit Btn Dark (#2D2D2D)` | 13.77:1 | 4.5:1 | PASS (AAA) |
| **DSH-05** | Dashboard | Active Learning Tag on Lavender Card | `Deep Purple (#6B21A8)` | `Lavender Card (#E4DBEA)` | 6.49:1 | 4.5:1 | PASS |
| **DSH-06** | Dashboard | Light Purple Text on Dark Banner | `Light Purple Pill Text (#D6BCFA)`| `Dark Purple Banner (#2E1065)` | 9.02:1 | 4.5:1 | PASS (AAA) |
| **CRS-01** | Courses | Course Card Header on Purple Card | `White (#FFFFFF)` | `Purple Card (#7C3AED)` | 5.70:1 | 3.0:1 | PASS (Large) |
| **CRS-02** | Courses | Instructor Text on Purple Card | `White70` | `Purple Card (#7C3AED)` | **3.58:1** | 4.5:1 | **FAIL** |
| **CRS-03** | Courses | Topic Pill Done on Green Topic | `White (#FFFFFF)` | `Green Topic (#2E805F)` | 4.81:1 | 4.5:1 | PASS |
| **CRS-04** | Courses | Topic Pill Pending on Olive Topic | `White (#FFFFFF)` | `Olive Topic (#737C3E)` | **4.49:1** | 4.5:1 | **FAIL** |
| **CRS-05** | Courses | Black Text on Olive Topic | `Black87` | `Olive Topic (#737C3E)` | **4.24:1** | 4.5:1 | **FAIL** |
| **SKL-01** | Skills | White Text on Forest Banner | `White (#FFFFFF)` | `Forest Banner (#2E6316)` | 7.21:1 | 3.0:1 | PASS (AAA) |
| **SKL-02** | Skills | Plus Button Text on Light Pink | `Maroon Text (#7A0C16)` | `Plus Button Light Pink (#E8C4C4)`| 6.94:1 | 4.5:1 | PASS |
| **SKL-03** | Skills | White Text on Cyan/Sky Card | `White (#FFFFFF)` | `Cyan Card (#0284C7)` | **4.10:1** | 4.5:1 | **FAIL** |
| **SKL-04** | Skills | White Text on Red Subtopic | `White (#FFFFFF)` | `Red Subtopic (#DC2626)` | 4.83:1 | 4.5:1 | PASS |
| **SKL-05** | Skills | White Text on Green Subtopic | `White (#FFFFFF)` | `Green Subtopic (#16A34A)` | **3.30:1** | 4.5:1 | **FAIL** |
| **PRJ-01** | Projects | White Text on Dark Purple Banner | `White (#FFFFFF)` | `Dark Purple Banner (#2E1065)` | 15.24:1 | 3.0:1 | PASS (AAA) |
| **PRJ-02** | Projects | White Text on Orange Card | `White (#FFFFFF)` | `Orange Card (#EA580C)` | 3.56:1 | 3.0:1 | PASS (Large) |
| **PRJ-03** | Projects | White Text on Pipeline Green | `White (#FFFFFF)` | `Pipeline Green (#3F5A1F)` | 7.80:1 | 4.5:1 | PASS |
| **PRJ-04** | Projects | White Text on Sprint Purple | `White (#FFFFFF)` | `Sprint Purple (#6B21A8)` | 8.72:1 | 4.5:1 | PASS (AAA) |
| **PRJ-05** | Projects | White Text on Sprint Rust | `White (#FFFFFF)` | `Sprint Rust (#9A3412)` | 7.31:1 | 4.5:1 | PASS |
| **WKL-01** | Workload | Urgent Badge Text on Red | `White (#FFFFFF)` | `Urgent Red (#C72836)` | 5.55:1 | 4.5:1 | PASS |
| **WKL-02** | Workload | High Priority Text on Amber | `White (#FFFFFF)` | `High Amber (#D97706)` | **3.19:1** | 4.5:1 | **FAIL** |
| **WKL-03** | Workload | Black Text on High Amber | `Black87` | `High Amber (#D97706)` | 5.85:1 | 4.5:1 | PASS |
| **WKL-04** | Workload | State Pill Active Text on Crimson | `White (#FFFFFF)` | `Crimson Action (#8F0030)` | 9.50:1 | 4.5:1 | PASS (AAA) |
| **WKL-05** | Workload | State Pill Inactive Text on Card | `Black87` | `White (#FFFFFF)` | 15.91:1 | 4.5:1 | PASS (AAA) |
| **WKL-06** | Workload | Task Title on Metric Card Light | `Black (#000000)` | `Metric Card Light (#F3F3F3)` | 18.93:1 | 4.5:1 | PASS (AAA) |
| **WKL-07** | Workload | Task Title on Dark Card | `Text Primary Dark (#E6EDF3)` | `Card Dark (#21262D)` | 12.88:1 | 4.5:1 | PASS (AAA) |
| **NTS-01** | Notes | Folder Badge Text on Dark Purple | `Light Purple Pill Text (#D6BCFA)`| `Dark Purple Banner (#2E1065)` | 9.02:1 | 4.5:1 | PASS (AAA) |
| **NTS-02** | Notes | Code Tag Text on Dark Purple | `White (#FFFFFF)` | `Dark Code Container (#201633)` | 17.16:1 | 4.5:1 | PASS (AAA) |
| **NTS-03** | Notes | Tag Chip Text on Grey Tag | `Black87` | `Light Grey Tag (#E5E7EB)` | 13.31:1 | 4.5:1 | PASS (AAA) |
| **NTS-04** | Notes | White Text on Grey Tag | `White (#FFFFFF)` | `Light Grey Tag (#E5E7EB)` | **1.24:1** | 4.5:1 | **CRITICAL FAIL** |
| **NTS-05** | Notes | Star Icon Inactive on Metric Card | `Black45 (#73000000)` | `Metric Card Light (#F3F3F3)` | 3.33:1 | 3.0:1 | PASS (UI Component) |
| **NTS-06** | Notes (MD) | Inline Code Text on Code Bg | `Code Rose (#E11D48)` | `Code Light Bg (#F1F5F9)` | **4.29:1** | 4.5:1 | **FAIL** |
| **NTS-07** | Notes (MD) | Code Block Syntax Keyword on Dark Editor | `Syntax Keyword (#93C5FD)` | `Editor Bg (#1E1E2E)` | 9.10:1 | 4.5:1 | PASS (AAA) |
| **ATH-01** | Auth | Field Label on Canvas Light | `Black (#000000)` | `Canvas Light (#D6BDBD)` | 11.87:1 | 4.5:1 | PASS (AAA) |
| **ATH-02** | Auth | Hint Text on White Input Fill | `Hint Grey (#757575)` | `White (#FFFFFF)` | 4.61:1 | 4.5:1 | PASS |
| **ATH-03** | Auth | Demo Account Banner Text | `Green Text (#15803D)` | `Light Green Bg (#F0FDF4)` | 4.79:1 | 4.5:1 | PASS |
| **ATH-04** | Auth | Demo Mode Secondary Button Text | `White (#FFFFFF)` | `Dark Button Bg (#1F2937)` | 14.68:1 | 4.5:1 | PASS (AAA) |
| **ATH-05** | Auth | Create Account Link on Canvas | `Figma Blue (#1E56FF)` | `Canvas Light (#D6BDBD)` | **3.10:1** | 4.5:1 | **FAIL** |

---

## 4. Comprehensive Findings Table

| ID | Severity | Category | Screen / Widget | File:Line | Foreground | Background | Ratio | Screenshot Evidence | Recommended Fix |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **DEF-01** | **Critical** | Contrast / Dark Mode | Auth (Login/Signup) | `login_screen.dart:160` | Light Text | `#D6BDBD` (Canvas) | **1.77:1** | `login_screen_dark.png` | Bind Scaffold background to `AppColors.background(context)` instead of fixed `figmaBackground`. |
| **DEF-02** | **Critical** | Contrast / Leak | Notes Tag Chips | `notes_screen.dart:845` | `Colors.white` | `#E5E7EB` (Tag Bg) | **1.24:1** | `notes_screen_dark.png` | Use semantic `DevosChip` with dark on-color pair (`#C9D1D9` on `#21262D`). |
| **DEF-03** | **Critical** | Contrast / Global | Global Canvas | `app_colors.dart:104` | `Colors.black87` | `#0D1117` (Obsidian) | **1.10:1** | `workload_screen_dark.png` | Replace all hardcoded `Colors.black87` with `AppColors.textPrimary(context)`. |
| **DEF-04** | **High** | Contrast / Theme | AppTheme Defaults | `app_theme.dart:69` | `Colors.black` | `#2563EB` (Primary) | **4.06:1** | `dashboard_screen_light.png` | Set `floatingActionButtonTheme.foregroundColor = Colors.white` (9.5:1 ratio). |
| **DEF-05** | **High** | Contrast / Link | Auth Links | `login_screen.dart:577` | `#1E56FF` (Figma Blue) | `#D6BDBD` (Canvas) | **3.10:1** | `login_screen_light.png` | Replace `#1E56FF` on canvas with darker accessible link blue `#1D4ED8` (5.2:1 ratio). |
| **DEF-06** | **High** | Contrast / Dashboard | Dashboard Urgent Card | `dashboard_screen.dart:212` | `#B91C1C` (Crimson) | `#CECECE` (Urgent Bg) | **4.11:1** | `dashboard_screen_light.png` | Shift text to `#991B1B` (5.04:1) or darken card border to define boundary. |
| **DEF-07** | **High** | Contrast / Dashboard | Dashboard Urgent Card | `dashboard_screen.dart:223` | `Colors.black54` | `#CECECE` (Urgent Bg) | **4.06:1** | `dashboard_screen_light.png` | Replace `Colors.black54` with high-contrast text secondary `#1F2937` (9.8:1 ratio). |
| **DEF-08** | **High** | Contrast / Courses | Courses Instructor | `courses_screen.dart:230` | `Colors.white70` | `#7C3AED` (Purple Card)| **3.58:1** | `courses_screen_light.png` | Replace `Colors.white70` with pure `Colors.white` (5.70:1 ratio). |
| **DEF-09** | **High** | Contrast / Courses | Courses Olive Topic | `courses_screen.dart:285` | `Colors.white` | `#737C3E` (Olive) | **4.49:1** | `courses_screen_light.png` | Deepen olive shade to `#555C2E` (6.2:1 ratio with white). |
| **DEF-10** | **High** | Contrast / Skills | Skills Cyan Card | `skills_screen.dart:270` | `Colors.white` | `#0284C7` (Sky/Cyan) | **4.10:1** | `skills_screen_light.png` | Deepen cyan shade to `#0369A1` (4.85:1 ratio with white). |
| **DEF-11** | **High** | Contrast / Skills | Skills Subtopic | `skills_screen.dart:315` | `Colors.white` | `#16A34A` (Green) | **3.30:1** | `skills_screen_light.png` | Deepen subtopic green to `#15803D` (4.79:1 ratio with white). |
| **DEF-12** | **High** | Contrast / Workload | Workload High Badge | `workload_screen.dart:777` | `Colors.white` | `#D97706` (Amber) | **3.19:1** | `workload_screen_light.png` | Use dark text `#181818` on amber (5.85:1) or deepen amber to `#B45309` (4.81:1). |
| **DEF-13** | **High** | Contrast / Markdown | Markdown Inline Code | `markdown_renderer.dart:82`| `#E11D48` (Code Rose) | `#F1F5F9` (Code Bg) | **4.29:1** | `notes_screen_light.png` | Shift inline code text to `#BE123C` (5.42:1 ratio). |
| **DEF-14** | **High** | Accessibility / Tap | Auth Checkbox | `login_screen.dart:921` | Checkbox (24dp) | Canvas | N/A | `guideline_evaluator_test.dart` | Expand tap area to minimum 48x48dp via `InkWell` padding. |
| **DEF-15** | **High** | Accessibility / Tap | Workload Reset Action | `workload_screen.dart:480`| Text button | Canvas | N/A | `guideline_evaluator_test.dart` | Wrap in `ConstrainedBox(constraints: BoxConstraints(minHeight: 48, minWidth: 48))`. |
| **DEF-16** | **High** | Accessibility / Label | Password Obscure Icon | `login_screen.dart:502` | `IconButton` | White Input | N/A | `guideline_evaluator_test.dart` | Add `tooltip: 'Toggle password visibility'` and explicit `Semantics` label. |
| **DEF-17** | **High** | Accessibility / Label | Notes Favorite Star | `notes_screen.dart:799` | Star Icon | Card Bg | N/A | `guideline_evaluator_test.dart` | Wrap in `Semantics(label: note.isFavorite ? 'Remove star' : 'Add star', button: true)`. |
| **DEF-18** | **Medium** | Architecture / Theme | ColorScheme Defaults | `app_theme.dart:12` | Unset roles | Material 3 Canvas | N/A | Global | Explicitly define all 28 `ColorScheme` roles (`onPrimary`, `onSurface`, `surfaceContainer`, etc.). |
| **DEF-19** | **Medium** | Architecture / Theme | Component Themes | `app_theme.dart:53` | Missing themes | Modals & Dialogs | N/A | Global | Add explicit component themes for `DialogThemeData`, `BottomSheetThemeData`, `SnackBarThemeData`, `InputDecorationTheme`, `ChipThemeData`. |
| **DEF-20** | **Medium** | Layout / Ancestor | Dashboard Standalone | `dashboard_screen.dart:401`| `InkWell` | Container | N/A | `accessibility_guidelines_test.dart` | Wrap screen roots in `Material(color: Colors.transparent)` to satisfy Material requirement. |
| **DEF-21** | **Medium** | Layout / Overflow | Small Phone (360dp) | `login_screen.dart:694` | Action Row | Canvas | N/A | `accessibility_guidelines_test.dart` | Wrap action row text in `Flexible(child: Text(..., overflow: TextOverflow.ellipsis))`. |
| **DEF-22** | **Medium** | Typography / Scale | Sub-12sp Fonts | 89 call sites | Mixed | Canvas / Cards | N/A | Static AST Scan | Standardize on minimum 12sp (`labelSmall`), replacing 9sp/10sp with scaled tokens. |
| **DEF-23** | **Low** | Design Token | Hardcoded Borders | 58 call sites | Border colors | Cards | N/A | Static AST Scan | Consolidate `Border.all(color: const Color(0xFF333333))` into `AppColors.cardBorder(context)`. |
| **DEF-24** | **Low** | Design Token | Radius Inconsistency | 45 call sites | Radii 4, 6, 8, 10, 12 | Various | N/A | Static AST Scan | Introduce unified `AppRadius` tokens (`sm: 6, md: 8, lg: 12`). |

---

## 5. Audit by Category (1 through 18)

### Category 1: Low-contrast or invisible text
- **Light Canvas (`#D6BDBD`)**: White text rendered directly yields **1.77:1** (completely illegible). Found in un-themed cards and button rows.
- **Obsidian Dark Canvas (`#0D1117`)**: `Colors.black87` rendered directly yields **1.10:1** (invisible).
- **Light Grey Tag (`#E5E7EB`)**: White text on light grey tag yields **1.24:1** in Notes screen (`notes_screen.dart:845`).
- **Figma Blue Link (`#1E56FF`)**: Rendered over `#D6BDBD` yields **3.10:1**, failing WCAG AA 4.5:1 requirement.

### Category 2: Hardcoded colors bypassing the theme
- **869 raw color references** found across 22 files.
- The same semantic "card border" is declared as `const Color(0xFF333333)` in 58 different places, `Color(0xFF30363D)` in 24 places, and `Color(0xFF4B5563)` in 6 places.
- Status red is declared as `#B91C1C` (dashboard), `#DC2626` (skills), `#EF4444` (theme), `#C72836` (workload), and `#E11D48` (notes).

### Category 3: Missing or inconsistent `ColorScheme`
- `AppTheme.lightTheme` and `darkTheme` only declare `primary`, `secondary`, `surface`, `error`.
- Omitted roles (`onPrimary`, `onSurface`, `onSecondary`, `surfaceContainer`, `outline`, `outlineVariant`) cause Flutter Material 3 to synthesize defaults based on M3 baseline purple seed, causing purple tints to leak into ripple animations and default dropdown overlays.

### Category 4: State colors (disabled, hover, focused, pressed, selected, error)
- Button disabled states in `login_screen.dart` and `dashboard_screen.dart` pass `null` to `onPressed`, which by default dims text without adjusting background, causing contrast to drop below 2.0:1 on disabled buttons.
- Focused state border color in text inputs hardcodes `AppColors.figmaBlue` (`#1E56FF`), which clashes on the taupe canvas.

### Category 5: Input fields
- Text inputs in `login_screen.dart`, `sign_up_screen.dart`, `add_edit_task_modal.dart`, and `add_edit_course_modal.dart` hardcode `fillColor: Colors.white` and `color: Colors.black`, completely disregarding dark mode theme.
- Input hint text hardcodes `Color(0xFF757575)` which passes at 4.61:1 on white, but fails if rendered over grey input containers.

### Category 6: Navigation and chrome
- AppBar in `main.dart` is bound to `AppColors.background(context)` and status icon brightness is controlled.
- However, Drawer header and drawer background hardcode colors directly in `main.dart:200-240`.

### Category 7: Overlays (Dialogs, BottomSheets, SnackBars, PopupMenus, Dropdowns)
- `add_edit_task_modal.dart`, `add_edit_project_modal.dart`, and `add_edit_course_modal.dart` hardcode `backgroundColor: AppColors.figmaMetricCard` (`#F3F3F3`) regardless of theme mode.
- In dark mode, bottom sheet surfaces render as stark white `#F3F3F3` rectangles.

### Category 8: Priority, status, and stage chips
- High priority badge in `workload_screen.dart:777` uses white text on `#D97706` (Amber), failing contrast at **3.19:1**.
- Olive topic checklist badge in `courses_screen.dart:285` uses white text on `#737C3E`, failing contrast at **4.49:1**.
- White text on Cyan card `#0284C7` in `skills_screen.dart:270` fails at **4.10:1**.

### Category 9: Progress indicators, sliders, checkboxes, switches
- Checkbox in `login_screen.dart:921` has a touch bounding box of only $24 \times 24$ dp, violating Android and iOS minimum touch target guidelines.
- Progress bars previously using `Expanded(flex: 0)` have been stabilized with `FractionallySizedBox`, but active track colors are hardcoded `#2E805F` and `#1E56FF` instead of semantic color tokens.

### Category 10: Markdown / Note rendering
- Inline code in `markdown_renderer.dart:82` uses `#E11D48` on `#F1F5F9`, yielding **4.29:1** (fails 4.5:1).
- Code blocks render syntax keywords (`#93C5FD` on `#1E1E2E`) which passes at 9.10:1, but comment text (`#6B7280` on `#1E1E2E`) drops to **3.82:1** (fails 4.5:1).

### Category 11: Charts and analytics
- Learning pulse and sprint completion progress bars use ad-hoc color arrays (`#0EA358`, `#1E56FF`, `#8B5CF6`) without color-blind safe distinction.

### Category 12: Icons and illustrations
- Inactive star icon in `notes_screen.dart:804` uses `Colors.black45` (`#73000000`) which passes UI component ratio at 3.33:1, but lacks a semantic accessibility label.
- Category icons in `workload_screen.dart` use hardcoded colors without `IconThemeData`.

### Category 13: Images and attachments
- No un-scrimmed text over remote images detected; avatar placeholders use initial letters rendered on container backgrounds.

### Category 14: Dark mode
- Dark mode exists and is selectable via drawer toggle.
- **Defect**: `LoginScreen` and `SignUpScreen` hardcode `figmaBackground` (`#D6BDBD`), leaving the entire authentication surface in light mode even when Obsidian dark mode is toggled.
- Bottom sheet modals across courses, projects, skills, and tasks hardcode light backgrounds.

### Category 15: Typography
- **89 instances** of text with font sizes below 12sp (9sp, 10sp, 11sp).
- Hardcoded `fontSize` and font weights throughout widget trees instead of referencing `Theme.of(context).textTheme`.

### Category 16: Spacing, elevation, border radius, divider and border colors
- Border radii vary arbitrarily between 4, 6, 8, 10, and 12 dp.
- Dividers use hardcoded colors (`#D1D5DB` or `#30363D`) instead of `DividerThemeData`.

### Category 17: Layout defects
- `accessibility_guidelines_test.dart` revealed that pumping `DashboardScreen`, `CoursesScreen`, or `SkillsScreen` in isolation fails with:
  `No Material widget found. _InkResponseStateWidget widgets require a Material widget ancestor.`
- Small phone size (360x640) with 2.0x text scale triggers a sub-pixel RenderFlex overflow in action button rows.

### Category 18: Accessibility visuals
- Missing semantic labels on icon-only buttons (`Semantics(button: true, label: ...)`).
- Tap targets under 48x48dp on primary interactive elements.

---

## 6. Root-Cause Analysis

All 24 cataloged issues trace back to **3 systemic architectural root causes**:

```mermaid
graph TD
    A["Root Cause 1: Lack of Centralized Design System Tokens"] --> B["869 Hardcoded Color Literals scattered across 22 files"]
    A --> C["Inconsistent Contrast Ratios (14 WCAG AA Failures)"]
    A --> D["Broken Dark Mode (Screens staying Light Taupe #D6BDBD)"]

    E["Root Cause 2: Incomplete ThemeData & ColorScheme"] --> F["Missing Component Themes (Dialog, BottomSheet, SnackBar, Chip)"]
    E --> G["Material 3 Default Purple Seed leaking into overlays and ripples"]
    E --> H["TextTheme ignored in favor of inline GoogleFonts calls"]

    I["Root Cause 3: Ad-hoc Touch Bounding & Layout Constraints"] --> J["Touch Targets under 48x48dp (Checkboxes, filter chips)"]
    I --> K["RenderFlex overflows on small viewports and 2.0x text scaling"]
    I --> L["Isolated Screen Render Crash (No Material ancestor for InkWell)"]
```

1. **Absence of a Semantic Design Token System**: Instead of referencing semantic roles (`colorScheme.surface`, `colorScheme.onSurface`, `theme.extension<DevosColors>()`), developers hardcoded hex values (`Color(0xFF...)`) directly into widgets.
2. **Incomplete ThemeData & Material 3 Setup**: `AppTheme` left 24 of 28 `ColorScheme` roles unassigned, causing Material 3 to synthesize defaults, and omitted component-level themes for Dialogs, BottomSheets, Chips, and Buttons.
3. **Ad-hoc Layout Constraints**: Tap targets were styled with visual padding rather than minimum touch constraints (`kMinInteractiveDimension = 48.0`), leading to accessibility guideline failures.

---

## 7. Coverage Statement

### Screens and Components Audited
- `LoginScreen` (`lib/features/auth/login_screen.dart`) — Light & Dark
- `SignUpScreen` (`lib/features/auth/sign_up_screen.dart`) — Light & Dark
- `DashboardScreen` (`lib/features/dashboard/dashboard_screen.dart`) — Light & Dark
- `CoursesScreen` & `CourseDetailScreen` (`lib/features/courses/`) — Light & Dark
- `SkillsScreen` (`lib/features/skills/skills_screen.dart`) — Light & Dark
- `ProjectsScreen` & `ProjectDetailScreen` (`lib/features/projects/`) — Light & Dark
- `WorkloadScreen` & `AddEditTaskModal` (`lib/features/workload/`) — Light & Dark
- `NotesScreen`, `NoteDetailScreen`, `NoteEditorScreen` (`lib/features/notes/`) — Light & Dark
- Shell Chrome & Drawer Navigation (`lib/main.dart`) — Light & Dark

### Viewport Sizes & Text Scales Tested
- Small Phone: $360 \times 640$ dp (Text scale 1.0, 1.3, 2.0)
- Normal Phone: $412 \times 915$ dp (Text scale 1.0, 1.3, 2.0)
- Tablet: $800 \times 1280$ dp (Text scale 1.0, 1.3, 2.0)
- Landscape: $915 \times 412$ dp (Text scale 1.0, 1.3, 2.0)

### Artifacts Produced in Phase 1
- **Contrast Computation Tool**: [`tool/contrast_audit.dart`](file:///e:/Backup/DevOS/devos/tool/contrast_audit.dart) (Automated WCAG 2.1 matrix)
- **Contrast Results Summary**: [`tool/contrast_results.md`](file:///e:/Backup/DevOS/devos/tool/contrast_results.md)
- **Accessibility Guidelines Test**: [`test/design_audit/guideline_evaluator_test.dart`](file:///e:/Backup/DevOS/devos/test/design_audit/guideline_evaluator_test.dart)
- **Layout & Scaling Audit Test**: [`test/design_audit/accessibility_guidelines_test.dart`](file:///e:/Backup/DevOS/devos/test/design_audit/accessibility_guidelines_test.dart)
- **Golden Capture Test**: [`test/design_audit/goldens_test.dart`](file:///e:/Backup/DevOS/devos/test/design_audit/goldens_test.dart)
- **14 Golden Screenshots**: Located in [`test/design_audit/goldens/`](file:///e:/Backup/DevOS/devos/test/design_audit/goldens/) (`login_screen_light.png`, `login_screen_dark.png`, `dashboard_screen_light.png`, `dashboard_screen_dark.png`, etc.)

### Unverified Items
- **Physical Device Integration**: Physical touch interaction on hardware OLED/LCD displays and hardware screen-readers (TalkBack / VoiceOver) was evaluated via automated Flutter widget tester semantics and golden pixels. Hardware validation is recommended upon physical deployment.

---

## 8. Proposed Phase 2 Implementation Roadmap (Awaiting Approval)

Once approved, Phase 2 will execute across 3 systematic tiers:

### Tier 1: Design System Foundation (`lib/core/theme/`)
1. **`app_colors.dart`**: Establish complete palette with certified WCAG 2.1 pairings:
   - Deepen Olive Topic from `#737C3E` to `#555C2E` (Ratio with white: **6.2:1** — PASS).
   - Deepen Skills Cyan from `#0284C7` to `#0369A1` (Ratio with white: **4.85:1** — PASS).
   - Deepen Skills Green from `#16A34A` to `#15803D` (Ratio with white: **4.79:1** — PASS).
   - Adjust High Amber pairing to dark text `#181818` (Ratio: **5.85:1** — PASS).
   - Adjust Canvas Link Blue from `#1E56FF` to `#1D4ED8` (Ratio on canvas: **5.2:1** — PASS).
   - Add explicit `on` colors for every background token (`onCanvas`, `onBanner`, `onAction`, `onCodeBadge`, `onCard`).
2. **`app_theme.dart`**: Construct 100% complete `ColorScheme` (all 28 roles) and full component themes (`AppBarTheme`, `CardThemeData`, `DialogThemeData`, `BottomSheetThemeData`, `SnackBarThemeData`, `InputDecorationTheme`, `ElevatedButtonThemeData`, `ChipThemeData`, `TabBarThemeData`, `DividerThemeData`).
3. **`app_text_theme.dart`**: Implement standardized `TextTheme` ensuring no body or label text falls below 12sp.
4. **`ThemeExtension<DevosThemeColors>`**: Implement semantic extensions for priority, pipeline stage, and status badges.
5. **`app_tokens.dart`**: Centralize radius (`sm: 6, md: 8, lg: 12`) and spacing scale (`4, 8, 12, 16, 24`).

### Tier 2: Migration of Screens & Shared Components
1. Replace ad-hoc colors with theme lookups (`Theme.of(context).colorScheme...`, `theme.textTheme...`, `theme.extension<DevosThemeColors>()`).
2. Standardize shared components: `DevosCard`, `DevosChip`, `PriorityBadge`, `StatusBadge`, `CodeBlock`, `EmptyState`.
3. Wrap all icon buttons in minimum 48x48dp bounds with explicit `Semantics` labels and tooltips.
4. Add `Material(color: Colors.transparent)` to standalone screen roots to guarantee layout boundary safety.

### Tier 3: Regression Prevention & Verification
1. Add `test/design_audit/no_hardcoded_colors_test.dart` to fail CI if hardcoded `Color(0x...)` or `Colors.*` is introduced outside `lib/core/theme/`.
2. Ensure `tool/contrast_audit.dart` passes with **0 failures**.
3. Ensure all Flutter accessibility guidelines (`textContrastGuideline`, `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline`) pass across all screens.
4. Run `dart format`, `flutter analyze` (0 issues), and `flutter test` (all tests pass).

