import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:devos/models/profile_model.dart';
import 'package:devos/models/task_model.dart';
import 'package:devos/models/course_model.dart';
import 'package:devos/models/project_model.dart';
import 'package:devos/models/skill_model.dart';
import 'package:devos/models/note_model.dart';
import 'package:devos/providers/app_providers.dart';
import 'package:devos/features/analytics/analytics_screen.dart';

void main() {
  final testProfile = UserProfile(
    id: 'test-user-uuid-1234',
    email: 'muntahashidratul3@gmail.com',
    fullName: 'Muntaha Shidratul',
    avatarUrl: '',
    institution: 'BAUST',
    major: 'Computer Science & Engineering',
    academicYear: '3rd Year (Junior)',
    learningStreak: 14,
    bio: 'Distributed Systems & Robotics Researcher',
  );

  final List<DevTask> testTasks = [
    DevTask(
      id: 'task-1',
      title: 'Complete ROS2 Nav2 Integration',
      description: 'Setup robot navigation stack',
      category: 'engineering',
      priority: TaskPriority.urgent,
      status: TaskStatus.completed,
    ),
    DevTask(
      id: 'task-2',
      title: 'PostgreSQL Database Indexing',
      description: 'Optimize queries for analytics',
      category: 'database',
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
    ),
  ];

  final List<Course> testCourses = [
    Course(
      id: 'course-1',
      name: 'Distributed Systems & Cloud Computing',
      code: 'CSE-4101',
      instructor: 'Dr. Alan Turing',
      creditHours: 3.0,
      description: 'Distributed consensus & fault tolerance',
      colorHex: '#7C3AED',
      progressPercentage: 65,
      topics: [
        CourseTopic(id: 't-1', title: 'Raft Consensus Algorithm', isCompleted: true),
        CourseTopic(id: 't-2', title: 'Vector Clocks', isCompleted: false),
      ],
    ),
  ];

  final List<Project> testProjects = [
    Project(
      id: 'project-1',
      title: 'DevOS Engineering Workspace',
      description: 'Single-theme developer operating environment',
      technologies: ['Flutter', 'Riverpod', 'Supabase'],
      githubUrl: 'https://github.com/muntaha-ux/devos',
      liveUrl: 'https://devos-gold.vercel.app',
      startDate: '2026-01-01',
      targetCompletionDate: '2026-12-31',
      status: 'in_progress',
      progressPercentage: 80,
      milestones: [
        ProjectMilestone(id: 'm-1', title: 'Analytics Engine', targetDate: '2026-03-01', isCompleted: true),
        ProjectMilestone(id: 'm-2', title: 'Semantic Search', targetDate: '2026-04-01', isCompleted: true),
      ],
    ),
  ];

  final List<Skill> testSkills = [
    Skill(
      id: 'skill-1',
      name: 'Flutter Architecture',
      category: 'Mobile',
      proficiencyLevel: 'Advanced',
      progressPercentage: 75,
      topics: [
        SkillTopic(id: 'st-1', title: 'Riverpod State Management', isCompleted: true),
      ],
    ),
  ];

  final List<Note> testNotes = [
    Note(
      id: 'note-1',
      title: 'PostgreSQL Row Level Security (RLS) Rules',
      content: 'Important considerations for authenticated sessions',
      category: 'Database',
      tags: ['database', 'security'],
      createdAt: DateTime.now(),
    ),
  ];

  Widget createTestWidget({void Function(int)? onNavigateToTab}) {
    return ProviderScope(
      overrides: [
        profileProvider.overrideWith(
          (ref) => ProfileNotifier(ref.read(databaseRepositoryProvider))..setProfile(testProfile),
        ),
        tasksProvider.overrideWith(
          (ref) => MockTasksNotifier(testTasks),
        ),
        coursesProvider.overrideWith(
          (ref) => MockCoursesNotifier(testCourses),
        ),
        projectsProvider.overrideWith(
          (ref) => MockProjectsNotifier(testProjects),
        ),
        skillsProvider.overrideWith(
          (ref) => MockSkillsNotifier(testSkills),
        ),
        notesProvider.overrideWith(
          (ref) => MockNotesNotifier(testNotes),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: AnalyticsScreen(
            onNavigateToTab: onNavigateToTab,
          ),
        ),
      ),
    );
  }

  testWidgets('AnalyticsScreen renders all 4 core features and titles', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify Screen Title & Badges
    expect(find.text('Productivity & Analytics'), findsOneWidget);
    expect(find.text('LIVE METRICS'), findsOneWidget);

    // Feature 2: Learning Streak Tracking
    expect(find.text('LEARNING STREAK TRACKING'), findsOneWidget);
    expect(find.text('14 Days Active Streak'), findsOneWidget);
    expect(find.text('SHIELD READY'), findsOneWidget);
    expect(find.text('TODAY\'S STREAK CHECKPOINTS'), findsOneWidget);
    expect(find.textContaining('CLAIM TODAY\'S STREAK CHECK-IN'), findsOneWidget);

    // Feature 1: Daily Coding Activity
    expect(find.text('DAILY CODING ACTIVITY'), findsOneWidget);
    expect(find.textContaining('Contributions'), findsOneWidget);
    expect(find.text('Log Activity'), findsOneWidget);

    // Feature 4: Productivity Visualization
    expect(find.text('PRODUCTIVITY VISUALIZATION'), findsOneWidget);
    expect(find.text('Daily Focus Hours & Engineering Velocity'), findsOneWidget);
    expect(find.text('MON'), findsOneWidget);
    expect(find.text('SUN'), findsOneWidget);
    expect(find.text('DOMAIN FOCUS DISTRIBUTION'), findsOneWidget);
    expect(find.text('94'), findsOneWidget);
    expect(find.text('Optimal Velocity Score'), findsOneWidget);

    // Feature 3: Weekly & Monthly Statistics
    expect(find.text('WEEKLY STATISTICAL MATRIX'), findsOneWidget);
    expect(find.text('Workload & Engineering Tasks'), findsOneWidget);
    expect(find.text('Courses & Academic Syllabus'), findsOneWidget);
    expect(find.text('Software Projects & Git Repositories'), findsOneWidget);
    expect(find.text('Skill Competencies & Engineering Modules'), findsOneWidget);
    expect(find.text('Notes & Technical Research Docs'), findsOneWidget);
  });

  testWidgets('Period toggle switches between Weekly and Monthly statistics', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('WEEKLY STATISTICAL MATRIX'), findsOneWidget);

    // Tap on Monthly View
    await tester.tap(find.text('MONTHLY VIEW (LAST 30 DAYS)'));
    await tester.pumpAndSettle();

    expect(find.text('MONTHLY STATISTICAL MATRIX'), findsOneWidget);
    expect(find.text('MONTHLY VELOCITY'), findsOneWidget);
  });

  testWidgets('Tapping Claim Streak Check-in increments streak and shows SnackBar', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final claimButton = find.textContaining('CLAIM TODAY\'S STREAK CHECK-IN');
    expect(claimButton, findsOneWidget);

    await tester.tap(claimButton);
    await tester.pump(); // Start SnackBar animation
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Streak Check-In Recorded!'), findsOneWidget);
  });

  testWidgets('Interactive Log Activity dialog adds commits and focus session', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap Log Activity
    await tester.tap(find.text('Log Activity'));
    await tester.pumpAndSettle();

    expect(find.text('Log Coding & Focus Session'), findsOneWidget);
    expect(find.text('Save Session'), findsOneWidget);

    // Tap Save Session
    await tester.tap(find.text('Save Session'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Logged 3 commits'), findsOneWidget);
  });
}

// ===================== MOCK NOTIFIERS FOR RIVERPOD =====================

class MockTasksNotifier extends StateNotifier<List<DevTask>> implements TasksNotifier {
  MockTasksNotifier(super.state);
  @override
  Future<void> loadTasks() async {}
  @override
  Future<void> toggleTaskStatus(String taskId) async {}
  @override
  Future<void> addTask(DevTask task) async {}
  @override
  Future<void> updateTask(DevTask updated) async {}
  @override
  Future<void> deleteTask(String taskId) async {}
  @override
  void setTasks(List<DevTask> tasks) {
    state = tasks;
  }
}

class MockCoursesNotifier extends StateNotifier<List<Course>> implements CoursesNotifier {
  MockCoursesNotifier(super.state);
  @override
  Future<void> loadCourses() async {}
  @override
  Future<void> toggleTopic(String courseId, String topicId) async {}
  @override
  Future<void> addCourse(Course course) async {}
  @override
  Future<void> updateCourse(Course updated) async {}
  @override
  Future<void> deleteCourse(String courseId) async {}
}

class MockProjectsNotifier extends StateNotifier<List<Project>> implements ProjectsNotifier {
  MockProjectsNotifier(super.state);
  @override
  Future<void> loadProjects() async {}
  @override
  Future<void> toggleMilestone(String projectId, String milestoneId) async {}
  @override
  Future<void> addProject(Project project) async {}
  @override
  Future<void> updateProject(Project updated) async {}
  @override
  Future<void> deleteProject(String projectId) async {}
}

class MockSkillsNotifier extends StateNotifier<List<Skill>> implements SkillsNotifier {
  MockSkillsNotifier(super.state);
  @override
  Future<void> loadSkills() async {}
  @override
  Future<void> toggleSkillTopic(String skillId, String topicId) async {}
  @override
  Future<void> addSkill(Skill skill) async {}
  @override
  Future<void> updateSkill(Skill updated) async {}
  @override
  Future<void> deleteSkill(String skillId) async {}
}

class MockNotesNotifier extends StateNotifier<List<Note>> implements NotesNotifier {
  MockNotesNotifier(super.state);
  @override
  Future<void> loadNotes() async {}
  @override
  Future<void> toggleFavorite(String noteId) async {}
  @override
  Future<void> addNote(Note note) async {}
  @override
  Future<void> updateNote(Note updated) async {}
  @override
  Future<void> deleteNote(String noteId) async {}
}
