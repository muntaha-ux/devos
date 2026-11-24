import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_model.dart';
import '../models/course_model.dart';
import '../models/skill_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../models/goal_model.dart';
import '../models/note_model.dart';
import '../models/research_model.dart';
import '../models/event_model.dart';

class SupabaseDatabaseRepository {
  final SupabaseClient? _explicitClient;

  SupabaseDatabaseRepository([SupabaseClient? client])
    : _explicitClient = client;

  SupabaseClient? get _clientOrNull {
    if (_explicitClient != null) return _explicitClient;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  SupabaseClient get _client {
    final client = _clientOrNull;
    if (client == null) {
      throw StateError('Supabase has not been initialized yet.');
    }
    return client;
  }

  String? get _currentUserId {
    try {
      return _clientOrNull?.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  // ===================== PROFILES =====================
  Future<UserProfile?> getProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final data = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        return UserProfile.fromJson(data);
      }

      // If profile row does not exist yet, create it from auth metadata
      final meta = user.userMetadata ?? {};
      final initialProfile = {
        'id': user.id,
        'email': user.email ?? '',
        'full_name': meta['full_name'] ?? 'Engineering Student',
        'avatar_url': meta['avatar_url'] ?? '',
        'institution': meta['institution'] ?? 'University of Technology',
        'major': meta['major'] ?? 'Computer Science & Engineering',
        'academic_year': meta['academic_year'] ?? '3rd Year (Junior)',
        'learning_streak': 1,
      };

      await _client.from('profiles').upsert(initialProfile);
      return UserProfile.fromJson(initialProfile);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      await _client
          .from('profiles')
          .update({
            'full_name': profile.fullName,
            'avatar_url': profile.avatarUrl,
            'institution': profile.institution,
            'major': profile.major,
            'academic_year': profile.academicYear,
            'learning_streak': profile.learningStreak,
          })
          .eq('id', userId);
    } catch (_) {}
  }

  // ===================== COURSES =====================
  static final List<Course> _defaultSampleCourses = [
    Course(
      id: 'course-1',
      name: 'Data Structures & Algorithms',
      code: 'CSE 2201',
      instructor: 'Dr. Alan Turing',
      creditHours: 3.0,
      description:
          'Advanced trees, graphs, dynamic programming, and complexity theory.',
      colorHex: '#06B6D4',
      progressPercentage: 50,
      topics: [
        CourseTopic(
          id: 'c1-t1',
          title: 'Binary Search Trees & AVL',
          isCompleted: true,
        ),
        CourseTopic(
          id: 'c1-t2',
          title: 'Graph Traversal (BFS / DFS)',
          isCompleted: true,
        ),
        CourseTopic(
          id: 'c1-t3',
          title: 'Dynamic Programming Knapsack',
          isCompleted: false,
        ),
        CourseTopic(
          id: 'c1-t4',
          title: 'Shortest Path (Dijkstra, Bellman-Ford)',
          isCompleted: false,
        ),
      ],
    ),
    Course(
      id: 'course-2',
      name: 'Distributed Systems & Cloud Computing',
      code: 'CSE 4105',
      instructor: 'Prof. Leslie Lamport',
      creditHours: 3.5,
      description: 'Consensus algorithms, Paxos, Raft, microservices, and high availability.',
      colorHex: '#10B981',
      progressPercentage: 33,
      topics: [
        CourseTopic(
          id: 'c2-t1',
          title: 'CAP Theorem & PACELC',
          isCompleted: true,
        ),
        CourseTopic(
          id: 'c2-t2',
          title: 'Raft Consensus Protocol',
          isCompleted: false,
        ),
        CourseTopic(
          id: 'c2-t3',
          title: 'Vector Clocks & Distributed Ordering',
          isCompleted: false,
        ),
      ],
    ),
    Course(
      id: 'course-3',
      name: 'Operating Systems & Concurrency',
      code: 'CSE 3102',
      instructor: 'Dr. Andrew Tanenbaum',
      creditHours: 4.0,
      description: 'Kernel architecture, virtual memory, synchronization primitives, and file systems.',
      colorHex: '#8F0030',
      progressPercentage: 67,
      topics: [
        CourseTopic(
          id: 'c3-t1',
          title: 'Process Synchronization & Semaphores',
          isCompleted: true,
        ),
        CourseTopic(
          id: 'c3-t2',
          title: 'Virtual Memory & Page Replacement',
          isCompleted: true,
        ),
        CourseTopic(
          id: 'c3-t3',
          title: 'UNIX VFS & Inode Allocation',
          isCompleted: false,
        ),
      ],
    ),
  ];

  Future<List<Course>> getCourses() async {
    final userId = _currentUserId;
    if (userId == null) return _defaultSampleCourses;
    try {
      final response = await _client
          .from('courses')
          .select('*, course_topics(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final list = (response as List).map((c) => Course.fromJson(c)).toList();
      return list.isEmpty ? _defaultSampleCourses : list;
    } catch (_) {
      return _defaultSampleCourses;
    }
  }

  Future<Course> addCourse(Course course) async {
    final userId = _currentUserId;
    if (userId == null) return course;

    final courseRes = await _client
        .from('courses')
        .insert({
          'user_id': userId,
          'name': course.name,
          'code': course.code,
          'instructor': course.instructor,
          'credit_hours': course.creditHours,
          'description': course.description,
          'color_hex': course.colorHex,
          'progress_percentage': course.progressPercentage,
        })
        .select()
        .single();

    final courseId = courseRes['id'].toString();
    final topics = <CourseTopic>[];

    if (course.topics.isNotEmpty) {
      final topicPayloads = course.topics.asMap().entries.map((entry) {
        return {
          'course_id': courseId,
          'title': entry.value.title,
          'is_completed': entry.value.isCompleted,
          'order_index': entry.key,
        };
      }).toList();

      final topicsRes = await _client
          .from('course_topics')
          .insert(topicPayloads)
          .select();
      topics.addAll((topicsRes as List).map((t) => CourseTopic.fromJson(t)));
    }

    return Course.fromJson({
      ...courseRes,
      'course_topics': topics.map((t) => t.toJson()).toList(),
    });
  }

  Future<void> updateCourse(Course course) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      await _client
          .from('courses')
          .update({
            'name': course.name,
            'code': course.code,
            'instructor': course.instructor,
            'credit_hours': course.creditHours,
            'description': course.description,
            'color_hex': course.colorHex,
            'progress_percentage': course.progressPercentage,
          })
          .eq('id', course.id)
          .eq('user_id', userId);
    } catch (_) {}
  }

  Future<void> deleteCourse(String courseId) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      await _client
          .from('courses')
          .delete()
          .eq('id', courseId)
          .eq('user_id', userId);
    } catch (_) {}
  }

  Future<void> toggleCourseTopic(String topicId, bool isCompleted) async {
    try {
      await _client
          .from('course_topics')
          .update({'is_completed': isCompleted})
          .eq('id', topicId);
    } catch (_) {}
  }

  // ===================== SKILLS =====================
  static final List<Skill> _defaultSampleSkills = [
    Skill(
      id: 'skill-1',
      name: 'Flutter & Dart Architecture',
      category: 'Frontend & Mobile',
      proficiencyLevel: 'Advanced',
      progressPercentage: 75,
      topics: [
        SkillTopic(
          id: 's1-t1',
          title: 'Riverpod State Management',
          isCompleted: true,
        ),
        SkillTopic(
          id: 's1-t2',
          title: 'SOLID Principles in Dart',
          isCompleted: true,
        ),
        SkillTopic(
          id: 's1-t3',
          title: 'Supabase PostgreSQL Integration',
          isCompleted: true,
        ),
        SkillTopic(
          id: 's1-t4',
          title: 'Custom Canvas & Shaders',
          isCompleted: false,
        ),
      ],
    ),
    Skill(
      id: 'skill-2',
      name: 'Distributed Systems & Backend',
      category: 'Backend & Cloud',
      proficiencyLevel: 'Intermediate',
      progressPercentage: 60,
      topics: [
        SkillTopic(
          id: 's2-t1',
          title: 'PostgreSQL Row Level Security',
          isCompleted: true,
        ),
        SkillTopic(
          id: 's2-t2',
          title: 'gRPC & Protocol Buffers',
          isCompleted: true,
        ),
        SkillTopic(
          id: 's2-t3',
          title: 'Kafka Event Streams',
          isCompleted: false,
        ),
        SkillTopic(
          id: 's2-t4',
          title: 'Raft Consensus Implementation',
          isCompleted: false,
        ),
      ],
    ),
    Skill(
      id: 'skill-3',
      name: 'Embedded Systems & ROS2',
      category: 'Robotics & Hardware',
      proficiencyLevel: 'Intermediate',
      progressPercentage: 50,
      topics: [
        SkillTopic(
          id: 's3-t1',
          title: 'UART Framing & Micro-ROS',
          isCompleted: true,
        ),
        SkillTopic(
          id: 's3-t2',
          title: 'STM32 Hardware Serial Interfacing',
          isCompleted: true,
        ),
        SkillTopic(
          id: 's3-t3',
          title: 'Kinematics & Motion Planning',
          isCompleted: false,
        ),
      ],
    ),
  ];

  Future<List<Skill>> getSkills() async {
    final userId = _currentUserId;
    if (userId == null) return _defaultSampleSkills;
    try {
      final response = await _client
          .from('skills')
          .select('*, skill_topics(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final list = (response as List).map((s) => Skill.fromJson(s)).toList();
      return list.isEmpty ? _defaultSampleSkills : list;
    } catch (_) {
      return _defaultSampleSkills;
    }
  }

  Future<Skill> addSkill(Skill skill) async {
    final userId = _currentUserId;
    if (userId == null) return skill;

    final skillRes = await _client
        .from('skills')
        .insert({
          'user_id': userId,
          'name': skill.name,
          'category': skill.category,
          'proficiency_level': skill.proficiencyLevel,
          'progress_percentage': skill.progressPercentage,
        })
        .select()
        .single();

    final skillId = skillRes['id'].toString();
    final topics = <SkillTopic>[];

    if (skill.topics.isNotEmpty) {
      final payloads = skill.topics.asMap().entries.map((entry) {
        return {
          'skill_id': skillId,
          'title': entry.value.title,
          'is_completed': entry.value.isCompleted,
          'order_index': entry.key,
        };
      }).toList();

      final topicsRes = await _client
          .from('skill_topics')
          .insert(payloads)
          .select();
      topics.addAll((topicsRes as List).map((t) => SkillTopic.fromJson(t)));
    }

    return Skill.fromJson({
      ...skillRes,
      'skill_topics': topics.map((t) => t.toJson()).toList(),
    });
  }

  Future<void> updateSkill(Skill skill) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      await _client
          .from('skills')
          .update({
            'name': skill.name,
            'category': skill.category,
            'proficiency_level': skill.proficiencyLevel,
            'progress_percentage': skill.progressPercentage,
          })
          .eq('id', skill.id)
          .eq('user_id', userId);
    } catch (_) {}
  }

  Future<void> deleteSkill(String skillId) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      await _client
          .from('skills')
          .delete()
          .eq('id', skillId)
          .eq('user_id', userId);
    } catch (_) {}
  }

  Future<void> toggleSkillTopic(String topicId, bool isCompleted) async {
    try {
      await _client
          .from('skill_topics')
          .update({'is_completed': isCompleted})
          .eq('id', topicId);
    } catch (_) {}
  }

  // ===================== PROJECTS =====================
  static final List<Project> _defaultSampleProjects = [
    Project(
      id: 'proj-1',
      title: 'DevOS Engineering Workspace',
      description: 'Full-stack engineering & academic dashboard built with Flutter & Supabase.',
      technologies: ['Flutter', 'Dart', 'Supabase', 'PostgreSQL'],
      githubUrl: 'https://github.com/developer/devos',
      liveUrl: 'https://devos.app',
      startDate: '2026-01-10',
      targetCompletionDate: '2026-06-30',
      status: 'in_progress',
      progressPercentage: 75,
      milestones: [
        ProjectMilestone(
          id: 'p1-m1',
          title: 'Setup Supabase Schema & Auth',
          targetDate: '2026-02-15',
          isCompleted: true,
        ),
        ProjectMilestone(
          id: 'p1-m2',
          title: 'SOLID Architecture Refactor',
          targetDate: '2026-03-30',
          isCompleted: true,
        ),
        ProjectMilestone(
          id: 'p1-m3',
          title: 'End-to-End Real-Time Sync',
          targetDate: '2026-05-15',
          isCompleted: false,
        ),
      ],
    ),
    Project(
      id: 'proj-2',
      title: 'Robotic Arm ROS2 Controller',
      description: '6-DOF robotic manipulator controller with STM32 UART bridge and micro-ROS.',
      technologies: ['C++', 'Python', 'ROS2', 'STM32'],
      githubUrl: 'https://github.com/developer/robotic-arm-ros2',
      liveUrl: '',
      startDate: '2026-02-01',
      targetCompletionDate: '2026-08-15',
      status: 'in_progress',
      progressPercentage: 50,
      milestones: [
        ProjectMilestone(
          id: 'p2-m1',
          title: 'Kinematics Solver in C++',
          targetDate: '2026-03-10',
          isCompleted: true,
        ),
        ProjectMilestone(
          id: 'p2-m2',
          title: 'Hardware UART Serial Driver',
          targetDate: '2026-04-20',
          isCompleted: true,
        ),
        ProjectMilestone(
          id: 'p2-m3',
          title: 'Trajectory Generation Node',
          targetDate: '2026-07-01',
          isCompleted: false,
        ),
      ],
    ),
    Project(
      id: 'proj-3',
      title: 'Distributed Key-Value Store',
      description: 'High-availability partitioned key-value store implementing Raft consensus.',
      technologies: ['Go', 'gRPC', 'Raft', 'Docker'],
      githubUrl: 'https://github.com/developer/raft-kv',
      liveUrl: '',
      startDate: '2026-03-01',
      targetCompletionDate: '2026-09-30',
      status: 'planning',
      progressPercentage: 25,
      milestones: [
        ProjectMilestone(
          id: 'p3-m1',
          title: 'Leader Election State Machine',
          targetDate: '2026-04-15',
          isCompleted: true,
        ),
        ProjectMilestone(
          id: 'p3-m2',
          title: 'Log Replication & Heartbeats',
          targetDate: '2026-06-01',
          isCompleted: false,
        ),
        ProjectMilestone(
          id: 'p3-m3',
          title: 'Snapshotting & Compaction',
          targetDate: '2026-08-30',
          isCompleted: false,
        ),
      ],
    ),
  ];

  Future<List<Project>> getProjects() async {
    final userId = _currentUserId;
    if (userId == null) return _defaultSampleProjects;
    try {
      final response = await _client
          .from('projects')
          .select('*, project_milestones(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final list = (response as List).map((p) => Project.fromJson(p)).toList();
      return list.isEmpty ? _defaultSampleProjects : list;
    } catch (_) {
      return _defaultSampleProjects;
    }
  }

  Future<Project> addProject(Project project) async {
    final userId = _currentUserId;
    if (userId == null) return project;

    final projectRes = await _client
        .from('projects')
        .insert({
          'user_id': userId,
          'title': project.title,
          'description': project.description,
          'technologies': project.technologies,
          'github_url': project.githubUrl,
          'live_url': project.liveUrl,
          'start_date': project.startDate.isNotEmpty ? project.startDate : null,
          'target_completion_date': project.targetCompletionDate.isNotEmpty
              ? project.targetCompletionDate
              : null,
          'status': project.status,
          'progress_percentage': project.progressPercentage,
        })
        .select()
        .single();

    final projectId = projectRes['id'].toString();
    final milestones = <ProjectMilestone>[];

    if (project.milestones.isNotEmpty) {
      final payloads = project.milestones.asMap().entries.map((entry) {
        return {
          'project_id': projectId,
          'title': entry.value.title,
          'target_date': entry.value.targetDate.isNotEmpty
              ? entry.value.targetDate
              : null,
          'is_completed': entry.value.isCompleted,
          'order_index': entry.key,
        };
      }).toList();

      final res = await _client
          .from('project_milestones')
          .insert(payloads)
          .select();
      milestones.addAll((res as List).map((m) => ProjectMilestone.fromJson(m)));
    }

    return Project.fromJson({
      ...projectRes,
      'project_milestones': milestones.map((m) => m.toJson()).toList(),
    });
  }

  Future<void> updateProject(Project project) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      await _client
          .from('projects')
          .update({
            'title': project.title,
            'description': project.description,
            'technologies': project.technologies,
            'github_url': project.githubUrl,
            'live_url': project.liveUrl,
            'start_date': project.startDate.isNotEmpty
                ? project.startDate
                : null,
            'target_completion_date': project.targetCompletionDate.isNotEmpty
                ? project.targetCompletionDate
                : null,
            'status': project.status,
            'progress_percentage': project.progressPercentage,
          })
          .eq('id', project.id)
          .eq('user_id', userId);
    } catch (_) {}
  }

  Future<void> deleteProject(String projectId) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      await _client
          .from('projects')
          .delete()
          .eq('id', projectId)
          .eq('user_id', userId);
    } catch (_) {}
  }

  Future<void> toggleProjectMilestone(
    String milestoneId,
    bool isCompleted,
  ) async {
    try {
      await _client
          .from('project_milestones')
          .update({'is_completed': isCompleted})
          .eq('id', milestoneId);
    } catch (_) {}
  }

  // ===================== TASKS =====================
  static final List<DevTask> _defaultSampleTasks = [
    DevTask(
      id: 'task-1',
      title: 'DSA Assignment 2: Binary Search Trees',
      description: 'Implement AVL balancing and Red-Black tree insertion with unit tests',
      category: 'course',
      priority: TaskPriority.urgent,
      status: TaskStatus.pending,
      dueDate: DateTime.now().add(const Duration(hours: 8)),
      relatedCourseName: 'CSE-301 Data Structures',
    ),
    DevTask(
      id: 'task-2',
      title: 'Debug ROS2 hardware serial node',
      description:
          'Resolve packet loss over UART at 115200 baud on STM32 controller',
      category: 'project',
      priority: TaskPriority.urgent,
      status: TaskStatus.inProgress,
      dueDate: DateTime.now().add(const Duration(hours: 24)),
      relatedProjectName: 'Robotic Arm ROS2',
    ),
    DevTask(
      id: 'task-3',
      title: 'Operating Systems: Virtual Memory Lab',
      description:
          'Simulate LRU and Second-Chance page replacement algorithms in C++',
      category: 'course',
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
      dueDate: DateTime.now().add(const Duration(days: 3)),
      relatedCourseName: 'CSE-304 Operating Systems',
    ),
    DevTask(
      id: 'task-4',
      title: 'Integrate Supabase Auth & PostgreSQL sync',
      description:
          'Set up real-time table listeners and JWT session renewal pipeline',
      category: 'project',
      priority: TaskPriority.high,
      status: TaskStatus.completed,
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      relatedProjectName: 'DevOS Mobile App',
    ),
    DevTask(
      id: 'task-5',
      title: 'Implement Workload Matrix & Task Filtering',
      description: 'Build state filter tabs (Pending, In Progress, Done) and course/project linkages',
      category: 'project',
      priority: TaskPriority.medium,
      status: TaskStatus.completed,
      dueDate: DateTime.now().subtract(const Duration(hours: 3)),
      relatedProjectName: 'DevOS Mobile App',
    ),
    DevTask(
      id: 'task-6',
      title: 'Database Systems: B-Tree Indexing Chapter 7',
      description: 'Complete practice problems on multi-level indexing and query execution plans',
      category: 'course',
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      dueDate: DateTime.now().add(const Duration(days: 5)),
      relatedCourseName: 'CSE-302 Database Systems',
    ),
  ];

  Future<List<DevTask>> getTasks() async {
    final userId = _currentUserId;
    if (userId == null) return _defaultSampleTasks;
    try {
      final response = await _client
          .from('tasks')
          .select('*, courses(name), projects(title)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final list = (response as List).map((t) => DevTask.fromJson(t)).toList();
      return list.isEmpty ? _defaultSampleTasks : list;
    } catch (_) {
      return _defaultSampleTasks;
    }
  }

  Future<DevTask> addTask(DevTask task) async {
    final userId = _currentUserId;
    if (userId == null) return task;

    try {
      final payload = <String, dynamic>{
        'user_id': userId,
        'title': task.title,
        'description': task.description,
        'category': task.category,
        'priority': task.priority.name,
        'status': task.status == TaskStatus.inProgress
            ? 'in_progress'
            : task.status.name,
        'due_date': task.dueDate?.toIso8601String(),
      };

      if (task.relatedCourseId != null &&
          task.relatedCourseId!.isNotEmpty &&
          task.relatedCourseId!.contains('-')) {
        payload['related_course_id'] = task.relatedCourseId;
      }
      if (task.relatedProjectId != null &&
          task.relatedProjectId!.isNotEmpty &&
          task.relatedProjectId!.contains('-')) {
        payload['related_project_id'] = task.relatedProjectId;
      }

      final res = await _client.from('tasks').insert(payload).select().single();
      return DevTask.fromJson({
        ...res,
        'related_course_name': task.relatedCourseName,
        'related_project_name': task.relatedProjectName,
      });
    } catch (_) {
      return task;
    }
  }

  Future<void> updateTask(DevTask task) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      final payload = <String, dynamic>{
        'title': task.title,
        'description': task.description,
        'category': task.category,
        'priority': task.priority.name,
        'status': task.status == TaskStatus.inProgress
            ? 'in_progress'
            : task.status.name,
        'due_date': task.dueDate?.toIso8601String(),
      };

      if (task.relatedCourseId != null &&
          task.relatedCourseId!.isNotEmpty &&
          task.relatedCourseId!.contains('-')) {
        payload['related_course_id'] = task.relatedCourseId;
      }
      if (task.relatedProjectId != null &&
          task.relatedProjectId!.isNotEmpty &&
          task.relatedProjectId!.contains('-')) {
        payload['related_project_id'] = task.relatedProjectId;
      }

      await _client
          .from('tasks')
          .update(payload)
          .eq('id', task.id)
          .eq('user_id', userId);
    } catch (_) {}
  }

  Future<void> deleteTask(String taskId) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      await _client
          .from('tasks')
          .delete()
          .eq('id', taskId)
          .eq('user_id', userId);
    } catch (_) {}
  }

  // ===================== GOALS =====================
  static final List<Goal> _defaultSampleGoals = [
    Goal(
      id: 'goal-1',
      title: 'Master Distributed Systems & Cloud Infrastructure',
      description: 'Achieve strong theoretical & practical mastery for engineering career.',
      category: 'Engineering',
      targetDate: '2026-12-31',
      progressPercentage: 50,
      status: 'active',
      milestones: [
        GoalMilestone(
          id: 'g1-m1',
          title: 'Finish Lamport distributed systems textbook',
          isCompleted: true,
        ),
        GoalMilestone(
          id: 'g1-m2',
          title: 'Deploy Kubernetes cluster on cloud infrastructure',
          isCompleted: false,
        ),
      ],
    ),
  ];

  Future<List<Goal>> getGoals() async {
    final userId = _currentUserId;
    if (userId == null) return _defaultSampleGoals;
    try {
      final response = await _client
          .from('goals')
          .select('*, goal_milestones(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final list = (response as List).map((g) => Goal.fromJson(g)).toList();
      return list.isEmpty ? _defaultSampleGoals : list;
    } catch (_) {
      return _defaultSampleGoals;
    }
  }

  Future<Goal> addGoal(Goal goal) async {
    final userId = _currentUserId;
    if (userId == null) return goal;

    final res = await _client
        .from('goals')
        .insert({
          'user_id': userId,
          'title': goal.title,
          'description': goal.description,
          'category': goal.category,
          'target_date': goal.targetDate.isNotEmpty ? goal.targetDate : null,
          'progress_percentage': goal.progressPercentage,
          'status': goal.status,
        })
        .select()
        .single();

    final goalId = res['id'].toString();
    final milestones = <GoalMilestone>[];

    if (goal.milestones.isNotEmpty) {
      final payloads = goal.milestones.asMap().entries.map((entry) {
        return {
          'goal_id': goalId,
          'title': entry.value.title,
          'is_completed': entry.value.isCompleted,
          'order_index': entry.key,
        };
      }).toList();

      final r = await _client.from('goal_milestones').insert(payloads).select();
      milestones.addAll((r as List).map((m) => GoalMilestone.fromJson(m)));
    }

    return Goal.fromJson({
      ...res,
      'goal_milestones': milestones.map((m) => m.toJson()).toList(),
    });
  }

  Future<void> updateGoal(Goal goal) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      await _client
          .from('goals')
          .update({
            'title': goal.title,
            'description': goal.description,
            'category': goal.category,
            'target_date': goal.targetDate.isNotEmpty ? goal.targetDate : null,
            'progress_percentage': goal.progressPercentage,
            'status': goal.status,
          })
          .eq('id', goal.id)
          .eq('user_id', userId);
    } catch (_) {}
  }

  Future<void> deleteGoal(String goalId) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      await _client
          .from('goals')
          .delete()
          .eq('id', goalId)
          .eq('user_id', userId);
    } catch (_) {}
  }

  Future<void> toggleGoalMilestone(String milestoneId, bool isCompleted) async {
    try {
      await _client
          .from('goal_milestones')
          .update({'is_completed': isCompleted})
          .eq('id', milestoneId);
    } catch (_) {}
  }

  // ===================== NOTES =====================
  static final List<Note> _defaultSampleNotes = [
    Note(
      id: 'note-1',
      title: 'Red-Black Tree Balancing & Rotation Invariants',
      category: 'Algorithms & DSA',
      isFavorite: true,
      tags: ['#trees', '#algorithms', '#cpp', '#dsa'],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      content: '''# Red-Black Tree Invariants

A **Red-Black Tree** is a self-balancing binary search tree where each node contains an extra bit for denoting color (`RED` or `BLACK`).

### Five Essential Properties:
1. Every node is either **red** or **black**.
2. The root is always **black**.
3. Every leaf (`NIL`) is **black**.
4. If a node is **red**, then both its children are **black** (no two consecutive reds).
5. For each node, all simple paths from the node to descendant leaves contain the same number of black nodes (*black-height*).

### Left Rotation Implementation (C++):
```cpp
void leftRotate(Node*& root, Node* x) {
    Node* y = x->right;
    x->right = y->left;
    if (y->left != nullptr) y->left->parent = x;
    y->parent = x->parent;
    if (x->parent == nullptr) root = y;
    else if (x == x->parent->left) x->parent->left = y;
    else x->parent->right = y;
    y->left = x;
    x->parent = y;
}
```

> **Complexity:** Rotation executes in strictly \$O(1)\$ time, guaranteeing tree height does not exceed \$2 \\log_2(n+1)\$.''',
    ),
    Note(
      id: 'note-2',
      title: 'Distributed Microservices: Event-Driven Sagas',
      category: 'System Architecture',
      isFavorite: true,
      tags: ['#architecture', '#distributed', '#patterns', '#backend'],
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      content: '''# Saga Pattern: Orchestration vs Choreography

In distributed architectures where multi-service ACID transactions are infeasible, the **Saga Pattern** provides eventual consistency across independent microservices.

### Architecture Comparison:
* **Choreography:** Each service publishes domain events; peer services consume and react independently.
* **Orchestration:** A centralized state machine coordinator directs transactions and executes compensating rollbacks.

### Compensating Rollback (PostgreSQL):
```sql
-- Rollback order reservation in case of payment processing failure
UPDATE order_reservations
SET status = 'COMPENSATED',
    cancelled_at = NOW(),
    metadata = jsonb_set(metadata, '{reason}', '"Payment authorization timeout"')
WHERE saga_id = 'c7a4b891' AND status = 'PENDING';
```

> **Rule of Thumb:** Idempotency keys are mandatory for all distributed consumer endpoints.''',
    ),
    Note(
      id: 'note-3',
      title: 'Supabase Realtime & PostgreSQL RLS Policies',
      category: 'DevOps & Cloud',
      isFavorite: false,
      tags: ['#supabase', '#postgresql', '#security', '#database'],
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      content: '''# Row Level Security (RLS) Guide

PostgreSQL Row Level Security restricts record visibility and mutations at the database engine layer based on the authenticated context (`auth.uid()`).

### RLS Policy Definition (SQL):
```sql
-- Enable RLS on notes table
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to view only their personal records
CREATE POLICY "Users can access own notes"
ON public.notes
FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
```

### Critical Rules:
* Foreign keys referenced in RLS predicates must be indexed to prevent table scans.
* Use `SECURITY DEFINER` on PostgreSQL trigger functions with locked search paths.''',
    ),
    Note(
      id: 'note-4',
      title: 'ROS2 Humble: Serial Bridge Node & UART Framing',
      category: 'Robotics & Embedded',
      isFavorite: false,
      tags: ['#ros2', '#robotics', '#python', '#embedded'],
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      content: '''# ROS2 Hardware Serial Bridge Node

Streaming hardware telemetry packets from an STM32 MCU over UART to a ROS2 computational graph.

### Python Node Implementation:
```python
import rclpy
from rclpy.node import Node
from std_msgs.msg import String
import serial

class SerialBridgeNode(Node):
    def __init__(self):
        super().__init__('serial_bridge_node')
        self.ser = serial.Serial('/dev/ttyUSB0', 115200, timeout=0.1)
        self.pub = self.create_publisher(String, 'telemetry/raw', 10)
        self.timer = self.create_timer(0.02, self.read_serial)

    def read_serial(self):
        if self.ser.in_waiting:
            line = self.ser.readline().decode('utf-8').strip()
            msg = String()
            msg.data = line
            self.pub.publish(msg)
```''',
    ),
    Note(
      id: 'note-5',
      title: 'Dart 3 Records & Exhaustive Pattern Matching',
      category: 'Quick Cheatsheets',
      isFavorite: false,
      tags: ['#dart', '#flutter', '#cheatsheet'],
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      content: '''# Dart 3 Records & Pattern Matching

Dart 3 provides first-class records, pattern matching, and sealed class hierarchies.

### Exhaustive Switch Expression:
```dart
sealed class AuthState {}
class Authenticated extends AuthState { final String email; Authenticated(this.email); }
class Unauthenticated extends AuthState {}
class AuthLoading extends AuthState {}

String renderStatus(AuthState state) => switch (state) {
  Authenticated(email: final email) => 'Logged in: \$email',
  Unauthenticated() => 'Guest Mode',
  AuthLoading() => 'Authenticating session...',
};
```''',
    ),
  ];

  Future<List<Note>> getNotes() async {
    final userId = _currentUserId;
    if (userId == null) return _defaultSampleNotes;
    try {
      final response = await _client
          .from('notes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final list = (response as List).map((n) => Note.fromJson(n)).toList();
      return list.isEmpty ? _defaultSampleNotes : list;
    } catch (_) {
      return _defaultSampleNotes;
    }
  }

  Future<Note> addNote(Note note) async {
    final userId = _currentUserId;
    if (userId == null) return note;

    try {
      final res = await _client
          .from('notes')
          .insert({
            'user_id': userId,
            'title': note.title,
            'content': note.content,
            'category': note.category,
            'is_favorite': note.isFavorite,
          })
          .select()
          .single();

      return Note.fromJson({...res, 'tags': note.tags});
    } catch (_) {
      return note;
    }
  }

  Future<void> updateNote(Note note) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      await _client
          .from('notes')
          .update({
            'title': note.title,
            'content': note.content,
            'category': note.category,
            'is_favorite': note.isFavorite,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', note.id)
          .eq('user_id', userId);
    } catch (_) {}
  }

  Future<void> deleteNote(String noteId) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      await _client
          .from('notes')
          .delete()
          .eq('id', noteId)
          .eq('user_id', userId);
    } catch (_) {}
  }

  // ===================== RESEARCH PAPERS =====================
  static final List<ResearchPaper> _defaultSampleResearch = [
    ResearchPaper(
      id: 'res-1',
      title: 'In Search of an Understandable Consensus Algorithm (Raft)',
      authors: 'Diego Ongaro and John Ousterhout',
      publicationYear: 2014,
      topic: 'Distributed Consensus',
      paperLink: 'https://raft.github.io/raft.pdf',
      personalNotes: 'Key insight: decomposes consensus into leader election, log replication, and safety.',
      keyFindings: 'Raft is significantly more understandable and debuggable than Multi-Paxos.',
      status: 'reading',
    ),
  ];

  Future<List<ResearchPaper>> getResearchPapers() async {
    final userId = _currentUserId;
    if (userId == null) return _defaultSampleResearch;
    try {
      final response = await _client
          .from('research')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final list = (response as List)
          .map((r) => ResearchPaper.fromJson(r))
          .toList();
      return list.isEmpty ? _defaultSampleResearch : list;
    } catch (_) {
      return _defaultSampleResearch;
    }
  }

  Future<ResearchPaper> addResearchPaper(ResearchPaper paper) async {
    final userId = _currentUserId;
    if (userId == null) return paper;

    final res = await _client
        .from('research')
        .insert({
          'user_id': userId,
          'title': paper.title,
          'authors': paper.authors,
          'publication_year': paper.publicationYear,
          'topic': paper.topic,
          'paper_link': paper.paperLink,
          'personal_notes': paper.personalNotes,
          'key_findings': paper.keyFindings,
          'status': paper.status,
        })
        .select()
        .single();

    return ResearchPaper.fromJson(res);
  }

  Future<void> updateResearchPaper(ResearchPaper paper) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      await _client
          .from('research')
          .update({
            'title': paper.title,
            'authors': paper.authors,
            'publication_year': paper.publicationYear,
            'topic': paper.topic,
            'paper_link': paper.paperLink,
            'personal_notes': paper.personalNotes,
            'key_findings': paper.keyFindings,
            'status': paper.status,
          })
          .eq('id', paper.id)
          .eq('user_id', userId);
    } catch (_) {}
  }

  Future<void> deleteResearchPaper(String paperId) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      await _client
          .from('research')
          .delete()
          .eq('id', paperId)
          .eq('user_id', userId);
    } catch (_) {}
  }

  // ===================== CALENDAR EVENTS =====================
  static final List<CalendarEvent> _defaultSampleEvents = [
    CalendarEvent(
      id: 'event-1',
      title: 'Algorithms Midterm Exam',
      description:
          'Auditorium Hall B - Topics: Graphs, BST, Dynamic Programming',
      eventType: 'exam',
      startTime: DateTime.now().add(const Duration(days: 4)),
      endTime: DateTime.now().add(const Duration(days: 4, hours: 2)),
    ),
    CalendarEvent(
      id: 'event-2',
      title: 'DevOS Milestone 2 Code Review',
      description: 'Live presentation of Supabase backend architecture',
      eventType: 'project_deadline',
      startTime: DateTime.now().add(const Duration(days: 2)),
      endTime: DateTime.now().add(const Duration(days: 2, hours: 1)),
    ),
  ];

  Future<List<CalendarEvent>> getEvents() async {
    final userId = _currentUserId;
    if (userId == null) return _defaultSampleEvents;
    try {
      final response = await _client
          .from('events')
          .select()
          .eq('user_id', userId)
          .order('start_time', ascending: true);

      final list = (response as List)
          .map((e) => CalendarEvent.fromJson(e))
          .toList();
      return list.isEmpty ? _defaultSampleEvents : list;
    } catch (_) {
      return _defaultSampleEvents;
    }
  }

  Future<CalendarEvent> addEvent(CalendarEvent event) async {
    final userId = _currentUserId;
    if (userId == null) return event;

    final res = await _client
        .from('events')
        .insert({
          'user_id': userId,
          'title': event.title,
          'description': event.description,
          'event_type': event.eventType,
          'start_time': event.startTime.toIso8601String(),
          'end_time': event.endTime?.toIso8601String(),
        })
        .select()
        .single();

    return CalendarEvent.fromJson(res);
  }

  Future<void> updateEvent(CalendarEvent event) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      await _client
          .from('events')
          .update({
            'title': event.title,
            'description': event.description,
            'event_type': event.eventType,
            'start_time': event.startTime.toIso8601String(),
            'end_time': event.endTime?.toIso8601String(),
          })
          .eq('id', event.id)
          .eq('user_id', userId);
    } catch (_) {}
  }

  Future<void> deleteEvent(String eventId) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      await _client
          .from('events')
          .delete()
          .eq('id', eventId)
          .eq('user_id', userId);
    } catch (_) {}
  }

  // ===================== DATABASE INITIAL SEEDER =====================
  Future<void> seedInitialWorkspaceDataIfEmpty() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final existingCourses = await _client
          .from('courses')
          .select('id')
          .eq('user_id', userId)
          .limit(1);

      if ((existingCourses as List).isNotEmpty) {
        return; // Already populated
      }

      // 1. Seed Courses
      final c1 = await _client
          .from('courses')
          .insert({
            'user_id': userId,
            'name': 'Data Structures & Algorithms',
            'code': 'CSE 2201',
            'instructor': 'Dr. Alan Turing',
            'credit_hours': 3.0,
            'description': 'Advanced trees, graphs, dynamic programming, and complexity theory.',
            'color_hex': '#06B6D4',
            'progress_percentage': 50,
          })
          .select()
          .single();

      await _client.from('course_topics').insert([
        {
          'course_id': c1['id'],
          'title': 'Binary Search Trees & AVL',
          'is_completed': true,
          'order_index': 0,
        },
        {
          'course_id': c1['id'],
          'title': 'Graph Traversal (BFS / DFS)',
          'is_completed': true,
          'order_index': 1,
        },
        {
          'course_id': c1['id'],
          'title': 'Dynamic Programming Knapsack',
          'is_completed': false,
          'order_index': 2,
        },
        {
          'course_id': c1['id'],
          'title': 'Shortest Path (Dijkstra, Bellman-Ford)',
          'is_completed': false,
          'order_index': 3,
        },
      ]);

      final c2 = await _client
          .from('courses')
          .insert({
            'user_id': userId,
            'name': 'Distributed Systems & Cloud Computing',
            'code': 'CSE 4105',
            'instructor': 'Prof. Leslie Lamport',
            'credit_hours': 3.5,
            'description': 'Consensus algorithms, Paxos, Raft, microservices, and high availability.',
            'color_hex': '#10B981',
            'progress_percentage': 33,
          })
          .select()
          .single();

      await _client.from('course_topics').insert([
        {
          'course_id': c2['id'],
          'title': 'CAP Theorem & PACELC',
          'is_completed': true,
          'order_index': 0,
        },
        {
          'course_id': c2['id'],
          'title': 'Raft Consensus Protocol',
          'is_completed': false,
          'order_index': 1,
        },
        {
          'course_id': c2['id'],
          'title': 'Vector Clocks & Distributed Ordering',
          'is_completed': false,
          'order_index': 2,
        },
      ]);

      final c3 = await _client
          .from('courses')
          .insert({
            'user_id': userId,
            'name': 'Operating Systems & Concurrency',
            'code': 'CSE 3102',
            'instructor': 'Dr. Andrew Tanenbaum',
            'credit_hours': 4.0,
            'description': 'Kernel architecture, virtual memory, synchronization primitives, and file systems.',
            'color_hex': '#8F0030',
            'progress_percentage': 67,
          })
          .select()
          .single();

      await _client.from('course_topics').insert([
        {
          'course_id': c3['id'],
          'title': 'Process Synchronization & Semaphores',
          'is_completed': true,
          'order_index': 0,
        },
        {
          'course_id': c3['id'],
          'title': 'Virtual Memory & Page Replacement',
          'is_completed': true,
          'order_index': 1,
        },
        {
          'course_id': c3['id'],
          'title': 'UNIX VFS & Inode Allocation',
          'is_completed': false,
          'order_index': 2,
        },
      ]);

      // 2. Seed Skills
      final s1 = await _client
          .from('skills')
          .insert({
            'user_id': userId,
            'name': 'Flutter & Dart Architecture',
            'category': 'Frontend & Mobile',
            'proficiency_level': 'Advanced',
            'progress_percentage': 75,
          })
          .select()
          .single();

      await _client.from('skill_topics').insert([
        {
          'skill_id': s1['id'],
          'title': 'Riverpod State Management',
          'is_completed': true,
          'order_index': 0,
        },
        {
          'skill_id': s1['id'],
          'title': 'SOLID Principles in Dart',
          'is_completed': true,
          'order_index': 1,
        },
        {
          'skill_id': s1['id'],
          'title': 'Supabase PostgreSQL Integration',
          'is_completed': true,
          'order_index': 2,
        },
        {
          'skill_id': s1['id'],
          'title': 'Custom Canvas & Shaders',
          'is_completed': false,
          'order_index': 3,
        },
      ]);

      final s2 = await _client
          .from('skills')
          .insert({
            'user_id': userId,
            'name': 'Distributed Systems & Backend',
            'category': 'Backend & Cloud',
            'proficiency_level': 'Intermediate',
            'progress_percentage': 60,
          })
          .select()
          .single();

      await _client.from('skill_topics').insert([
        {
          'skill_id': s2['id'],
          'title': 'PostgreSQL Row Level Security',
          'is_completed': true,
          'order_index': 0,
        },
        {
          'skill_id': s2['id'],
          'title': 'gRPC & Protocol Buffers',
          'is_completed': true,
          'order_index': 1,
        },
        {
          'skill_id': s2['id'],
          'title': 'Kafka Event Streams',
          'is_completed': false,
          'order_index': 2,
        },
        {
          'skill_id': s2['id'],
          'title': 'Raft Consensus Implementation',
          'is_completed': false,
          'order_index': 3,
        },
      ]);

      // 3. Seed Projects
      final p1 = await _client
          .from('projects')
          .insert({
            'user_id': userId,
            'title': 'DevOS Engineering Workspace',
            'description': 'Full-stack engineering & academic dashboard built with Flutter & Supabase.',
            'technologies': ['Flutter', 'Dart', 'Supabase', 'PostgreSQL'],
            'github_url': 'https://github.com/developer/devos',
            'live_url': 'https://devos.app',
            'status': 'in_progress',
            'progress_percentage': 75,
          })
          .select()
          .single();

      await _client.from('project_milestones').insert([
        {
          'project_id': p1['id'],
          'title': 'Setup Supabase Schema & Auth',
          'is_completed': true,
          'order_index': 0,
        },
        {
          'project_id': p1['id'],
          'title': 'SOLID Architecture Refactor',
          'is_completed': true,
          'order_index': 1,
        },
        {
          'project_id': p1['id'],
          'title': 'End-to-End Real-Time Sync',
          'is_completed': false,
          'order_index': 2,
        },
      ]);

      final p2 = await _client
          .from('projects')
          .insert({
            'user_id': userId,
            'title': 'Robotic Arm ROS2 Controller',
            'description': '6-DOF robotic manipulator controller with STM32 UART bridge and micro-ROS.',
            'technologies': ['C++', 'Python', 'ROS2', 'STM32'],
            'github_url': 'https://github.com/developer/robotic-arm-ros2',
            'live_url': '',
            'status': 'in_progress',
            'progress_percentage': 50,
          })
          .select()
          .single();

      await _client.from('project_milestones').insert([
        {
          'project_id': p2['id'],
          'title': 'Kinematics Solver in C++',
          'is_completed': true,
          'order_index': 0,
        },
        {
          'project_id': p2['id'],
          'title': 'Hardware UART Serial Driver',
          'is_completed': true,
          'order_index': 1,
        },
        {
          'project_id': p2['id'],
          'title': 'Trajectory Generation Node',
          'is_completed': false,
          'order_index': 2,
        },
      ]);

      // 4. Seed Tasks (All 6 engineering tasks linked to courses and projects)
      await _client.from('tasks').insert([
        {
          'user_id': userId,
          'title': 'DSA Assignment 2: Binary Search Trees',
          'description': 'Implement AVL balancing and Red-Black tree insertion with unit tests',
          'category': 'course',
          'priority': 'urgent',
          'status': 'pending',
          'due_date': DateTime.now()
              .add(const Duration(hours: 8))
              .toIso8601String(),
          'related_course_id': c1['id'],
        },
        {
          'user_id': userId,
          'title': 'Debug ROS2 hardware serial node',
          'description': 'Resolve packet loss over UART at 115200 baud on STM32 controller',
          'category': 'project',
          'priority': 'urgent',
          'status': 'in_progress',
          'due_date': DateTime.now()
              .add(const Duration(hours: 24))
              .toIso8601String(),
          'related_project_id': p2['id'],
        },
        {
          'user_id': userId,
          'title': 'Operating Systems: Virtual Memory Lab',
          'description': 'Simulate LRU and Second-Chance page replacement algorithms in C++',
          'category': 'course',
          'priority': 'high',
          'status': 'in_progress',
          'due_date': DateTime.now()
              .add(const Duration(days: 3))
              .toIso8601String(),
          'related_course_id': c3['id'],
        },
        {
          'user_id': userId,
          'title': 'Integrate Supabase Auth & PostgreSQL sync',
          'description': 'Set up real-time table listeners and JWT session renewal pipeline',
          'category': 'project',
          'priority': 'high',
          'status': 'completed',
          'due_date': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          'related_project_id': p1['id'],
        },
        {
          'user_id': userId,
          'title': 'Implement Workload Matrix & Task Filtering',
          'description': 'Build state filter tabs (Pending, In Progress, Done) and course/project linkages',
          'category': 'project',
          'priority': 'medium',
          'status': 'completed',
          'due_date': DateTime.now()
              .subtract(const Duration(hours: 3))
              .toIso8601String(),
          'related_project_id': p1['id'],
        },
        {
          'user_id': userId,
          'title': 'Database Systems: B-Tree Indexing Chapter 7',
          'description': 'Complete practice problems on multi-level indexing and query execution plans',
          'category': 'course',
          'priority': 'medium',
          'status': 'pending',
          'due_date': DateTime.now()
              .add(const Duration(days: 5))
              .toIso8601String(),
          'related_course_id': c1['id'],
        },
      ]);

      // 5. Seed Goals
      final g1 = await _client
          .from('goals')
          .insert({
            'user_id': userId,
            'title': 'Master Distributed Systems & Cloud Infrastructure',
            'description': 'Achieve strong theoretical & practical mastery for engineering career.',
            'category': 'Engineering',
            'target_date': DateTime.now()
                .add(const Duration(days: 90))
                .toIso8601String()
                .split('T')[0],
            'progress_percentage': 50,
            'status': 'active',
          })
          .select()
          .single();

      await _client.from('goal_milestones').insert([
        {
          'goal_id': g1['id'],
          'title': 'Finish Lamport distributed systems textbook',
          'is_completed': true,
          'order_index': 0,
        },
        {
          'goal_id': g1['id'],
          'title': 'Deploy Kubernetes cluster on cloud infrastructure',
          'is_completed': false,
          'order_index': 1,
        },
      ]);

      // 6. Seed Notes (All 5 technical notes with code snippets)
      for (final note in _defaultSampleNotes) {
        await _client.from('notes').insert({
          'user_id': userId,
          'title': note.title,
          'content': note.content,
          'category': note.category,
          'is_favorite': note.isFavorite,
        });
      }

      // 7. Seed Research Papers
      for (final paper in _defaultSampleResearch) {
        await _client.from('research').insert({
          'user_id': userId,
          'title': paper.title,
          'authors': paper.authors,
          'publication_year': paper.publicationYear,
          'topic': paper.topic,
          'paper_link': paper.paperLink,
          'personal_notes': paper.personalNotes,
          'key_findings': paper.keyFindings,
          'status': paper.status,
        });
      }

      // 8. Seed Events
      for (final event in _defaultSampleEvents) {
        await _client.from('events').insert({
          'user_id': userId,
          'title': event.title,
          'description': event.description,
          'event_type': event.eventType,
          'start_time': event.startTime.toIso8601String(),
          'end_time': event.endTime?.toIso8601String(),
        });
      }
    } catch (_) {}
  }
}
