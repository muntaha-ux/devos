import 'package:flutter_test/flutter_test.dart';
import 'package:devos/repositories/supabase_database_repository.dart';
import 'package:devos/models/task_model.dart';
import 'package:devos/models/note_model.dart';
import 'package:devos/models/course_model.dart';
import 'package:devos/models/skill_model.dart';
import 'package:devos/models/project_model.dart';

void main() {
  group('SupabaseDatabaseRepository Fallback & Demo Mode Tests', () {
    late SupabaseDatabaseRepository repo;

    setUp(() {
      repo = SupabaseDatabaseRepository(null);
    });

    test(
      'getCourses returns rich default sample courses when unauthenticated',
      () async {
        final courses = await repo.getCourses();
        expect(courses, isNotEmpty);
        expect(courses.length, equals(3));
        expect(courses[0].name, equals('Data Structures & Algorithms'));
        expect(courses[0].topics, isNotEmpty);
        expect(courses[0].progressPercentage, equals(50));
      },
    );

    test(
      'getSkills returns rich default sample skills when unauthenticated',
      () async {
        final skills = await repo.getSkills();
        expect(skills, isNotEmpty);
        expect(skills.length, equals(3));
        expect(skills[0].name, equals('Flutter & Dart Architecture'));
        expect(skills[0].topics, isNotEmpty);
        expect(skills[0].progressPercentage, equals(75));
      },
    );

    test(
      'getProjects returns rich default sample projects when unauthenticated',
      () async {
        final projects = await repo.getProjects();
        expect(projects, isNotEmpty);
        expect(projects.length, equals(3));
        expect(projects[0].title, equals('DevOS Engineering Workspace'));
        expect(projects[0].milestones, isNotEmpty);
        expect(projects[0].progressPercentage, equals(75));
      },
    );

    test(
      'getTasks returns 6 engineering tasks with priority indicators',
      () async {
        final tasks = await repo.getTasks();
        expect(tasks, isNotEmpty);
        expect(tasks.length, equals(6));

        // Verify urgent tasks exist
        final urgentTasks = tasks
            .where((t) => t.priority == TaskPriority.urgent)
            .toList();
        expect(urgentTasks, isNotEmpty);

        // Verify course and project linkage
        final courseTasks = tasks.where((t) => t.category == 'course').toList();
        final projectTasks = tasks
            .where((t) => t.category == 'project')
            .toList();
        expect(courseTasks, isNotEmpty);
        expect(projectTasks, isNotEmpty);
      },
    );

    test(
      'getNotes returns 5 technical notes with code snippets and tags',
      () async {
        final notes = await repo.getNotes();
        expect(notes, isNotEmpty);
        expect(notes.length, equals(5));

        final noteWithCode = notes.firstWhere((n) => n.content.contains('```'));
        expect(noteWithCode, isNotNull);
        expect(noteWithCode.tags, isNotEmpty);
      },
    );

    test(
      'getGoals, getResearchPapers, and getEvents return sample data',
      () async {
        final goals = await repo.getGoals();
        final papers = await repo.getResearchPapers();
        final events = await repo.getEvents();

        expect(goals, isNotEmpty);
        expect(papers, isNotEmpty);
        expect(events, isNotEmpty);
      },
    );
  });

  group('Supabase PostgREST Relational Join & Parser Tests', () {
    test('DevTask.fromJson accurately parses PostgREST joined courses and projects', () {
      final joinedTaskJson = {
        'id': 'task-uuid-1234',
        'user_id': 'user-uuid-5678',
        'title': 'Operating Systems Lab',
        'description': 'Simulate LRU page replacement',
        'category': 'course',
        'priority': 'high',
        'status': 'in_progress',
        'due_date': '2026-11-28T12:00:00Z',
        'related_course_id': 'course-uuid-9999',
        'courses': {'name': 'CSE-304 Operating Systems'},
        'related_project_id': 'proj-uuid-8888',
        'projects': {'title': 'DevOS Mobile App'},
      };

      final task = DevTask.fromJson(joinedTaskJson);
      expect(task.id, equals('task-uuid-1234'));
      expect(task.title, equals('Operating Systems Lab'));
      expect(task.priority, equals(TaskPriority.high));
      expect(task.status, equals(TaskStatus.inProgress));
      expect(task.relatedCourseName, equals('CSE-304 Operating Systems'));
      expect(task.relatedProjectName, equals('DevOS Mobile App'));
    });

    test('Note.fromJson automatically extracts hashtags from content if tags column absent', () {
      final noteJson = {
        'id': 'note-uuid-1111',
        'user_id': 'user-uuid-2222',
        'title': 'PostgreSQL RLS Architecture',
        'content': '''# PostgreSQL Row Level Security
Always enforce auth.uid() = user_id on private tables.
#postgresql #security #supabase #database''',
        'category': 'Architecture',
        'is_favorite': true,
        'created_at': '2026-11-24T10:00:00Z',
      };

      final note = Note.fromJson(noteJson);
      expect(note.id, equals('note-uuid-1111'));
      expect(note.title, equals('PostgreSQL RLS Architecture'));
      expect(
        note.tags,
        containsAll(['#postgresql', '#security', '#supabase', '#database']),
      );
    });

    test('Course.fromJson correctly parses nested course_topics from Supabase join', () {
      final courseJson = {
        'id': 'course-uuid-001',
        'name': 'Data Structures & Algorithms',
        'code': 'CSE 2201',
        'instructor': 'Dr. Alan Turing',
        'credit_hours': 3.0,
        'description': 'Advanced algorithmic analysis',
        'color_hex': '#06B6D4',
        'progress_percentage': 50,
        'course_topics': [
          {
            'id': 'topic-1',
            'title': 'Binary Search Trees',
            'is_completed': true,
          },
          {'id': 'topic-2', 'title': 'Graph Traversal', 'is_completed': false},
        ],
      };

      final course = Course.fromJson(courseJson);
      expect(course.topics.length, equals(2));
      expect(course.topics[0].title, equals('Binary Search Trees'));
      expect(course.topics[0].isCompleted, isTrue);
      expect(course.topics[1].isCompleted, isFalse);
    });

    test(
      'Skill.fromJson correctly parses nested skill_topics from Supabase join',
      () {
        final skillJson = {
          'id': 'skill-uuid-001',
          'name': 'Flutter & Dart Architecture',
          'category': 'Frontend & Mobile',
          'proficiency_level': 'Advanced',
          'progress_percentage': 75,
          'skill_topics': [
            {
              'id': 'st-1',
              'title': 'Riverpod State Management',
              'is_completed': true,
            },
            {'id': 'st-2', 'title': 'Shaders & Canvas', 'is_completed': false},
          ],
        };

        final skill = Skill.fromJson(skillJson);
        expect(skill.topics.length, equals(2));
        expect(skill.topics[0].isCompleted, isTrue);
        expect(skill.topics[1].isCompleted, isFalse);
      },
    );

    test('Project.fromJson correctly parses nested project_milestones from Supabase join', () {
      final projectJson = {
        'id': 'proj-uuid-001',
        'title': 'DevOS Engineering Workspace',
        'description': 'Full-stack engineering & academic dashboard',
        'technologies': ['Flutter', 'Dart', 'Supabase'],
        'github_url': 'https://github.com/developer/devos',
        'live_url': 'https://devos.app',
        'start_date': '2026-01-10',
        'target_completion_date': '2026-06-30',
        'status': 'in_progress',
        'progress_percentage': 75,
        'project_milestones': [
          {
            'id': 'pm-1',
            'title': 'Setup Supabase Schema',
            'is_completed': true,
            'target_date': '2026-02-15',
          },
          {
            'id': 'pm-2',
            'title': 'End-to-End Real-Time Sync',
            'is_completed': false,
            'target_date': '2026-05-15',
          },
        ],
      };

      final project = Project.fromJson(projectJson);
      expect(project.milestones.length, equals(2));
      expect(project.milestones[0].isCompleted, isTrue);
      expect(project.milestones[1].isCompleted, isFalse);
    });
  });
}
