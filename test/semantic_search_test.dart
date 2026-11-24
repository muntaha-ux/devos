import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devos/core/services/semantic_search_service.dart';
import 'package:devos/models/task_model.dart';
import 'package:devos/models/note_model.dart';
import 'package:devos/models/course_model.dart';
import 'package:devos/models/project_model.dart';
import 'package:devos/models/skill_model.dart';
import 'package:devos/providers/app_providers.dart';
import 'package:devos/features/search/global_search_modal.dart';

void main() {
  group('SemanticSearchService Unit Tests', () {
    test('detectConcepts accurately identifies engineering domain ontologies', () {
      final dbConcepts = SemanticSearchService.detectConcepts('sql database');
      expect(dbConcepts.any((c) => c.label.contains('Database')), isTrue);

      final aiConcepts = SemanticSearchService.detectConcepts('deep learning model');
      expect(aiConcepts.any((c) => c.label.contains('Artificial Intelligence')), isTrue);

      final dsaConcepts = SemanticSearchService.detectConcepts('binary search tree');
      expect(dsaConcepts.any((c) => c.label.contains('Algorithms')), isTrue);

      final urgentConcepts = SemanticSearchService.detectConcepts('exam submission due asap');
      expect(urgentConcepts.any((c) => c.label.contains('Urgent Deadlines')), isTrue);

      final mobileConcepts = SemanticSearchService.detectConcepts('flutter widget state');
      expect(mobileConcepts.any((c) => c.label.contains('Frontend & Mobile')), isTrue);
    });

    test('Semantic expansion matches "sql" to PostgreSQL / Supabase notes and tasks', () {
      final sampleNote = Note(
        id: 'n1',
        title: 'Relational Schema Design',
        content: 'Configuring Row Level Security in Supabase tables.',
        category: 'Systems Architecture',
        tags: ['#postgres', '#security'],
        createdAt: DateTime.now(),
      );

      final results = SemanticSearchService.searchAll(
        query: 'sql',
        notes: [sampleNote],
      );

      expect(results.isNotEmpty, isTrue);
      expect(results.first.id, 'n1');
      expect(results.first.semanticReason, contains('Database'));
    });

    test('Semantic expansion matches "urgent" to high and urgent priority tasks', () {
      final urgentTask = DevTask(
        id: 't1',
        title: 'Microservices Architecture Review',
        description: 'Prepare diagrams for systems presentation.',
        category: 'project',
        priority: TaskPriority.urgent,
        status: TaskStatus.inProgress,
      );

      final lowTask = DevTask(
        id: 't2',
        title: 'Update README formatting',
        description: 'Fix markdown lint warnings.',
        category: 'general',
        priority: TaskPriority.low,
        status: TaskStatus.pending,
      );

      final results = SemanticSearchService.searchAll(
        query: 'urgent',
        tasks: [urgentTask, lowTask],
      );

      expect(results.isNotEmpty, isTrue);
      expect(results.first.id, 't1');
      expect(results.any((r) => r.id == 't2'), isFalse);
    });

    test('Fuzzy matching catches typos in queries like "algoritm"', () {
      final course = Course(
        id: 'c1',
        name: 'Design and Analysis of Algorithms',
        code: 'CSE 2201',
        instructor: 'Dr. Turing',
        creditHours: 3.0,
        description: 'Sorting, dynamic programming, and complexity.',
        colorHex: '#352554',
        progressPercentage: 45,
        topics: [CourseTopic(id: 'top1', title: 'Divide and Conquer')],
      );

      final results = SemanticSearchService.searchAll(
        query: 'algoritm',
        courses: [course],
      );

      expect(results.isNotEmpty, isTrue);
      expect(results.first.title, contains('CSE 2201'));
      expect(results.first.semanticReason, contains('Fuzzy match'));
    });

    test('searchAll aggregates and ranks entities across all 5 workspace domains', () {
      final tasks = [
        DevTask(
          id: 't-tree',
          title: 'Implement AVL Tree Traversal',
          description: 'Balance factors and rotations.',
          category: 'course',
          priority: TaskPriority.high,
          status: TaskStatus.pending,
        ),
      ];

      final notes = [
        Note(
          id: 'n-tree',
          title: 'B-Tree vs LSM Trees in Storage Engines',
          content: 'Database indexing comparison for SSD workloads.',
          category: 'Algorithms',
          tags: ['#storage', '#dsa'],
          createdAt: DateTime.now(),
        ),
      ];

      final courses = [
        Course(
          id: 'c-tree',
          name: 'Advanced Data Structures and Trees',
          code: 'CSE 3101',
          instructor: 'Dr. Knuth',
          creditHours: 3.0,
          description: 'Splay trees, red-black trees, and heaps.',
          colorHex: '#352554',
          progressPercentage: 20,
          topics: [],
        ),
      ];

      final projects = [
        Project(
          id: 'p-tree',
          title: 'Syntax Tree AST Visualizer',
          description: 'Flutter interactive tool for parsing grammars.',
          technologies: ['Flutter', 'Dart', 'Parser'],
          githubUrl: '',
          liveUrl: '',
          startDate: '2026-01-01',
          targetCompletionDate: '2026-06-01',
          status: 'in_progress',
          progressPercentage: 60,
          milestones: [],
        ),
      ];

      final skills = [
        Skill(
          id: 's-tree',
          name: 'Binary Trees Mastery',
          category: 'Data Structures',
          proficiencyLevel: 'Advanced',
          progressPercentage: 80,
          topics: [],
        ),
      ];

      final results = SemanticSearchService.searchAll(
        query: 'tree',
        tasks: tasks,
        notes: notes,
        courses: courses,
        projects: projects,
        skills: skills,
      );

      expect(results.length, 5);
      // All 5 domains represented
      final types = results.map((r) => r.type).toSet();
      expect(types.contains(SearchResultType.task), isTrue);
      expect(types.contains(SearchResultType.note), isTrue);
      expect(types.contains(SearchResultType.course), isTrue);
      expect(types.contains(SearchResultType.project), isTrue);
      expect(types.contains(SearchResultType.skill), isTrue);
    });
  });

  group('GlobalSearchDialog Widget Tests', () {
    testWidgets('GlobalSearchDialog renders input, suggested prompts, and handles query', (tester) async {
      int navigatedTab = -1;

      final testTasks = [
        DevTask(
          id: 't-ml',
          title: 'Train ResNet Computer Vision Model',
          description: 'PyTorch deep learning pipeline on GPU cluster.',
          category: 'project',
          priority: TaskPriority.high,
          status: TaskStatus.inProgress,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => TasksNotifier(ref.read(databaseRepositoryProvider))..setTasks(testTasks)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: GlobalSearchDialog(
                onNavigateToTab: (index) => navigatedTab = index,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header & Prompts
      expect(find.text('SEMANTIC SEARCH'), findsOneWidget);
      expect(find.text('SUGGESTED SEMANTIC PROMPTS'), findsOneWidget);
      expect(find.text('🔥 Urgent & High Priority'), findsOneWidget);

      // Enter semantic query "tree"
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'tree');
      await tester.pumpAndSettle();

      // Concept badge should appear for Algorithms & Data Structures
      expect(find.text('Concept: Algorithms & Data Structures'), findsOneWidget);

      // Result card should appear with task title
      expect(find.text('DSA Assignment 2: Binary Search Trees'), findsOneWidget);
      expect(find.text('TASK'), findsOneWidget);

      // Tap result card to navigate
      final resultCard = find.text('DSA Assignment 2: Binary Search Trees');
      await tester.tap(resultCard);
      await tester.pumpAndSettle();

      // Should have triggered navigation to Workload tab (index 2)
      expect(navigatedTab, 2);
    });
  });
}
