# DevOS Comprehensive Implementation Plan

**Date**: November 10, 2026  
**Auditor & Architect**: Principal Flutter Engineer & Software Architect  
**Target Codebase**: `E:\Backup\DevOS\devos`  
**Strategy**: **Disciplined Incremental Refactor** (preserving working UI while systematically decoupling architecture, fixing critical crashes, and establishing testing boundaries)

---

## 1. Strategy: Incremental Refactor vs. Partial Rewrite

### Decision: Incremental Refactor with Layered Decoupling
We reject a total rewrite. The user interface already has established Figma design tokens, passing test suites for Workload & Notes (17 tests), and working PostgREST database schemas (`supabase/schema.sql`). A ground-up rewrite would discard working domain models and delay business value.

Instead, we will execute an **Incremental Refactor**:
1. **Preserve & Fortify**: Retain working UI widgets in `features/workload/` and `features/notes/`.
2. **Quarantine & Fix**: Immediately resolve Critical and High severity runtime crashes (flex assertions in `Expanded`, missing Android permissions, secrets in VCS).
3. **Decouple the Core**: Break down the 971-line `SupabaseDatabaseRepository` and 436-line `app_providers.dart` into domain-scoped repositories and modern `AsyncNotifier` providers.
4. **Unify Design Tokens**: Eliminate the 310 raw hex color literals by introducing a centralized, dark-mode compatible `AppDesignSystem`.

---

## 2. Target Architecture

DevOS will adopt a **Feature-First Clean Architecture** with strict layer separation:
* **Presentation Layer**: Flutter widgets, screens, modals, and presentation controllers. No direct database or network calls.
* **Application / Domain Layer**: Pure Dart entities, use cases, and Riverpod `AsyncNotifier` state managers representing UI state machines.
* **Data Layer**: Repositories, data transfer objects (DTOs), local cache (SQLite / Hive), and Supabase / Cloudflare remote data sources.

### Target Folder Tree

```
lib/
├── app.dart                             # MaterialApp, theme bindings, routing observer
├── main.dart                            # Environment bootstrap, error zones, DI container
├── core/
│   ├── config/
│   │   ├── env_config.dart              # Compile-time environment variables (--dart-define)
│   │   └── supabase_config.dart         # Safe config reader (reads from EnvConfig)
│   ├── errors/
│   │   ├── app_exception.dart           # Domain exception taxonomy (Network, Auth, Database)
│   │   └── error_handler.dart           # Global error observer & logger
│   ├── network/
│   │   ├── network_info.dart            # Connectivity checker
│   │   └── result.dart                  # Result<T, E> functional error handling
│   ├── theme/
│   │   ├── app_colors.dart              # Abstract design tokens
│   │   ├── app_text_theme.dart          # JetBrains Mono & Inter typography tokens
│   │   ├── app_theme.dart               # Light & Dark ThemeData definitions
│   │   └── theme_provider.dart          # Responsive theme switcher
│   └── utils/
│       ├── formatters.dart              # Date, streak, and percentage formatting
│       └── validators.dart              # Form validation logic
├── data/
│   ├── local/
│   │   ├── database_helper.dart         # Local offline cache storage
│   │   └── sync_queue.dart              # Offline mutation buffer & sync coordinator
│   └── remote/
│       ├── supabase_client_provider.dart# Riverpod Supabase client provider
│       └── r2_storage_client.dart       # Cloudflare R2 S3-compatible client
├── features/
│   ├── auth/
│   │   ├── data/auth_repository.dart
│   │   ├── domain/auth_state.dart
│   │   └── presentation/{login_screen.dart, sign_up_screen.dart}
│   ├── dashboard/
│   │   ├── presentation/{dashboard_screen.dart, widgets/urgent_card.dart, widgets/metric_grid.dart}
│   │   └── providers/dashboard_provider.dart
│   ├── courses/
│   │   ├── data/courses_repository.dart
│   │   ├── domain/course_model.dart
│   │   ├── presentation/{courses_screen.dart, course_detail_screen.dart, add_edit_course_modal.dart}
│   │   └── providers/courses_provider.dart
│   ├── workload/
│   │   ├── data/tasks_repository.dart
│   │   ├── domain/task_model.dart
│   │   ├── presentation/{workload_screen.dart, add_edit_task_modal.dart}
│   │   └── providers/tasks_provider.dart
│   ├── skills/
│   │   ├── data/skills_repository.dart
│   │   ├── domain/skill_model.dart
│   │   ├── presentation/{skills_screen.dart, add_edit_skill_modal.dart}
│   │   └── providers/skills_provider.dart
│   ├── projects/
│   │   ├── data/projects_repository.dart
│   │   ├── domain/project_model.dart
│   │   ├── presentation/{projects_screen.dart, project_detail_screen.dart, add_edit_project_modal.dart}
│   │   └── providers/projects_provider.dart
│   └── notes/
│       ├── data/notes_repository.dart
│       ├── domain/note_model.dart
│       ├── presentation/{notes_screen.dart, note_detail_screen.dart, note_editor_screen.dart}
│       ├── presentation/widgets/{markdown_renderer.dart, tag_filter_bar.dart}
│       └── providers/notes_provider.dart
└── shared_widgets/
    ├── devos_app_bar.dart
    ├── devos_bottom_nav.dart
    ├── devos_drawer.dart
    ├── responsive_layout.dart
    └── touch_target_box.dart
```

---

## 3. Phased Roadmap

```
+---------------------------------------------------------------------------------------------------------+
|                                           PHASED ROADMAP                                                |
+---------------------------------------------------------------------------------------------------------+
|  PHASE 0: STABILIZE (Days 1 - 2)                                                                        |
|  - Fix Critical security secrets, Android manifest internet permission, release signing, flex crashes. |
|  - Format code, configure strict analyzer & GitHub Actions CI.                                          |
+---------------------------------------------------------------------------------------------------------+
                                                     |
                                                     v
+---------------------------------------------------------------------------------------------------------+
|  PHASE 1: FOUNDATION (Days 3 - 5)                                                                       |
|  - Modularize God-Classes (Split SupabaseDatabaseRepository & app_providers).                          |
|  - Unify Design Tokens & Theme. Create Result<T> error taxonomy.                                        |
+---------------------------------------------------------------------------------------------------------+
                                                     |
                                                     v
+---------------------------------------------------------------------------------------------------------+
|  PHASE 2: FIX HIGH & CRITICAL DEFECTS (Days 6 - 8)                                                      |
|  - Restore dynamic multi-item rendering for Courses and Projects screens.                                |
|  - Fix Dashboard faked metrics & wire Submit action. Fix task relational joins & empty list overwrite.  |
+---------------------------------------------------------------------------------------------------------+
                                                     |
                                                     v
+---------------------------------------------------------------------------------------------------------+
|  PHASE 3: FEATURE COMPLETION & HARMONIZATION (Days 9 - 12)                                               |
|  - Harmonize Course and Project Detail screens to Figma design language.                                |
|  - Restore Calendar & Goals screens with Figma styling. Integrate Cloudflare R2 storage.                |
+---------------------------------------------------------------------------------------------------------+
                                                     |
                                                     v
+---------------------------------------------------------------------------------------------------------+
|  PHASE 4: TESTING & QUALITY GATES (Days 13 - 15)                                                        |
|  - Add repository unit tests with mocktail. Add notifier state machine tests. Target >=75% coverage.   |
+---------------------------------------------------------------------------------------------------------+
                                                     |
                                                     v
+---------------------------------------------------------------------------------------------------------+
|  PHASE 5: PERFORMANCE, ACCESSIBILITY & POLISH (Days 16 - 17)                                            |
|  - Break down giant 500+ line build() methods. Implement lazy ListView in markdown renderer.            |
|  - Expand tap targets to 48x48dp. Add Semantics & Screen Reader labels.                                 |
+---------------------------------------------------------------------------------------------------------+
                                                     |
                                                     v
+---------------------------------------------------------------------------------------------------------+
|  PHASE 6: RELEASE READINESS (Days 18 - 20)                                                              |
|  - Update Android package ID, icons, and splash screens. Integrate Sentry error logging.                |
+---------------------------------------------------------------------------------------------------------+
```

---

## 4. Detailed Task Specifications

### Phase 0: Stabilize
*Immediate baseline fixes to prevent security breaches and runtime crashes.*

#### Task 0.1: Secure Configuration & Credential Isolation
* **Task ID**: `TASK-001`
* **Linked Findings**: `SEC-01`, `K`
* **Description**: Remove plaintext Supabase credentials from VCS and switch to compile-time `--dart-define` / `.env` loading.
* **Files Affected**:
  - `lib/core/constants/supabase_config.dart`
  - `lib/core/config/env_config.dart` (new)
  - `.gitignore`
  - `.env.example` (new)
* **Step-by-Step Approach**:
  1. Create `lib/core/config/env_config.dart` with `String.fromEnvironment('SUPABASE_URL')` and `String.fromEnvironment('SUPABASE_ANON_KEY')`.
  2. Fall back to local `.env` reader via `flutter_dotenv` if definitions are omitted during debug.
  3. Update `lib/core/constants/supabase_config.dart` to read from `EnvConfig`.
  4. Add `.env*` to `.gitignore`. Create `.env.example` with sanitized template values.
* **Acceptance Criteria**: Repository contains zero live credentials in git history; app initializes successfully when supplied with `--dart-define` parameters.
* **Tests to Add**: Unit test validating `EnvConfig` fallback defaults.
* **Effort**: Small (2 hours) | **Risk**: Low

#### Task 0.2: Add Android Main Manifest Internet Permission
* **Task ID**: `TASK-002`
* **Linked Findings**: `PLT-01`
* **Description**: Add `<uses-permission android:name="android.permission.INTERNET"/>` to the production Android manifest.
* **Files Affected**: `android/app/src/main/AndroidManifest.xml`
* **Step-by-Step Approach**:
  1. Open `android/app/src/main/AndroidManifest.xml`.
  2. Insert `<uses-permission android:name="android.permission.INTERNET"/>` directly under the `<manifest>` root element.
* **Acceptance Criteria**: Manifest contains the INTERNET permission; release Android builds have socket permissions.
* **Effort**: Small (15 minutes) | **Risk**: Low

#### Task 0.3: Fix `Expanded(flex: 0)` Assertion Crashes
* **Task ID**: `TASK-003`
* **Linked Findings**: `BUG-01`
* **Description**: Guard progress bar `flex` calculations in `CoursesScreen` and `SkillsScreen` to ensure `flex` is strictly `>= 1`.
* **Files Affected**:
  - `lib/features/courses/courses_screen.dart` (lines 197, 201)
  - `lib/features/skills/skills_screen.dart` (lines 345, 349)
  - `lib/features/dashboard/dashboard_screen.dart` (lines 271, 275)
* **Step-by-Step Approach**:
  1. Replace direct integer flex binding with a clamped calculation:
     `final clampedFlex = percentage.clamp(1, 99);`
     `flex: clampedFlex` and `flex: 100 - clampedFlex`.
  2. Handle boundary cases (0% and 100%) cleanly with full-width colored containers when progress is at extremes.
* **Acceptance Criteria**: Courses and Skills with 0% and 100% progress render without throwing Flutter framework assertion errors.
* **Tests to Add**: Widget tests in `test/courses_test.dart` and `test/skills_test.dart` verifying 0% and 100% progress rendering.
* **Effort**: Small (1 hour) | **Risk**: Low

#### Task 0.4: Codebase Formatting, Strict Analysis & Dead Code Cleanup
* **Task ID**: `TASK-004`
* **Linked Findings**: `FMT-01`, `LNT-01`, `COD-01`
* **Description**: Format all 44 Dart files, enable strict type checking in `analysis_options.yaml`, and remove unused dead widgets.
* **Files Affected**:
  - `analysis_options.yaml`
  - Workspace Dart files (`lib/`, `test/`)
  - `lib/widgets/section_header.dart`
  - `lib/widgets/streak_badge.dart`
* **Step-by-Step Approach**:
  1. Update `analysis_options.yaml` analyzer section:
     ```yaml
     analyzer:
       language:
         strict-casts: true
         strict-inference: true
         strict-raw-types: true
     ```
  2. Delete unreferenced dead code (`lib/widgets/section_header.dart` and `streak_badge.dart`).
  3. Run `dart format .` across the workspace.
  4. Run `flutter analyze` and resolve any strict cast or raw type warnings.
* **Acceptance Criteria**: `dart format --set-exit-if-changed .` exits with 0; `flutter analyze` reports 0 issues under strict flags.
* **Effort**: Small (1.5 hours) | **Risk**: Low

---

### Phase 1: Foundation
*Decouple the monolithic data layer, eliminate race conditions, and standardize design tokens.*

#### Task 1.1: Modularize Repository Layer (Split `SupabaseDatabaseRepository`)
* **Task ID**: `TASK-101`
* **Linked Findings**: `ARC-01`, `ASY-01`
* **Description**: Split the 971-line `SupabaseDatabaseRepository` into 6 single-responsibility domain repositories:
  - `ProfileRepository`
  - `CoursesRepository`
  - `TasksRepository`
  - `SkillsRepository`
  - `ProjectsRepository`
  - `NotesRepository`
* **Files Affected**:
  - `lib/repositories/supabase_database_repository.dart` (deprecate/split)
  - `lib/features/*/data/*_repository.dart` (new)
  - `lib/core/network/result.dart` (new)
* **Step-by-Step Approach**:
  1. Create `Result<T, AppError>` sealed class to wrap successful data or typed failures.
  2. Extract each domain's PostgREST queries into dedicated repository classes.
  3. Replace `catch (_)` blocks with structured `try/catch` mapping PostgREST exceptions into `DatabaseFailure(message)`.
* **Acceptance Criteria**: Each repository is under 200 lines, independently testable, and returns typed `Result<T>` instead of swallowing exceptions.
* **Tests to Add**: Unit tests verifying that database errors propagate as `Result.failure`.
* **Effort**: Large (8 hours) | **Risk**: Medium

#### Task 1.2: Eliminate Constructor Async Side-Effects & Modernize State Notifiers
* **Task ID**: `TASK-102`
* **Linked Findings**: `ARC-02`
* **Description**: Remove unawaited asynchronous queries from notifier constructors and transition to Riverpod `AsyncNotifier` state machines.
* **Files Affected**:
  - `lib/providers/app_providers.dart` (split into feature providers)
  - `lib/features/*/providers/*_provider.dart` (new)
* **Step-by-Step Approach**:
  1. Convert `StateNotifier<List<T>>` into `AsyncNotifier<List<T>>`.
  2. Migrate constructor calls into the `Future<List<T>> build()` lifecycle method of `AsyncNotifier`.
  3. Replace the imperative `syncWorkspaceProvider` sequence with reactive providers that load lazily on first access.
* **Acceptance Criteria**: Zero unawaited database queries fire during startup; UI cleanly handles `AsyncLoading`, `AsyncData`, and `AsyncError`.
* **Tests to Add**: Unit tests verifying notifier state transitions (`loading` -> `data` / `error`).
* **Effort**: Medium (6 hours) | **Risk**: Medium

#### Task 1.3: Centralize Design Tokens & Fix Dark Mode Compatibility
* **Task ID**: `TASK-103`
* **Linked Findings**: `UIX-01`
* **Description**: Eliminate raw hex color literals by introducing `AppDesignSystem` theme extension and binding scaffold backgrounds dynamically to theme mode.
* **Files Affected**:
  - `lib/core/constants/app_colors.dart`
  - `lib/core/theme/app_theme.dart`
  - `lib/main.dart`
  - Feature screens
* **Step-by-Step Approach**:
  1. Define a `ThemeExtension` called `DevOSTokens` holding Figma-matched semantic colors (`urgentCardBackground`, `codeBadge`, `sprintPurple`, `bottomNav`).
  2. Register light and dark variants in `AppTheme.lightTheme` and `AppTheme.darkTheme`.
  3. Replace hardcoded `AppColors.figmaBackground` with `Theme.of(context).scaffoldBackgroundColor`.
* **Acceptance Criteria**: Toggling theme mode in drawer flips entire UI between light Figma taupe and dark background without broken contrast.
* **Effort**: Medium (6 hours) | **Risk**: Low

---

### Phase 2: Fix High & Critical Bugs
*Fix broken user flows, hardcoded UI fallbacks, and database query defects.*

#### Task 2.1: Implement Dynamic Multi-Item Rendering on Courses & Projects Screens
* **Task ID**: `TASK-201`
* **Linked Findings**: `BUG-02`
* **Description**: Replace single `firstOrNull` item display with dynamic lists rendering all user courses and projects.
* **Files Affected**:
  - `lib/features/courses/courses_screen.dart`
  - `lib/features/projects/projects_screen.dart`
* **Step-by-Step Approach**:
  1. In `courses_screen.dart`: Keep the featured card for the primary active course, but add a horizontal or vertical scrollable list for all additional enrolled courses.
  2. In `projects_screen.dart`: Replace the static hardcoded sprint cards with dynamic project milestone items mapped from the user's actual projects.
  3. Show clear, professional empty state illustrations when the collection has 0 items.
* **Acceptance Criteria**: All user-created courses and projects appear in the UI; adding a new course or project immediately shows in the list.
* **Tests to Add**: Widget tests in `test/courses_test.dart` and `test/projects_test.dart` verifying multi-item list rendering.
* **Effort**: Medium (5 hours) | **Risk**: Medium

#### Task 2.2: Dynamic Dashboard Metrics & Functional Submit Action
* **Task ID**: `TASK-202`
* **Linked Findings**: `BUG-03`
* **Description**: Connect Dashboard metrics dynamically to real provider state and wire the Urgent Deadline "Submit" button to update task completion.
* **Files Affected**: `lib/features/dashboard/dashboard_screen.dart`
* **Step-by-Step Approach**:
  1. Compute "Learning Pulse" dynamically based on course syllabus topic completion percentages:
     `final avgCourseProgress = courses.isEmpty ? 0 : (courses.map((c) => c.progressPercentage).reduce((a, b) => a + b) / courses.length).round();`
  2. Calculate "Hours Today" from completed task durations or default estimate.
  3. Wire the "Submit" button on the Urgent Deadline card to invoke:
     `ref.read(tasksProvider.notifier).toggleTaskStatus(urgentTask.id);`
  4. Display confirmation SnackBar only after the task status successfully updates.
* **Acceptance Criteria**: Clicking "Submit" marks the urgent task completed in Supabase and updates the "Tasks Done" counter dynamically.
* **Tests to Add**: Widget test verifying dashboard metric computation and submit interaction.
* **Effort**: Medium (4 hours) | **Risk**: Low

#### Task 2.3: Task Relational Joins & Zero-Task State Persistence
* **Task ID**: `TASK-203`
* **Linked Findings**: `DAT-01`, `DAT-02`
* **Description**: Fix PostgREST query to perform relational joins for course/project names and allow valid empty task lists.
* **Files Affected**:
  - `lib/repositories/supabase_database_repository.dart` (or new `TasksRepository`)
  - `lib/features/skills/skills_screen.dart`
* **Step-by-Step Approach**:
  1. Update PostgREST select query in `getTasks()`:
     ```dart
     final response = await _client
         .from('tasks')
         .select('*, courses(name), projects(title)')
         .eq('user_id', userId)
         .order('created_at', ascending: false);
     ```
  2. Parse `relatedCourseName` from `json['courses']?['name']` and `relatedProjectName` from `json['projects']?['title']`.
  3. Remove the line `if (list.isEmpty) return _defaultSampleTasks;` so users can have an empty task inbox.
  4. In `skills_screen.dart:51`, replace `millisecondsSinceEpoch` with `const Uuid().v4()`.
* **Acceptance Criteria**: Tasks loaded from Supabase retain their linked course/project badge names; zero-task lists persist correctly.
* **Tests to Add**: Unit test for `DevTask.fromJson` with PostgREST join payloads.
* **Effort**: Medium (4 hours) | **Risk**: Low

---

### Phase 3: Feature Completion & Harmonization
*Reconcile visual inconsistencies, restore orphaned feature screens, and integrate storage.*

#### Task 3.1: Harmonize Course & Project Detail Views with Figma Aesthetic
* **Task ID**: `TASK-301`
* **Linked Findings**: `UIX-02`
* **Description**: Redesign `CourseDetailScreen` and `ProjectDetailScreen` to match the Figma taupe/rose aesthetic and JetBrains Mono typography.
* **Files Affected**:
  - `lib/features/courses/course_detail_screen.dart`
  - `lib/features/projects/project_detail_screen.dart`
* **Step-by-Step Approach**:
  1. Replace generic Material 3 Dark Cards with Figma styled metric cards and topic outlines.
  2. Implement interactive topic checklist allowing users to check off syllabus items directly inside `CourseDetailScreen`.
  3. Add project milestone stepper with status toggles directly inside `ProjectDetailScreen`.
* **Acceptance Criteria**: Detail screens share identical design tokens, fonts, and colors as the primary screens.
* **Effort**: Medium (6 hours) | **Risk**: Low

#### Task 3.2: Restore Academic Calendar & Personal Goals Screens
* **Task ID**: `TASK-302`
* **Linked Findings**: `INF-04`
* **Description**: Rebuild `CalendarScreen` and `GoalsScreen` using `table_calendar` and Figma styling tokens.
* **Files Affected**:
  - `lib/features/calendar/calendar_screen.dart` (new)
  - `lib/features/goals/goals_screen.dart` (new)
  - `lib/main.dart` (update drawer & navigation)
* **Step-by-Step Approach**:
  1. Create `CalendarScreen` utilizing `table_calendar: ^3.1.2`, styling calendar days with JetBrains Mono and highlighting exam/assignment deadlines.
  2. Create `GoalsScreen` supporting academic and career goals with interactive milestone checkboxes.
  3. Wire both screens into `DevOSMainShell` drawer navigation.
* **Acceptance Criteria**: Users can navigate to Calendar and Goals from drawer and perform full CRUD operations.
* **Effort**: Large (8 hours) | **Risk**: Medium

#### Task 3.3: Cloudflare R2 Storage Integration
* **Task ID**: `TASK-303`
* **Linked Findings**: `INF-03`
* **Description**: Implement object storage client for Cloudflare R2 to allow PDF and image attachments on notes and projects.
* **Files Affected**:
  - `lib/data/remote/r2_storage_client.dart` (new)
  - `lib/features/notes/note_editor_screen.dart`
* **Step-by-Step Approach**:
  1. Add S3-compatible client or pre-signed URL upload handler for Cloudflare R2.
  2. Add attachment upload button in `NoteEditorScreen` to upload markdown images/diagrams to R2.
* **Acceptance Criteria**: File upload returns public R2 URL and embeds in markdown note.
* **Effort**: Large (8 hours) | **Risk**: Medium

---

### Phase 4: Testing & Quality Gates
*Elevate line coverage from 35.87% to >=75% with unit and widget test suites.*

#### Task 4.1: Repository Layer Unit Tests (Mocktail)
* **Task ID**: `TASK-401`
* **Linked Findings**: `TST-01`
* **Description**: Write comprehensive unit tests for all repositories utilizing `mocktail` to mock Supabase PostgREST clients.
* **Files Affected**: `test/repositories/` (new test files)
* **Step-by-Step Approach**:
  1. Mock `SupabaseClient`, `PostgrestFilterBuilder`, and `GoTrueClient`.
  2. Test success, network failure, and authentication failure flows for each repository.
* **Acceptance Criteria**: All repository methods covered; 100% passing tests without network dependencies.
* **Effort**: Large (8 hours) | **Risk**: Low

#### Task 4.2: Provider & Notifier State Machine Tests
* **Task ID**: `TASK-402`
* **Linked Findings**: `TST-01`
* **Description**: Write unit tests for all Riverpod `AsyncNotifier` state managers.
* **Files Affected**: `test/providers/` (new test files)
* **Step-by-Step Approach**:
  1. Set up `ProviderContainer` with repository overrides.
  2. Test optimistic updates, deletion, topic toggling, and error rollbacks.
* **Acceptance Criteria**: Test coverage exceeds 75% across the application layer.
* **Effort**: Medium (6 hours) | **Risk**: Low

#### Task 4.3: GitHub Actions CI/CD Pipeline
* **Task ID**: `TASK-403`
* **Linked Findings**: `DOC-01`
* **Description**: Create GitHub Actions workflow to run `dart format`, `flutter analyze`, and `flutter test --coverage` on every PR.
* **Files Affected**: `.github/workflows/ci.yml` (new)
* **Acceptance Criteria**: CI workflow runs automatically on pull requests and rejects regressions.
* **Effort**: Small (2 hours) | **Risk**: Low

---

### Phase 5: Performance, Accessibility & Polish

#### Task 5.1: Modularize 500+ Line Build Methods & Lazy Markdown Renderer
* **Task ID**: `TASK-501`
* **Linked Findings**: `PER-01`, `PER-02`
* **Description**: Extract reusable sub-widgets with `const` constructors in `WorkloadScreen` and `NotesScreen`; convert `MarkdownRenderer` to lazy `ListView.builder`.
* **Files Affected**:
  - `lib/features/workload/workload_screen.dart`
  - `lib/features/notes/notes_screen.dart`
  - `lib/features/notes/widgets/markdown_renderer.dart`
* **Step-by-Step Approach**:
  1. Extract `WorkloadMetricsHeader`, `TaskCardItem`, `FolderPillList` into dedicated files.
  2. Refactor `MarkdownRenderer` to render parsed blocks inside `ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics())` for lazy instantiation.
* **Acceptance Criteria**: No widget `build()` method exceeds 120 lines; 60fps scrolling on long markdown documents.
* **Effort**: Medium (5 hours) | **Risk**: Low

#### Task 5.2: Accessibility Compliance (Tap Targets & Semantics)
* **Task ID**: `TASK-502`
* **Linked Findings**: `ACC-01`, `ACC-02`
* **Description**: Ensure all touch targets meet minimum 48x48dp bounds and wrap interactive custom widgets with `Semantics`.
* **Files Affected**:
  - `lib/main.dart`
  - `lib/features/skills/skills_screen.dart`
  - Custom chips and buttons
* **Step-by-Step Approach**:
  1. Wrap 32x32dp and 38x38dp buttons in `TouchTargetBox` providing a 48x48dp tap target area.
  2. Add `Semantics(button: true, label: 'Search DevOS', child: ...)` to search button and drawer actions.
  3. Adjust contrast on secondary text elements to meet 4.5:1 ratio.
* **Acceptance Criteria**: Zero accessibility issues reported by Flutter accessibility guidelines.
* **Effort**: Small (3 hours) | **Risk**: Low

#### Task 5.3: Internationalization (i18n) Foundation
* **Task ID**: `TASK-503`
* **Linked Findings**: `LOC-01`
* **Description**: Introduce `flutter_localizations` and `.arb` catalogs for English strings.
* **Files Affected**:
  - `pubspec.yaml`
  - `lib/l10n/app_en.arb` (new)
  - `lib/app.dart`
* **Acceptance Criteria**: Common strings (buttons, headers, error dialogs) extracted to `AppLocalizations`.
* **Effort**: Medium (4 hours) | **Risk**: Low

---

### Phase 6: Release Readiness

#### Task 6.1: Platform Identity, Keystore Signing & Permissions
* **Task ID**: `TASK-601`
* **Linked Findings**: `PLT-02`, `SEC-02`
* **Description**: Update Android application ID to `com.devos.app`, generate launcher icons, and configure secure release signing.
* **Files Affected**:
  - `android/app/build.gradle.kts`
  - `pubspec.yaml` (`flutter_launcher_icons`)
* **Step-by-Step Approach**:
  1. Update `namespace` and `applicationId` to `com.devos.academic.app`.
  2. Configure `key.properties` for release signing and git-ignore the keystore file.
  3. Generate multi-resolution icons for Android, iOS, and Web.
* **Acceptance Criteria**: Clean release APK generated with valid non-debug signature.
* **Effort**: Medium (4 hours) | **Risk**: Medium

#### Task 6.2: Crash Reporting (Sentry) & Comprehensive README
* **Task ID**: `TASK-602`
* **Linked Findings**: `PLT-03`, `DOC-01`
* **Description**: Integrate Sentry SDK for production crash observability and rewrite `README.md`.
* **Files Affected**:
  - `pubspec.yaml`
  - `lib/main.dart`
  - `README.md`
* **Step-by-Step Approach**:
  1. Wrap `runApp` with `SentryFlutter.init()`.
  2. Write production `README.md` covering prerequisites, environment setup, architecture map, and contribution guidelines.
* **Acceptance Criteria**: Uncaught exceptions reported to Sentry dashboard; README provides clear setup commands.
* **Effort**: Small (3 hours) | **Risk**: Low

---

## 5. Dependency Graph & Parallel Execution

```
+-----------------------------------------------------------------------------------+
|                           DEPENDENCY & EXECUTION GRAPH                            |
+-----------------------------------------------------------------------------------+
|                                                                                   |
|  [TASK-001: Secure Config] ---> [TASK-002: Android Manifest] ---> [TASK-003: Flex]|
|               |                                                       |           |
|               v                                                       v           |
|  [TASK-004: Format & Lint] -------------------------------------------------+     |
|                                                                             |     |
|  ========================= PHASE 0 COMPLETE =============================== |     |
|                                                                             |     |
|               +-----------------------+-----------------------+             |     |
|               |                                               |             |     |
|               v                                               v             v     |
|  [TASK-101: Repositories]                       [TASK-103: Design Tokens]         |
|               |                                               |                   |
|               v                                               |                   |
|  [TASK-102: Notifiers & DI]                                   |                   |
|               |                                               |                   |
|  ========================= PHASE 1 COMPLETE ==================v============ |     |
|               |                                                                   |
|       +-------+-------+-----------------------+                                   |
|       |               |                       |                                   |
|       v               v                       v                                   |
|  [TASK-201: Lists] [TASK-202: Dashboard]  [TASK-203: Tasks DB]                    |
|       |               |                       |                                   |
|       +-------+-------+-----------------------+                                   |
|               |                                                                   |
|               v                                                                   |
|  [TASK-301: Detail UI] ---------> [TASK-302: Calendar/Goals]                      |
|               |                                                                   |
|               v                                                                   |
|  [TASK-401: Repo Unit Tests] ---> [TASK-402: Notifier Tests] ---> [TASK-403: CI] |
|               |                                                                   |
|               v                                                                   |
|  [TASK-501: Perf/Build] --------> [TASK-502: Accessibility]                       |
|               |                                                                   |
|               v                                                                   |
|  [TASK-601: Release Signing] ---> [TASK-602: Sentry & Docs]                       |
|                                                                                   |
+-----------------------------------------------------------------------------------+
```

### Parallelizable Streams
* **Stream A (Backend/Data)**: `TASK-101` (Repositories) -> `TASK-203` (Tasks DB) -> `TASK-401` (Repo Tests).
* **Stream B (UI/Presentation)**: `TASK-103` (Tokens) -> `TASK-201` (Multi-item Lists) -> `TASK-301` (Detail Views).
* **Stream C (Platform/Infra)**: `TASK-002` (Manifest) -> `TASK-403` (CI/CD) -> `TASK-601` (Release Signing).

---

## 6. Risk Register

| Risk | Probability | Impact | Mitigation Strategy |
| :--- | :---: | :---: | :--- |
| **Data Loss During Schema Migration** | Low | High | Never alter live PostgreSQL tables without backwards-compatible SQL migrations and automated backups. |
| **Breaking Existing Passing Tests** | Medium | Medium | Run `flutter test` before and after every task. Ensure regression tests pass before merging PRs. |
| **Riverpod Notifier Migration Regressions** | Medium | High | Migrate notifiers one feature at a time (e.g. `TasksNotifier` first), verify in UI, then proceed to next. |
| **Platform-Specific Build Failures** | Medium | Medium | Run CI on both Linux/Windows agents to catch platform manifest inconsistencies early. |
| **Supabase Free-Tier Pausing** | High | Medium | Implement clear UI offline banner alerting users if Supabase DNS does not resolve, rather than failing silently. |

---

## 7. Definition of Done (DoD)

A task or phase is considered **Complete** only when:
1. **Compilation**: Zero analyzer errors and zero warnings under `strict-casts`, `strict-inference`, and `strict-raw-types`.
2. **Formatting**: `dart format --output=none --set-exit-if-changed .` passes cleanly with exit code 0.
3. **Tests**: All existing unit and widget tests pass (`flutter test`).
4. **Coverage**: New code paths must include unit tests; overall project line coverage must exceed **75%**.
5. **No Swallowed Errors**: Zero bare `catch (_)` blocks in new or refactored code.
6. **No Raw Colors**: All colors referenced through `Theme.of(context)` or `DevOSTokens`.
7. **Accessibility**: All interactive targets meet 48x48dp and have semantic labels.
8. **Security**: Zero credentials, tokens, or private keys committed to VCS.

---

## 8. Quick Wins (< 1 Hour Each)

These 5 quick wins provide immediate stability and polish with under 1 hour of effort each:

1. **Add Android Manifest Internet Permission (`TASK-002`)**:
   - *Time*: 10 minutes
   - *Result*: Fixes guaranteed release failure on physical Android devices.
2. **Clamped Progress Flex Bug Fix (`TASK-003`)**:
   - *Time*: 30 minutes
   - *Result*: Eliminates the runtime crash on 0% and 100% course and skill items.
3. **Run Full Workspace Formatting (`TASK-004`)**:
   - *Time*: 10 minutes
   - *Result*: Immediately restores 100% formatting compliance across 40 files.
4. **Secure Credentials to Environment Definitions (`TASK-001`)**:
   - *Time*: 45 minutes
   - *Result*: Removes plaintext JWT and URL from version control.
5. **Fix Search & Skill Add Button Tap Targets (`TASK-502`)**:
   - *Time*: 20 minutes
   - *Result*: Expands 32x32dp and 38x38dp buttons to 48x48dp for WCAG compliance.

