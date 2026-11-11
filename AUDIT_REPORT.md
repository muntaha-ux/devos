# DevOS System Audit Report

**Date of Audit**: November 10, 2026  
**Auditor**: Principal Flutter/Dart Engineer, Software Architect, QA Lead & Security Reviewer  
**Target Codebase**: `E:\Backup\DevOS\devos`  
**Flutter SDK**: 3.47.0 (Dart 3.13.0, Channel stable)  
**Host Platform**: Windows 11 Version 2009 (Build 26100.3323)  

---

## 1. Executive Summary

### Overall Health Score: 6.2 / 10
* **Completion Estimate**: ~70% (Workload & Task Management, Markdown Notes & Knowledge Base, and Auth UI are implemented; Dashboard, Courses, Skills, and Projects contain substantial hardcoded mock data and UI bugs; Calendar, Goals, Research, and Analytics screens are currently deleted/orphaned from navigation; Cloudflare R2 storage is not implemented).
* **Test Coverage**: 35.87% line coverage (1,559 / 4,346 lines instrumented across 17 passing tests; zero unit tests for repositories, models, providers, or detail views).
* **Code Formatting**: 40 of 44 Dart files fail standard formatting (`dart format --set-exit-if-changed`).

### Top 5 Risks
1. **Plaintext Secrets in Version Control (SEC-01)**: The production Supabase URL and live JWT `anon` key are hardcoded directly in `lib/core/constants/supabase_config.dart` and committed to git history.
2. **Missing Android Release Internet Permission (PLT-01)**: `android/app/src/main/AndroidManifest.xml` omits `<uses-permission android:name="android.permission.INTERNET"/>` (only present in debug manifest), guaranteeing that all network and Supabase calls will fail immediately on release Android builds.
3. **Deterministic UI Crash on 0% and 100% Progress (BUG-01)**: `courses_screen.dart` and `skills_screen.dart` pass `0` to `Expanded(flex: ...)` whenever a course or skill has 0% or 100% progress, causing Flutter runtime `AssertionError: flex > 0` crashes.
4. **Silent Exception Swallowing across Data Layer (ASY-01)**: `supabase_database_repository.dart` contains 35 instances of bare `catch (_)` blocks that conceal network drops, PostgreSQL schema violations, and authentication errors from the UI, giving users a false illusion of persistence.
5. **Hardcoded Mock Fallbacks & Broken List Rendering (BUG-02 & BUG-03)**: `ProjectsScreen` and `CoursesScreen` only render the first item in the collection and hide all subsequent user-created items; `DashboardScreen` displays fake hardcoded progress (70%, 4.6 hours, 43%) and has a dummy "Submit" button that only triggers a SnackBar.

### Honest Verdict
DevOS has a compelling visual identity and two feature-complete, well-tested core screens (`WorkloadScreen` and `NotesScreen`), but it is currently crippled by architectural shortcuts, severe release-configuration oversights, and fragile UI-to-database bindings. The project exhibits classic "prototype debt": database errors are caught and discarded, list views only display the first record, release builds are signed with debug keystores, and credentials sit in plain text. With a disciplined stabilization pass (Phase 0) followed by feature unification and domain-layer decoupling, DevOS can become a resilient, production-grade academic operating system.

---

## 2. Project Overview

### Purpose & Architecture Map
DevOS is an integrated personal engineering and academic operating system designed for computer science and engineering students. Its architectural mandate connects syllabus tracking, software projects, developer workloads, markdown technical notes, and academic goals into a unified workspace.

```
+---------------------------------------------------------------------------------------+
|                                    PRESENTATION LAYER                                 |
|  +---------------------------------------------------------------------------------+  |
|  | DevOSMainShell (main.dart)                                                      |  |
|  |  +--------------------+ +--------------------+ +-----------------------------+  |  |
|  |  | DashboardScreen    | | CoursesScreen      | | WorkloadScreen              |  |  |
|  |  | (Metrics, Urgent)  | | (Syllabus, Topics) | | (Tasks, Filters, Modals)    |  |  |
|  |  +--------------------+ +--------------------+ +-----------------------------+  |  |
|  |  +--------------------+ +--------------------+ +-----------------------------+  |  |
|  |  | SkillsScreen       | | ProjectsScreen     | | NotesScreen                 |  |  |
|  |  | (Matrix, Mastery)  | | (Pipelines, Repos) | | (Markdown, Folders, Tags)   |  |  |
|  |  +--------------------+ +--------------------+ +-----------------------------+  |  |
|  +---------------------------------------------------------------------------------+  |
|                                         |                                             |
|                                    WATCH / READ                                       |
|                                         v                                             |
+---------------------------------------------------------------------------------------+
|                                   APPLICATION LAYER                                   |
|  +---------------------------------------------------------------------------------+  |
|  | app_providers.dart (God Notifiers)                                              |  |
|  | ProfileNotifier | CoursesNotifier | SkillsNotifier | ProjectsNotifier           |  |
|  | TasksNotifier   | GoalsNotifier   | NotesNotifier  | ResearchNotifier | Events  |  |
|  +---------------------------------------------------------------------------------+  |
+---------------------------------------------------------------------------------------+
|                                  INFRASTRUCTURE / DATA                                |
|  +---------------------------------------+  +--------------------------------------+  |
|  | SupabaseAuthRepository                |  | SupabaseDatabaseRepository           |  |
|  | (GoTrue Client, Profiles Upsert)      |  | (PostgREST Client, In-Memory Mocks)  |  |
|  +---------------------------------------+  +--------------------------------------+  |
|                     |                                          |                      |
|                     +--------------------+---------------------+                      |
|                                          v                                            |
|                       Supabase Cloud (PostgreSQL + Auth)                              |
+---------------------------------------------------------------------------------------+
```

### Tech Stack
* **Framework**: Flutter 3.47.0 (Dart 3.13.0)
* **Target Platforms**: Android, iOS, Web, Desktop (Windows, macOS, Linux)
* **State Management**: `flutter_riverpod` ^2.5.1 (legacy StateNotifier pattern)
* **Backend & Auth**: `supabase_flutter` ^2.5.0 (PostgreSQL, GoTrue, Realtime)
* **Storage**: Documented for Cloudflare R2; currently unintegrated
* **Typography & UI**: `google_fonts` (JetBrains Mono, Inter), `percent_indicator`, `fl_chart`, `flutter_animate`

---

## 3. Findings Table

| ID | Severity | Category | Title | File:Line | Evidence | Why it matters | Recommended fix | Effort |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **SEC-01** | **Critical** | H | Hardcoded Supabase URL & JWT Anon Key in VCS | `lib/core/constants/supabase_config.dart:2-4` | `static const String supabaseAnonKey = 'eyJhbGci...';` | Credential leak; enables API quota abuse and unauthorized database scraping. | Move credentials to compile-time `--dart-define` or `.env` file ignored by git. | S |
| **PLT-01** | **Critical** | L | Missing Internet Permission in Main Android Manifest | `android/app/src/main/AndroidManifest.xml:1-45` | Missing `<uses-permission android:name="android.permission.INTERNET"/>` | Release Android builds will immediately fail all network and Supabase requests. | Add `android.permission.INTERNET` to `src/main/AndroidManifest.xml`. | S |
| **SEC-02** | **Critical** | H & L | Release Build Configured with Debug Keystore | `android/app/build.gradle.kts:36` | `signingConfig = signingConfigs.getByName("debug")` | Security hole; rejected by Google Play; APK can be spoofed or tampered with. | Configure release signing block using `key.properties` and keystore file. | M |
| **BUG-01** | **High** | B & A | `Expanded(flex: 0)` Crash on 0% or 100% Progress | `lib/features/courses/courses_screen.dart:197,201`<br>`lib/features/skills/skills_screen.dart:345,349` | `flex: percentage,`<br>`flex: 100 - percentage,` | Flutter `Expanded` asserts `flex > 0`. Any 0% or 100% course or skill crashes app. | Use `FractionallySizedBox` or clamp `flex: math.max(1, percentage)`. | S |
| **BUG-02** | **High** | B | Courses & Projects Screens Ignore Items Beyond Index 0 | `lib/features/courses/courses_screen.dart:27,245`<br>`lib/features/projects/projects_screen.dart:27,236` | `final featuredCourse = courses.firstOrNull;`<br>`final featuredProject = projects.firstOrNull;` | User creates multiple courses or projects, but only 1st item appears; rest are invisible. | Replace single featured card with dynamic `ListView.builder` iterating all items. | M |
| **BUG-03** | **High** | B | Hardcoded Mock Data & Dummy Submit Action on Dashboard | `lib/features/dashboard/dashboard_screen.dart:19-20,71-79,121,141` | `value: '70%'`, `value: '4.6 Hours'`, `content: Text('DSA Assignment 2 submitted successfully!')` | Misleading analytics; user submission does not update task status or database. | Hook dashboard metrics dynamically to `tasksProvider` and `projectsProvider`. | M |
| **ASY-01** | **High** | C & I | Swallowing 35 Unlogged Exceptions in Database Repository | `lib/repositories/supabase_database_repository.dart` (35 instances) | `} catch (_) { return []; }`<br>`} catch (_) {}` | Hides PostgreSQL errors, RLS policy violations, and network failures from users. | Implement structured error handling, logging, and user feedback through `Result<T>`. | L |
| **ARC-01** | **High** | D | Monolithic Repository & Provider God-Classes | `lib/repositories/supabase_database_repository.dart` (971 lines)<br>`lib/providers/app_providers.dart` (436 lines) | Single file manages 9 domains with mixed DB calls, mock fallbacks, and state. | High coupling, impossible to unit test, violates Single Responsibility Principle. | Split repository and notifiers into domain-specific modules per feature. | L |
| **ARC-02** | **High** | D & C | Constructor Async Side-Effects Trigger Race Conditions | `lib/providers/app_providers.dart:56,87,151,215,280,332,397,446,480` | `CoursesNotifier(...) : super([]) { loadCourses(); }` | Notifiers query database before initial seed completes; triggers unawaited queries on boot. | Remove async calls from constructors; use Riverpod `AsyncNotifier` / explicit load. | M |
| **DAT-01** | **High** | I & B | Broken Relational Joins & Inability to Have Zero Tasks | `lib/repositories/supabase_database_repository.dart:413-426` | `.select()` without joins; `if (list.isEmpty) return _defaultSampleTasks;` | Task course/project names null in Supabase; empty task list reset to defaults on reopen. | Add PostgREST select join `courses(name), projects(title)`; do not overwrite empty list. | M |
| **FMT-01** | **Medium** | A & M | 40 of 44 Files Fail `dart format` Formatting | Workspace-wide (`lib/`, `test/`) | `Formatted 44 files (40 changed) in 2.02 seconds.` | Inconsistent whitespace, unreadable git diffs, fails standard CI format gates. | Run `dart format .` and enforce formatting in CI workflow. | S |
| **DEP-01** | **Medium** | K & A | Outdated Packages & Deprecated Member Annotations | `pubspec.yaml:35-43`<br>`lib/main.dart:23` | `// ignore: deprecated_member_use`<br>`flutter_riverpod: ^2.5.1` (3.5 available) | Technical debt; security vulnerabilities; eventual breaking changes. | Upgrade dependencies incrementally (`supabase_flutter`, `riverpod`, `fl_chart`). | M |
| **LNT-01** | **Medium** | J & A | Missing Strict Analysis Rules in `analysis_options.yaml` | `analysis_options.yaml:10-36` | Only `package:flutter_lints/flutter.yaml`; no strict type flags | Permissive casting, implicit dynamic types, silent null-safety gaps pass compiler. | Enable `strict-casts`, `strict-inference`, and `strict-raw-types`. | S |
| **UIX-01** | **Medium** | F | 310 Inline Raw Hex Colors & Ineffective Dark Mode | `lib/` (310 instances)<br>`lib/main.dart:154` | `Color(0xFFD6BDBD)` hardcoded; `DevOSMainShell` forces light background | Dark mode toggle is non-functional; inconsistent color usage across app. | Centralize semantic color tokens in `AppTheme` and read via `Theme.of(context)`. | L |
| **UIX-02** | **Medium** | F | Visual Schism Between Figma Screens & Material Details | `lib/features/courses/course_detail_screen.dart`<br>`lib/features/projects/project_detail_screen.dart` | Material 3 Dark Card styling vs Figma Light Taupe/Rose main screens | Disorienting user experience; detail views look like a completely different application. | Redesign detail modals and screens to match Figma design tokens and palette. | M |
| **ACC-01** | **Medium** | G | Tap Targets Under 48x48dp & Low Contrast Text | `lib/main.dart:224` (38x38dp)<br>`lib/features/skills/skills_screen.dart:103` (32x32dp) | `Container(width: 32, height: 32)` | Violates WCAG 2.1 Level AA and Material guidelines; difficult to tap on mobile. | Ensure all touch targets meet minimum 48x48dp interactive bounding box. | S |
| **ACC-02** | **Medium** | G | Missing Accessibility Semantics & Screen Reader Support | `lib/widgets/`, `lib/features/` | Custom `InkWell` containers without `Semantics` or tooltips | Screen readers cannot convey button purpose or action to visually impaired users. | Add `Semantics(label: ...)` and `tooltip` to all custom interactive controls. | M |
| **TST-01** | **Medium** | J | Low Test Coverage (35.87%) & Zero Layer Unit Tests | `test/` (17 tests total) | No tests for Repositories, Notifiers, Dashboard, Courses, Skills, Projects | High regression risk during refactoring; unverified database mapping logic. | Add unit tests for repositories (with mocks) and state notifiers to reach >=70%. | L |
| **PER-01** | **Medium** | E | Giant 500+ Line `build()` Methods Triggering Broad Rebuilds | `lib/features/workload/workload_screen.dart:98`<br>`lib/features/notes/notes_screen.dart:108` | Monolithic `build()` methods creating hundreds of nested widgets | Excessive widget rebuilds; UI lag on low-end mobile devices during scrolling/search. | Extract modular sub-widgets with `const` constructors. | M |
| **PER-02** | **Medium** | E | Non-Lazy Markdown Parser Inside Column Freezes UI | `lib/features/notes/widgets/markdown_renderer.dart:20-23` | `Column(children: blocks.map(...).toList())` | Entire note parsed and inflated on main thread; large notes drop frames. | Use `ListView.builder` with lazy block rendering for markdown content. | M |
| **DAT-02** | **Medium** | I | Non-UUID ID Generation Causes PostgreSQL Syntax Errors | `lib/features/skills/skills_screen.dart:50-54` | `id: DateTime.now().millisecondsSinceEpoch.toString()` | PostgreSQL UUID primary key rejected on insert; sub-topic persistence fails. | Use `const Uuid().v4()` for all entity identifier generation. | S |
| **DAT-03** | **Medium** | I | Complete Absence of Offline Data Caching / Sync Queue | `lib/repositories/supabase_database_repository.dart` | Mutations require active internet; offline writes vanish | App unusable without continuous internet; network blips cause data loss. | Implement local SQLite / Hive caching layer with optimistic write-sync queue. | L |
| **FAL-01** | **Low** | B & C | Use of Deactivated `BuildContext` After Route Pop | `lib/features/notes/note_detail_screen.dart:58-59` | `Navigator.pop(context); ScaffoldMessenger.of(context)...` | Accessing popped context can throw runtime `deactivated widget` error. | Capture `scaffoldMessenger = ScaffoldMessenger.of(context)` before popping route. | S |
| **LOC-01** | **Low** | F | Complete Absence of Localization (i18n) | Workspace-wide | Hundreds of hardcoded user-facing English strings | Cannot support multi-language; strings difficult to audit for typos. | Introduce `flutter_localizations` and `.arb` string resource catalogs. | M |
| **PLT-02** | **Low** | L | Default Template Package Name & Missing App Identity | `android/app/build.gradle.kts:8,19` | `namespace = "com.example.devos"`, `applicationId = "com.example.devos"` | Cannot deploy to Google Play Store; shows generic Flutter icon. | Update namespace to `com.devos.app`, generate launcher icons with `flutter_launcher_icons`. | S |
| **PLT-03** | **Low** | L | Absence of Crash Reporting & Release ProGuard/R8 Rules | `android/app/build.gradle.kts` | No Sentry/Firebase Crashlytics; no ProGuard obfuscation rules | Production crashes go undetected; code reverse-engineerable. | Add Sentry SDK and configure `proguard-rules.pro` for Android release. | M |
| **DOC-01** | **Low** | M | Default Template README & Missing CI/CD Workflows | `README.md:1-17` | Standard template text: "This project is a starting point for a Flutter application." | Difficult onboarding; no automated PR checks or regression gates. | Rewrite README with setup steps; add GitHub Actions CI workflow for test/analyze. | S |
| **COD-01** | **Low** | A | Dead Code in Widgets Directory | `lib/widgets/section_header.dart`<br>`lib/widgets/streak_badge.dart` | Declared widgets with zero usages in codebase | Unnecessary codebase clutter; misleading maintenance surface. | Integrate widgets where appropriate or safely remove them. | S |
| **INF-01** | **Info** | D | Absence of Dependency Injection Abstraction | `lib/providers/app_providers.dart:17-24` | Direct constructor instantiation inside providers | Harder to swap mock repositories during integration testing. | Keep interface bindings clean and introduce Riverpod overrides for tests. | S |
| **INF-02** | **Info** | K | Missing Environment Flavors (Dev / Staging / Production) | Root workspace | Single configuration pointing to production database | Risk of corrupting production data during manual testing. | Introduce `dev`, `staging`, and `prod` flavor configurations. | M |
| **INF-03** | **Info** | I | Cloudflare R2 File Storage Not Implemented | `description.md:49-50` | Spec mentions R2 object storage for PDFs/images; zero code exists | Inability to attach assignment PDFs, project screenshots, or notes files. | Integrate AWS S3 / Minio client configured for Cloudflare R2 bucket. | L |
| **INF-04** | **Info** | B | Orphaned Models for Deleted Features (Calendar, Goals, Research, Analytics) | `lib/models/event_model.dart`<br>`lib/models/goal_model.dart`<br>`lib/models/research_model.dart` | Models and repo methods exist, but UI screens were deleted | Partial feature decay; unused schema overhead. | Re-implement modern Figma-styled screens for Calendar, Goals, and Research. | L |

---

## 4. Detailed Findings by Category

### Category A: Build and Compile Health
* **Evidence**: `lib/main.dart:23` uses deprecated `anonKey: SupabaseConfig.supabaseAnonKey` suppressed with `// ignore: deprecated_member_use`. `pubspec.yaml` uses `flutter_lints: ^6.0.0` but lacks strict analyzer configurations.
* **Evidence**: Running `dart format --output=none --set-exit-if-changed .` flags 40 files requiring whitespace and formatting corrections across `lib/` and `test/`.
* **Dead Code**: `lib/widgets/section_header.dart` and `lib/widgets/streak_badge.dart` are defined but never referenced anywhere in `lib/`.

```dart
// lib/main.dart:21-25
await Supabase.initialize(
  url: SupabaseConfig.supabaseUrl,
  // ignore: deprecated_member_use
  anonKey: SupabaseConfig.supabaseAnonKey,
);
```

### Category B: Functional Bugs and Logic Errors
* **Evidence**: In `courses_screen.dart:197-201` and `skills_screen.dart:345-349`, progress percentages are passed directly to `Expanded(flex: percentage)`. When `percentage == 0`, `Expanded(flex: 0)` triggers `AssertionError: flex > 0` and crashes the UI. When `percentage == 100`, the remainder `100 - percentage == 0` causes the same crash.
* **Evidence**: In `courses_screen.dart:27` and `projects_screen.dart:27`, only `featuredCourse = courses.firstOrNull` is displayed. The rest of the user's courses and projects are completely omitted from the UI.
* **Evidence**: `dashboard_screen.dart:71-79` has a "Submit" button inside the Urgent Deadline card that shows a hardcoded SnackBar without changing any state or sending any update to Supabase.
* **Evidence**: `dashboard_screen.dart:19-20` forces `displayCompleted = 3` and `totalTasks = 5` when `tasks` is empty, falsifying metrics.

```dart
// lib/features/skills/skills_screen.dart:344-351
Expanded(
  flex: percentage, // CRASHES if percentage == 0!
  child: Container(color: AppColors.figmaPink),
),
Expanded(
  flex: 100 - percentage, // CRASHES if percentage == 100!
  child: Container(color: const Color(0xFF222222)),
),
```

### Category C: Async and Error Handling
* **Evidence**: `lib/repositories/supabase_database_repository.dart` contains 35 bare `catch (_)` blocks that silently return empty lists `[]` or null, disguising database crashes, DNS errors, and table missing errors.
* **Evidence**: `lib/features/notes/note_detail_screen.dart:58-59` executes `Navigator.pop(context)` and immediately calls `ScaffoldMessenger.of(context)` using the deactivated widget context.

```dart
// lib/repositories/supabase_database_repository.dart:98-108
try {
  final response = await _client
      .from('courses')
      .select('*, course_topics(*)')
      .eq('user_id', userId)
      .order('created_at', ascending: false);
  return (response as List).map((c) => Course.fromJson(c)).toList();
} catch (_) {
  return []; // Silent swallow: caller never knows why it failed!
}
```

### Category D: State Management and Architecture
* **Evidence**: `lib/providers/app_providers.dart` is a 436-line god-file housing 9 distinct notifiers. Every notifier initiates an unawaited async database fetch inside its constructor (`ProfileNotifier`, `CoursesNotifier`, `SkillsNotifier`, `ProjectsNotifier`, `TasksNotifier`, `GoalsNotifier`, `NotesNotifier`, `ResearchNotifier`, `EventsNotifier`).
* **Evidence**: `syncWorkspaceProvider` (lines 513-525) calls `seedInitialWorkspaceDataIfEmpty()` followed by reloads. Because notifiers query empty tables in their constructors during app startup, a race condition exists between the initial query and the seed script.
* **Evidence**: `lib/repositories/supabase_database_repository.dart` combines data access with hardcoded mock fallback data (`_defaultSampleTasks`, `_defaultSampleCourses`).

### Category E: Performance
* **Evidence**: `workload_screen.dart` (1,052 lines) and `notes_screen.dart` (941 lines) contain monolithic `build()` methods creating hundreds of nested widgets on every state update.
* **Evidence**: `markdown_renderer.dart:20-23` renders markdown blocks inside a standard `Column(children: blocks.map(...).toList())`. When viewing large notes (500+ lines), all widgets are created simultaneously on the main thread, causing frame drops.

### Category F: UI/UX and Professionalism
* **Evidence**: The codebase contains 310 raw hex color literals (`Color(0x...)`) completely bypassing `Theme.of(context)` and `AppTheme`.
* **Evidence**: `DevOSMainShell` (`main.dart:154`) hardcodes `backgroundColor: AppColors.figmaBackground` (`#D6BDBD`), preventing dark mode from applying to the scaffold body.
* **Evidence**: Sharp visual disconnect: `CourseDetailScreen` and `ProjectDetailScreen` are styled using dark Material cards and standard text themes, directly conflicting with the custom Figma aesthetic of the primary dashboard and workload screens.

### Category G: Accessibility
* **Evidence**: The top bar search button (`main.dart:224`) has dimensions of 38x38dp; the skill addition button (`skills_screen.dart:103`) has dimensions of 32x32dp. Both violate the WCAG 2.1 48x48dp minimum touch target size.
* **Evidence**: `DashboardScreen:223` renders text with `AppColors.figmaTextRed.withValues(alpha: 0.45)` over a light lavender card, resulting in a contrast ratio of ~2.1:1 (failing the 4.5:1 WCAG AA minimum).
* **Evidence**: Custom interactive cards and chips lack `Semantics` wrappers and `tooltip` definitions for accessibility services.

### Category H: Security and Privacy
* **Evidence**: `lib/core/constants/supabase_config.dart:2-4`:
```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://vfwfgryfhbrozihqtlwt.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZmd2ZncnlmaGJyb3ppaHF0bHd0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODcyMDE3OTYsImV4cCI6MjEwMjc3Nzc5Nn0.y4LOUaIilXkPaEcOHSNGnHaf1_iK3lS-zfGAc1WWdXU';
}
```
* **Evidence**: `android/app/build.gradle.kts:36`: The release buildType uses `signingConfig = signingConfigs.getByName("debug")`.
* **Evidence**: Lack of `flutter_secure_storage` for session tokens or sensitive user credentials.

### Category I: Data Layer and Networking
* **Evidence**: `supabase_database_repository.dart:413-426`: `getTasks()` queries `tasks` with `.select()` but omits relational joins with `courses` and `projects`. Consequently, `relatedCourseName` and `relatedProjectName` are always null in Supabase responses.
* **Evidence**: In `getTasks()`, `if (list.isEmpty) return _defaultSampleTasks;` guarantees that if a user deletes or finishes all tasks, the default sample tasks are reloaded every time the app opens.
* **Evidence**: In `skills_screen.dart:51`, new sub-topics generate IDs using `DateTime.now().millisecondsSinceEpoch.toString()`. The PostgreSQL schema (`schema.sql:84`) defines `id UUID PRIMARY KEY DEFAULT uuid_generate_v4()`, causing an invalid UUID syntax error upon insert.
* **Evidence**: Zero offline queuing: if an insert/update occurs during network downtime, it fails silently and the change is lost.

### Category J: Testing and Quality Gates
* **Evidence**: 17 tests exist across 4 files (`dropdown_test.dart`, `notes_test.dart`, `widget_test.dart`, `workload_test.dart`).
* **Evidence**: Total Line Coverage is **35.87%** (1,559 / 4,346 lines instrumented).
* **Evidence**: Zero tests exist for `SupabaseAuthRepository`, `SupabaseDatabaseRepository`, `CoursesScreen`, `SkillsScreen`, `ProjectsScreen`, `DashboardScreen`, or any data models.
* **Evidence**: In `test/widget_test.dart:8`, pumpWidget triggers an uninitialized Supabase assertion warning in the test runner console because client mocks are not configured.

### Category K: Dependencies and Configuration
* **Evidence**: `flutter pub outdated` identifies 7 direct dependencies constrained below resolvable releases:
  - `flutter_riverpod`: *2.6.1 -> 3.5.0
  - `fl_chart`: *0.68.0 -> 1.3.1
  - `google_fonts`: *6.3.3 -> 9.0.0
  - `intl`: *0.19.0 -> 0.20.3
  - `supabase_flutter`: *2.17.2 -> 2.18.3
  - `table_calendar`: *3.1.3 -> 3.3.0
  - `cupertino_icons`: *1.0.9 -> 2.0.0
* **Evidence**: `.gitignore` lacks entries for `.env`, `*.jks`, `key.properties`, and `.flutter-plugins-dependencies` is tracked.

### Category L: Platform and Release Readiness
* **Evidence**: Android package ID is left as default `com.example.devos` (`android/app/build.gradle.kts:8, 19`).
* **Evidence**: `android/app/src/main/AndroidManifest.xml` lacks the `android.permission.INTERNET` permission required for release builds.
* **Evidence**: App icon and splash screen are Flutter defaults.
* **Evidence**: No crash reporting (Sentry/Firebase Crashlytics) or analytics integration.

### Category M: Documentation and Maintainability
* **Evidence**: `README.md` is 17 lines of the default Flutter scaffolding template.
* **Evidence**: No GitHub Actions or CI/CD pipelines defined (`.github/workflows` missing).
* **Evidence**: High onboarding barrier due to god-files and hidden credential setup requirements.

---

## 5. Root-Cause Analysis

```
+--------------------------------------------------------------------------------------------------+
|                                      SYSTEMIC ROOT CAUSES                                        |
+--------------------------------------------------------------------------------------------------+
                                  |                                       |
                                  v                                       v
         +----------------------------------+       +------------------------------------+
         | ROOT CAUSE 1:                    |       | ROOT CAUSE 2:                      |
         | "Demo-First" Prototyping Debt    |       | God-Class Monolithic Architecture  |
         +----------------------------------+       +------------------------------------+
                          |                                           |
         +----------------+----------------+         +----------------+----------------+
         |                                 |         |                                 |
         v                                 v         v                                 v
   [BUG-02, BUG-03]                  [ASY-01, DAT-01]  [ARC-01, ARC-02]               [PER-01]
Hardcoded 1st items &             Silent error        God repository & god notifiers  500-line build
faked metrics to mimic UI         swallowing to       with unawaited async calls      methods causing broad
design screenshot.                prevent crashes.    in constructors.                rebuilds.

                                  |                                       |
                                  v                                       v
         +----------------------------------+       +------------------------------------+
         | ROOT CAUSE 3:                    |       | ROOT CAUSE 4:                      |
         | Release Configuration Omission   |       | Missing Quality & Testing Gates    |
         +----------------------------------+       +------------------------------------+
                          |                                           |
         +----------------+----------------+         +----------------+----------------+
         |                                 |         |                                 |
         v                                 v         v                                 v
   [SEC-01, PLT-01, SEC-02]          [PLT-02]        [TST-01, LNT-01, FMT-01]         [BUG-01]
Plaintext keys in VCS;            Default package    35% coverage; permissive lint;   Expanded(flex: 0)
debug keystore & missing          ID com.example.    40 files unformatted; zero       assertions slipping
Internet permission in main.      devos.             unit tests for data layer.       into release.
+--------------------------------------------------------------------------------------------------+
```

---

## 6. Missing Features & Incomplete Work

1. **Academic Calendar & Deadlines**: Screen was deleted from `lib/features/calendar/`; data model exists (`event_model.dart`), but no active navigation route or UI calendar view is accessible.
2. **Personal Goals & Milestones**: Screen was deleted from `lib/features/goals/`; model exists (`goal_model.dart`), but no UI allows users to create, view, or manage long-term goals.
3. **Research Papers & Literature Tracker**: Screen was deleted from `lib/features/research/`; model exists (`research_model.dart`), but no reading list or PDF viewer interface exists.
4. **Progress Analytics & Charts**: Screen was deleted from `lib/features/analytics/`; fl_chart is included in dependencies, but analytics dashboard is absent.
5. **Cloudflare R2 Object Storage**: Outlined in `description.md:49-50` for file uploads, attachments, and PDFs. Zero implementation exists in Flutter code.
6. **Dynamic Course & Project Lists**: `CoursesScreen` and `ProjectsScreen` currently only render `firstOrNull`. Dynamic list views for all user courses and projects must be restored.
7. **Offline Sync Queue**: No local database (SQLite/Hive) exists to buffer mutations when the user is disconnected from Supabase.

---

## 7. Metrics

* **Analyzer Issues**: 0 errors, 0 warnings (1 deprecated member use suppressed with `// ignore`).
* **Formatting Compliance**: 4 of 44 files formatted (40 files require `dart format`).
* **Test Coverage**: 35.87% line coverage (1,559 / 4,346 instrumented lines across 17 passing tests).
* **Workspace Size**: 44 files in `lib/` and `test/`, totaling **11,841 lines of Dart code**.
* **Largest Files**:
  1. `lib/features/workload/workload_screen.dart` (1,052 lines)
  2. `lib/repositories/supabase_database_repository.dart` (971 lines)
  3. `lib/features/notes/notes_screen.dart` (941 lines)
  4. `lib/features/auth/login_screen.dart` (884 lines)
  5. `lib/features/auth/sign_up_screen.dart` (680 lines)
  6. `lib/features/workload/add_edit_task_modal.dart` (677 lines)
  7. `lib/features/notes/note_editor_screen.dart` (635 lines)
  8. `lib/features/notes/widgets/markdown_renderer.dart` (462 lines)
  9. `lib/providers/app_providers.dart` (436 lines)
  10. `lib/features/notes/note_detail_screen.dart` (395 lines)
* **Direct Dependencies**: 10 (7 outdated).
* **Swallowed Exception Blocks**: 35 instances in repository layer.
* **Inline Hex Colors**: 310 raw `Color(0x...)` instances.
* **Force Unwraps (`!`)**: 56 instances.

---

## 8. Coverage Statement

### Files Reviewed
* **Core & Config**: `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `.gitignore`, `README.md`, `description.md`, `PROJECT_DOCUMENTATION.md`, `supabase/schema.sql`
* **Platform Config**: `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`, `android/app/src/debug/AndroidManifest.xml`, `ios/Runner/Info.plist`, `web/index.html`
* **Lib Source**: All 40 Dart files across `lib/core/`, `lib/features/`, `lib/models/`, `lib/providers/`, `lib/repositories/`, and `lib/widgets/`
* **Test Source**: All 4 test files in `test/` (`dropdown_test.dart`, `notes_test.dart`, `widget_test.dart`, `workload_test.dart`)

### Skipped Areas & Unverified Items
* **UNVERIFIED: Native iOS Build & Podfile**: macOS / Xcode environment is not present on this Windows host. iOS build configuration was statically reviewed via `Info.plist`, but native execution remains unverified.
* **UNVERIFIED: Native Android Gradle Execution**: Android SDK and command-line tools are missing from the host machine (`flutter doctor`). Release APK compilation was statically verified via `build.gradle.kts` and manifests.
* **UNVERIFIED: Cloudflare R2 Bucket Infrastructure**: Cloudflare R2 bucket credentials and CORS configurations could not be verified because no R2 integration code has been created yet.

