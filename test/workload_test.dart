import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devos/models/task_model.dart';
import 'package:devos/models/course_model.dart';
import 'package:devos/models/project_model.dart';
import 'package:devos/providers/app_providers.dart';
import 'package:devos/features/workload/workload_screen.dart';

void main() {
  final sampleTasks = [
    DevTask(
      id: 'test-task-1',
      title: 'DSA Assignment 2: Binary Search Trees',
      description: 'Implement AVL balancing and Red-Black tree insertion',
      category: 'course',
      priority: TaskPriority.urgent,
      status: TaskStatus.pending,
      dueDate: DateTime.now().add(const Duration(hours: 8)),
      relatedCourseName: 'CSE-301 Data Structures',
    ),
    DevTask(
      id: 'test-task-2',
      title: 'Debug ROS2 hardware serial node',
      description: 'Resolve packet loss over UART at 115200 baud',
      category: 'project',
      priority: TaskPriority.urgent,
      status: TaskStatus.inProgress,
      dueDate: DateTime.now().add(const Duration(hours: 24)),
      relatedProjectName: 'Robotic Arm ROS2',
    ),
    DevTask(
      id: 'test-task-3',
      title: 'Operating Systems: Virtual Memory Lab',
      description: 'Simulate LRU and Second-Chance page replacement algorithms',
      category: 'course',
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
      dueDate: DateTime.now().add(const Duration(days: 3)),
      relatedCourseName: 'CSE-304 Operating Systems',
    ),
    DevTask(
      id: 'test-task-4',
      title: 'Integrate Supabase Auth & PostgreSQL sync',
      description: 'Set up real-time table listeners and JWT session renewal',
      category: 'project',
      priority: TaskPriority.high,
      status: TaskStatus.completed,
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      relatedProjectName: 'DevOS Mobile App',
    ),
    DevTask(
      id: 'test-task-5',
      title: 'General Maintenance: Update Flutter dependencies',
      description: 'Run flutter pub upgrade and verify deprecation warnings',
      category: 'general',
      priority: TaskPriority.low,
      status: TaskStatus.pending,
      dueDate: DateTime.now().add(const Duration(days: 7)),
    ),
  ];

  final sampleCourses = [
    Course(
      id: 'course-1',
      name: 'Data Structures & Algorithms',
      code: 'CSE-301',
      instructor: 'Dr. Turing',
      creditHours: 3.0,
      description: 'Advanced data structures and algorithmic complexity',
      colorHex: '#812DF2',
      progressPercentage: 65,
      topics: [],
    ),
  ];

  final sampleProjects = [
    Project(
      id: 'proj-1',
      title: 'DevOS Mobile App',
      description: 'Personal Engineering and Academic Workspace',
      technologies: ['Flutter', 'Supabase'],
      githubUrl: 'https://github.com/devos/app',
      liveUrl: '',
      startDate: '2026-01-01',
      targetCompletionDate: '2026-12-31',
      status: 'in_progress',
      progressPercentage: 45,
      milestones: [],
    ),
  ];

  Widget createWorkloadWidget({List<DevTask>? customTasks}) {
    return ProviderScope(
      overrides: [
        tasksProvider.overrideWith(
          (ref) => MockTasksNotifier(customTasks ?? sampleTasks),
        ),
        coursesProvider.overrideWith(
          (ref) => MockCoursesNotifier(sampleCourses),
        ),
        projectsProvider.overrideWith(
          (ref) => MockProjectsNotifier(sampleProjects),
        ),
      ],
      child: const MaterialApp(home: Scaffold(body: WorkloadScreen())),
    );
  }

  testWidgets(
    'WorkloadScreen renders header, banner, metrics, and initial task cards',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWorkloadWidget());
      await tester.pumpAndSettle();

      // Verify Banner Header
      expect(find.text('Workload & Tasks'), findsOneWidget);
      expect(
        find.text('ACADEMIC COURSES & SOFTWARE SPRINT BOARD'),
        findsOneWidget,
      );

      // Verify Metric Cards
      expect(find.text('Urgent Deadlines'), findsOneWidget);
      expect(find.text('Course Workload'), findsOneWidget);
      expect(find.text('Project Issues'), findsOneWidget);
      expect(find.text('Sprint Progress'), findsOneWidget);

      // Verify Search Box and State Filter Pills
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('All'), findsWidgets);
      expect(find.text('To Do'), findsWidgets);
      expect(find.text('In Progress'), findsWidgets);
      expect(find.text('Done'), findsWidgets);

      // Verify FAB
      expect(find.text('NEW TASK'), findsOneWidget);

      // Verify Task Titles rendered
      expect(
        find.text('DSA Assignment 2: Binary Search Trees'),
        findsOneWidget,
      );
      expect(find.text('Debug ROS2 hardware serial node'), findsOneWidget);
    },
  );

  testWidgets('Priority Indicators (Urgent, High, Low) render accurately', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createWorkloadWidget());
    await tester.pumpAndSettle();

    // Verify Priority Indicators
    expect(find.text('URGENT'), findsWidgets);
    expect(find.text('HIGH'), findsWidgets);
    expect(find.text('LOW'), findsWidgets);
  });

  testWidgets(
    'Category direct linkage badges display Course and Project references',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWorkloadWidget());
      await tester.pumpAndSettle();

      // Verify Direct Academic Course Link
      expect(find.text('Course: CSE-301 Data Structures'), findsOneWidget);

      // Verify Direct Software Project Link
      expect(find.text('Project: Robotic Arm ROS2'), findsOneWidget);
    },
  );

  testWidgets('State Filtering toggles visible tasks between To Do and Done', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createWorkloadWidget());
    await tester.pumpAndSettle();

    // Initially all 5 tasks are present
    expect(find.text('DSA Assignment 2: Binary Search Trees'), findsOneWidget);
    expect(
      find.text('Integrate Supabase Auth & PostgreSQL sync'),
      findsOneWidget,
    );

    // Tap 'Done' Filter Pill
    final donePill = find.widgetWithText(InkWell, 'Done');
    expect(donePill, findsOneWidget);
    await tester.tap(donePill);
    await tester.pumpAndSettle();

    // Only completed task should be visible
    expect(
      find.text('Integrate Supabase Auth & PostgreSQL sync'),
      findsOneWidget,
    );
    expect(find.text('DSA Assignment 2: Binary Search Trees'), findsNothing);

    // Tap 'To Do' Filter Pill
    final todoPill = find.widgetWithText(InkWell, 'To Do');
    await tester.tap(todoPill);
    await tester.pumpAndSettle();

    // Pending tasks should be visible, completed task should not
    expect(find.text('DSA Assignment 2: Binary Search Trees'), findsOneWidget);
    expect(
      find.text('Integrate Supabase Auth & PostgreSQL sync'),
      findsNothing,
    );
  });

  testWidgets(
    'Category Filtering filters by Academic Courses or Software Projects',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWorkloadWidget());
      await tester.pumpAndSettle();

      // Tap 'Software Projects' filter chip
      final projectChip = find.text('Software Projects');
      expect(projectChip, findsOneWidget);
      await tester.tap(projectChip);
      await tester.pumpAndSettle();

      // Should only see software project tasks
      expect(find.text('Debug ROS2 hardware serial node'), findsOneWidget);
      expect(
        find.text('Integrate Supabase Auth & PostgreSQL sync'),
        findsOneWidget,
      );
      expect(find.text('DSA Assignment 2: Binary Search Trees'), findsNothing);

      // Tap 'Academic Courses' filter chip
      final courseChip = find.text('Academic Courses');
      await tester.tap(courseChip);
      await tester.pumpAndSettle();

      // Should only see course tasks
      expect(
        find.text('DSA Assignment 2: Binary Search Trees'),
        findsOneWidget,
      );
      expect(find.text('Debug ROS2 hardware serial node'), findsNothing);
    },
  );

  testWidgets('Search query filters tasks instantly', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createWorkloadWidget());
    await tester.pumpAndSettle();

    // Enter search text
    await tester.enterText(find.byType(TextField), 'ROS2');
    await tester.pumpAndSettle();

    // Only ROS2 task should appear
    expect(find.text('Debug ROS2 hardware serial node'), findsOneWidget);
    expect(find.text('DSA Assignment 2: Binary Search Trees'), findsNothing);
  });

  testWidgets('Task toggle action flips task status', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createWorkloadWidget());
    await tester.pumpAndSettle();

    // Find the 'Mark Done' button for the first pending task
    final markDoneBtn = find.text('Mark Done').first;
    expect(markDoneBtn, findsOneWidget);

    await tester.tap(markDoneBtn);
    await tester.pumpAndSettle();

    // Status is toggled
    expect(find.text('Reopen'), findsWidgets);
  });

  testWidgets('AddEditTaskModal opens and validates required title', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createWorkloadWidget());
    await tester.pumpAndSettle();

    // Tap NEW TASK FAB
    await tester.tap(find.text('NEW TASK'));
    await tester.pumpAndSettle();

    // Verify modal header
    expect(find.text('New Workload Task'), findsOneWidget);
    expect(find.text('ADD TO WORKLOAD'), findsOneWidget);

    // Tap submit without title
    await tester.tap(find.text('ADD TO WORKLOAD'));
    await tester.pumpAndSettle();

    // Form validator should trigger
    expect(find.text('Please enter a task title'), findsOneWidget);
  });
}

// ===================== MOCK NOTIFIERS FOR QA TESTING =====================

class MockTasksNotifier extends StateNotifier<List<DevTask>>
    implements TasksNotifier {
  MockTasksNotifier(super.initialTasks);

  @override
  Future<void> loadTasks() async {}

  @override
  void setTasks(List<DevTask> tasks) {
    state = tasks;
  }

  @override
  Future<void> toggleTaskStatus(String taskId) async {
    state = state.map((t) {
      if (t.id == taskId) {
        final nextStatus = t.status == TaskStatus.completed
            ? TaskStatus.pending
            : TaskStatus.completed;
        return t.copyWith(status: nextStatus);
      }
      return t;
    }).toList();
  }

  @override
  Future<void> addTask(DevTask task) async {
    state = [task, ...state];
  }

  @override
  Future<void> updateTask(DevTask updated) async {
    state = state.map((t) => t.id == updated.id ? updated : t).toList();
  }

  @override
  Future<void> deleteTask(String taskId) async {
    state = state.where((t) => t.id != taskId).toList();
  }
}

class MockCoursesNotifier extends StateNotifier<List<Course>>
    implements CoursesNotifier {
  MockCoursesNotifier(super.initialCourses);

  @override
  Future<void> loadCourses() async {}

  @override
  Future<void> addCourse(Course course) async {}

  @override
  Future<void> updateCourse(Course course) async {}

  @override
  Future<void> deleteCourse(String courseId) async {}

  @override
  Future<void> toggleTopic(String courseId, String topicId) async {}
}

class MockProjectsNotifier extends StateNotifier<List<Project>>
    implements ProjectsNotifier {
  MockProjectsNotifier(super.initialProjects);

  @override
  Future<void> loadProjects() async {}

  @override
  Future<void> addProject(Project project) async {}

  @override
  Future<void> updateProject(Project project) async {}

  @override
  Future<void> deleteProject(String projectId) async {}

  @override
  Future<void> toggleMilestone(String projectId, String milestoneId) async {}
}
