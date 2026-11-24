import 'dart:math';
import 'package:flutter/material.dart';

import '../../models/task_model.dart';
import '../../models/note_model.dart';
import '../../models/course_model.dart';
import '../../models/project_model.dart';
import '../../models/skill_model.dart';

enum SearchResultType {
  task,
  note,
  course,
  project,
  skill;

  String get displayName {
    switch (this) {
      case SearchResultType.task:
        return 'Task';
      case SearchResultType.note:
        return 'Note';
      case SearchResultType.course:
        return 'Course';
      case SearchResultType.project:
        return 'Project';
      case SearchResultType.skill:
        return 'Skill';
    }
  }

  IconData get icon {
    switch (this) {
      case SearchResultType.task:
        return Icons.task_alt_rounded;
      case SearchResultType.note:
        return Icons.menu_book_rounded;
      case SearchResultType.course:
        return Icons.school_rounded;
      case SearchResultType.project:
        return Icons.folder_special_rounded;
      case SearchResultType.skill:
        return Icons.psychology_rounded;
    }
  }

  Color get color {
    switch (this) {
      case SearchResultType.task:
        return const Color(0xFF8F0030); // Crimson brand
      case SearchResultType.note:
        return const Color(0xFF1E56FF); // Blue
      case SearchResultType.course:
        return const Color(0xFF352554); // Purple brand
      case SearchResultType.project:
        return const Color(0xFFD97706); // Amber
      case SearchResultType.skill:
        return const Color(0xFF0EA358); // Green badge brand
    }
  }
}

class SearchResultItem {
  final String id;
  final String title;
  final String subtitle;
  final String snippet;
  final SearchResultType type;
  final double score;
  final String? semanticReason;
  final List<String> tags;
  final int targetTabIndex;
  final dynamic rawItem;

  const SearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.snippet,
    required this.type,
    required this.score,
    this.semanticReason,
    this.tags = const [],
    required this.targetTabIndex,
    this.rawItem,
  });
}

class SemanticConcept {
  final String label;
  final Set<String> triggers;
  final Set<String> relatedTerms;

  const SemanticConcept({
    required this.label,
    required this.triggers,
    required this.relatedTerms,
  });

  bool matchesQueryToken(String queryToken) {
    if (triggers.contains(queryToken)) return true;
    for (final trigger in triggers) {
      if (trigger.length >= 4 && (queryToken.contains(trigger) || trigger.contains(queryToken))) {
        return true;
      }
    }
    return false;
  }
}

/// Domain-aware Semantic Search Engine for DevOS Engineering Workspace.
///
/// Features:
/// 1. Concept Expansion & Engineering Ontologies (AI, DB, Systems, Mobile, DevOps, DSA, etc.)
/// 2. Multi-token weighted scoring (Exact, Substring, Synonym, Fuzzy Typo Tolerance)
/// 3. Priority and Deadline Semantic Intent matching ('urgent', 'due', 'exam')
/// 4. Unified global indexing across Tasks, Notes, Courses, Projects, and Skills.
class SemanticSearchService {
  static const List<SemanticConcept> concepts = [
    SemanticConcept(
      label: 'Database & Storage',
      triggers: {
        'db', 'database', 'sql', 'postgres', 'postgresql', 'supabase',
        'rdbms', 'nosql', 'query', 'table', 'schema', 'migration',
        'indexing', 'btree', 'b-tree', 'acid', 'transaction', 'orm',
      },
      relatedTerms: {
        'database', 'sql', 'postgresql', 'postgres', 'supabase', 'table',
        'schema', 'query', 'indexing', 'transactions', 'relational', 'r2',
        'cloudflare', 'storage', 'models', 'entities', 'repository',
      },
    ),
    SemanticConcept(
      label: 'Artificial Intelligence & ML',
      triggers: {
        'ai', 'ml', 'machine learning', 'deep learning', 'neural',
        'model', 'llm', 'transformer', 'nlp', 'cv', 'vision', 'pytorch',
        'tensorflow', 'training', 'inference', 'weights', 'dataset',
      },
      relatedTerms: {
        'ai', 'machine learning', 'neural', 'deep learning', 'model', 'llm',
        'nlp', 'transformer', 'vision', 'intelligence', 'training',
      },
    ),
    SemanticConcept(
      label: 'Frontend & Mobile UI',
      triggers: {
        'frontend', 'mobile', 'flutter', 'dart', 'react', 'ui', 'ux',
        'widget', 'component', 'animation', 'responsive', 'android', 'ios',
        'screen', 'theme', 'material', 'figma', 'design', 'layout',
      },
      relatedTerms: {
        'flutter', 'dart', 'ui', 'ux', 'widget', 'mobile', 'frontend',
        'screen', 'view', 'app', 'android', 'ios', 'layout', 'design',
      },
    ),
    SemanticConcept(
      label: 'Backend & APIs',
      triggers: {
        'backend', 'api', 'server', 'microservice', 'auth', 'endpoint',
        'crud', 'routing', 'middleware', 'controller', 'rest', 'http',
        'grpc', 'rpc', 'socket', 'gateway',
      },
      relatedTerms: {
        'backend', 'api', 'server', 'auth', 'endpoint', 'service', 'rest',
        'postgrest', 'http', 'controller', 'json', 'token', 'jwt',
      },
    ),
    SemanticConcept(
      label: 'Networking & Protocols',
      triggers: {
        'network', 'networking', 'tcp', 'udp', 'socket', 'http', 'dns',
        'ip', 'protocol', 'latency', 'websocket', 'bandwidth',
      },
      relatedTerms: {
        'network', 'networking', 'socket', 'tcp', 'udp', 'http', 'protocol',
        'distributed', 'connection', 'web', 'client', 'server',
      },
    ),
    SemanticConcept(
      label: 'Low-Level & Operating Systems',
      triggers: {
        'os', 'systems', 'kernel', 'operating system', 'memory', 'pointer',
        'concurrency', 'thread', 'process', 'assembly', 'c++', 'rust',
        'cache', 'lock', 'mutex', 'deadlock', 'paging',
      },
      relatedTerms: {
        'operating system', 'kernel', 'memory', 'concurrency',
        'threads', 'processes', 'c++', 'rust', 'low-level', 'posix',
      },
    ),
    SemanticConcept(
      label: 'Algorithms & Data Structures',
      triggers: {
        'dsa', 'algorithm', 'algorithms', 'tree', 'trees', 'bst', 'avl',
        'graph', 'graphs', 'bfs', 'dfs', 'sorting', 'dp',
        'dynamic programming', 'complexity', 'big-o', 'heap', 'stack',
        'queue', 'binary search', 'recursion',
      },
      relatedTerms: {
        'data structures', 'algorithms', 'trees', 'graphs', 'binary search',
        'sorting', 'complexity', 'dynamic programming', 'dsa', 'cse 2201',
      },
    ),
    SemanticConcept(
      label: 'Embedded Systems & Robotics',
      triggers: {
        'robotics', 'embedded', 'hardware', 'microcontroller', 'arduino',
        'raspberry pi', 'esp32', 'sensor', 'actuator', 'circuit', 'arm',
        'iot', 'firmware', 'ros', 'ros2', 'stm32', 'uart', 'baud',
      },
      relatedTerms: {
        'robotics', 'embedded', 'hardware', 'sensors', 'microcontroller',
        'circuits', 'automation', 'drone', 'stm32', 'ros2', 'uart',
      },
    ),
    SemanticConcept(
      label: 'Cloud & DevOps',
      triggers: {
        'cloud', 'devops', 'docker', 'kubernetes', 'container', 'ci/cd',
        'pipeline', 'deployment', 'vercel', 'actions', 'github', 'aws',
      },
      relatedTerms: {
        'cloud', 'devops', 'docker', 'vercel', 'github', 'actions', 'ci/cd',
        'deployment', 'hosting', 'production',
      },
    ),
    SemanticConcept(
      label: 'Urgent Deadlines & High Priority',
      triggers: {
        'urgent', 'critical', 'asap', 'high', 'priority', 'deadline', 'due',
        'overdue', 'exam', 'test', 'quiz', 'midterm', 'final', 'submission',
      },
      relatedTerms: {
        'urgent', 'high', 'deadline', 'due', 'exam', 'midterm', 'quiz',
        'final', 'assessment',
      },
    ),
    SemanticConcept(
      label: 'Completed & Finished Work',
      triggers: {'done', 'completed', 'finished', 'resolved', 'closed', 'passed'},
      relatedTerms: {'completed', 'done', 'finished', 'passed'},
    ),
  ];

  /// Computes Bigram / Sørensen-Dice similarity coefficient (0.0 to 1.0).
  static double diceSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.length < 2 || b.length < 2) return 0.0;

    final aBigrams = <String, int>{};
    for (int i = 0; i < a.length - 1; i++) {
      final bigram = a.substring(i, i + 2);
      aBigrams[bigram] = (aBigrams[bigram] ?? 0) + 1;
    }

    int matches = 0;
    for (int i = 0; i < b.length - 1; i++) {
      final bigram = b.substring(i, i + 2);
      final count = aBigrams[bigram] ?? 0;
      if (count > 0) {
        aBigrams[bigram] = count - 1;
        matches++;
      }
    }

    return (2.0 * matches) / ((a.length - 1) + (b.length - 1));
  }

  /// Extracts active semantic concepts for a given raw search query.
  static List<SemanticConcept> detectConcepts(String rawQuery) {
    final clean = rawQuery.trim().toLowerCase();
    if (clean.isEmpty) return [];

    final tokens = clean.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    final matched = <SemanticConcept>[];

    for (final concept in concepts) {
      bool hit = false;
      // Multi-word phrase check (only triggers containing space or >= 5 chars)
      for (final trigger in concept.triggers) {
        if (trigger.contains(' ') && clean.contains(trigger)) {
          hit = true;
          break;
        }
      }

      if (!hit) {
        // Individual token check
        for (final token in tokens) {
          if (concept.matchesQueryToken(token)) {
            hit = true;
            break;
          }
        }
      }

      if (hit) {
        matched.add(concept);
      }
    }

    return matched;
  }

  /// Evaluates semantic match score against a target text and collection of tags/topics.
  static (double score, String? reason) calculateMatchScore({
    required String query,
    required String title,
    required String body,
    List<String> tags = const [],
    List<SemanticConcept> activeConcepts = const [],
    bool isUrgentOrHigh = false,
    bool isCompleted = false,
  }) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return (0.0, null);

    final cleanTitle = title.toLowerCase();
    final cleanBody = body.toLowerCase();
    final cleanTags = tags.map((t) => t.toLowerCase().replaceAll('#', '')).toList();

    double totalScore = 0.0;
    String? topReason;

    // 1. Direct exact or substring match in Title (Highest weight)
    if (cleanTitle == cleanQuery) {
      totalScore += 150.0;
      topReason = 'Exact title match';
    } else if (cleanTitle.contains(cleanQuery)) {
      totalScore += 100.0;
      topReason = 'Title contains "$cleanQuery"';
    }

    // 2. Direct exact or substring match in Tags / Topics
    for (final tag in cleanTags) {
      if (tag == cleanQuery) {
        totalScore += 80.0;
        topReason ??= 'Tag match #$tag';
      } else if (tag.contains(cleanQuery)) {
        totalScore += 50.0;
        topReason ??= 'Tag match #$tag';
      }
    }

    // 3. Direct substring match in Body / Content
    if (cleanBody.contains(cleanQuery)) {
      totalScore += 40.0;
      topReason ??= 'Content match';
    }

    // 4. Multi-token decomposition & individual matching
    final tokens = cleanQuery.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (tokens.length > 1) {
      int matchedTokens = 0;
      for (final t in tokens) {
        if (cleanTitle.contains(t) || cleanBody.contains(t) || cleanTags.any((tag) => tag.contains(t))) {
          matchedTokens++;
        }
      }
      if (matchedTokens == tokens.length) {
        totalScore += 60.0;
        topReason ??= 'All query keywords matched';
      } else if (matchedTokens > 0) {
        totalScore += 20.0 * matchedTokens;
      }
    }

    // 5. Semantic Concept Expansion Matching
    for (final concept in activeConcepts) {
      // Check priority/status intent triggers
      if (concept.label.contains('Urgent') && isUrgentOrHigh) {
        totalScore += 65.0;
        topReason ??= 'Semantic: High/Urgent priority';
      }
      if (concept.label.contains('Completed') && isCompleted) {
        totalScore += 65.0;
        topReason ??= 'Semantic: Completed status';
      }

      // Check related conceptual terms against title, tags, and body
      for (final term in concept.relatedTerms) {
        if (cleanTitle.contains(term)) {
          totalScore += 45.0;
          topReason ??= 'Semantic match: ${concept.label}';
          break;
        } else if (cleanTags.any((tag) => tag.contains(term))) {
          totalScore += 35.0;
          topReason ??= 'Semantic topic: ${concept.label}';
          break;
        } else if (cleanBody.contains(term)) {
          totalScore += 20.0;
          topReason ??= 'Concept match: ${concept.label}';
          break;
        }
      }
    }

    // 6. Fuzzy Typo Tolerance for words >= 4 chars
    if (totalScore == 0.0 && cleanQuery.length >= 4) {
      final titleWords = cleanTitle.split(RegExp(r'\W+')).where((w) => w.length >= 4);
      for (final word in titleWords) {
        final similarity = diceSimilarity(cleanQuery, word);
        if (similarity >= 0.72) {
          totalScore += 50.0 * similarity;
          topReason = 'Fuzzy match with "$word"';
          break;
        }
      }
    }

    return (totalScore, topReason);
  }

  /// Searches all entities in the DevOS workspace and returns a ranked list of results.
  static List<SearchResultItem> searchAll({
    required String query,
    List<DevTask> tasks = const [],
    List<Note> notes = const [],
    List<Course> courses = const [],
    List<Project> projects = const [],
    List<Skill> skills = const [],
    SearchResultType? filterType,
  }) {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final activeConcepts = detectConcepts(cleanQuery);
    final results = <SearchResultItem>[];

    // --- Search Tasks (Tab Index 2: Workload) ---
    if (filterType == null || filterType == SearchResultType.task) {
      for (final task in tasks) {
        final (score, reason) = calculateMatchScore(
          query: cleanQuery,
          title: task.title,
          body: '${task.description} ${task.relatedCourseName ?? ''} ${task.relatedProjectName ?? ''}',
          tags: [task.category, task.priority.name, task.status.name],
          activeConcepts: activeConcepts,
          isUrgentOrHigh: task.priority == TaskPriority.urgent || task.priority == TaskPriority.high,
          isCompleted: task.status == TaskStatus.completed,
        );

        if (score > 0) {
          final subtitle = [
            task.priority.name.toUpperCase(),
            if (task.relatedCourseName != null) task.relatedCourseName!,
            if (task.relatedProjectName != null) task.relatedProjectName!,
            task.status == TaskStatus.completed ? 'DONE' : 'ACTIVE',
          ].join(' • ');

          results.add(SearchResultItem(
            id: task.id,
            title: task.title,
            subtitle: subtitle,
            snippet: task.description.isNotEmpty ? task.description : 'Task category: ${task.category}',
            type: SearchResultType.task,
            score: score,
            semanticReason: reason,
            tags: [task.category, task.priority.name],
            targetTabIndex: 2, // Workload Tab
            rawItem: task,
          ));
        }
      }
    }

    // --- Search Notes (Tab Index 5: Notes & Docs) ---
    if (filterType == null || filterType == SearchResultType.note) {
      for (final note in notes) {
        final (score, reason) = calculateMatchScore(
          query: cleanQuery,
          title: note.title,
          body: note.content,
          tags: [...note.tags, note.category],
          activeConcepts: activeConcepts,
        );

        if (score > 0) {
          // Extract snippet around matched terms if possible
          String snippet = note.content;
          final matchIdx = snippet.toLowerCase().indexOf(cleanQuery.toLowerCase());
          if (matchIdx > 30) {
            snippet = '...${snippet.substring(matchIdx - 20, min(snippet.length, matchIdx + 100))}...';
          } else if (snippet.length > 120) {
            snippet = '${snippet.substring(0, 120)}...';
          }

          results.add(SearchResultItem(
            id: note.id,
            title: note.title,
            subtitle: 'Folder: ${note.category} • ${note.tags.join(" ")}',
            snippet: snippet.replaceAll('\n', ' ').trim(),
            type: SearchResultType.note,
            score: score,
            semanticReason: reason,
            tags: note.tags,
            targetTabIndex: 5, // Notes Tab
            rawItem: note,
          ));
        }
      }
    }

    // --- Search Courses (Tab Index 1: Courses) ---
    if (filterType == null || filterType == SearchResultType.course) {
      for (final course in courses) {
        final topicTitles = course.topics.map((t) => t.title).toList();
        final (score, reason) = calculateMatchScore(
          query: cleanQuery,
          title: course.name,
          body: '${course.code} ${course.instructor} ${course.description} ${topicTitles.join(" ")}',
          tags: [course.code, ...topicTitles],
          activeConcepts: activeConcepts,
        );

        if (score > 0) {
          results.add(SearchResultItem(
            id: course.id,
            title: '${course.code}: ${course.name}',
            subtitle: 'Instructor: ${course.instructor} • ${course.creditHours} Credits',
            snippet: course.description.isNotEmpty ? course.description : 'Syllabus covering ${course.topics.length} topics',
            type: SearchResultType.course,
            score: score,
            semanticReason: reason,
            tags: [course.code, '${course.progressPercentage}% Complete'],
            targetTabIndex: 1, // Courses Tab
            rawItem: course,
          ));
        }
      }
    }

    // --- Search Projects (Tab Index 4: Projects) ---
    if (filterType == null || filterType == SearchResultType.project) {
      for (final project in projects) {
        final (score, reason) = calculateMatchScore(
          query: cleanQuery,
          title: project.title,
          body: '${project.description} ${project.technologies.join(" ")}',
          tags: project.technologies,
          activeConcepts: activeConcepts,
        );

        if (score > 0) {
          results.add(SearchResultItem(
            id: project.id,
            title: project.title,
            subtitle: 'Stack: ${project.technologies.join(", ")} • ${project.status.toUpperCase()}',
            snippet: project.description.isNotEmpty ? project.description : 'Engineering Project repository',
            type: SearchResultType.project,
            score: score,
            semanticReason: reason,
            tags: project.technologies,
            targetTabIndex: 4, // Projects Tab
            rawItem: project,
          ));
        }
      }
    }

    // --- Search Skills (Tab Index 3: Skills) ---
    if (filterType == null || filterType == SearchResultType.skill) {
      for (final skill in skills) {
        final topicTitles = skill.topics.map((t) => t.title).toList();
        final (score, reason) = calculateMatchScore(
          query: cleanQuery,
          title: skill.name,
          body: '${skill.category} ${skill.proficiencyLevel} ${topicTitles.join(" ")}',
          tags: [skill.category, skill.proficiencyLevel, ...topicTitles],
          activeConcepts: activeConcepts,
        );

        if (score > 0) {
          results.add(SearchResultItem(
            id: skill.id,
            title: skill.name,
            subtitle: 'Domain: ${skill.category} • Level: ${skill.proficiencyLevel}',
            snippet: 'Tracks ${skill.topics.length} engineering topics • ${skill.progressPercentage}% Mastery',
            type: SearchResultType.skill,
            score: score,
            semanticReason: reason,
            tags: [skill.category, skill.proficiencyLevel],
            targetTabIndex: 3, // Skills Tab
            rawItem: skill,
          ));
        }
      }
    }

    // Sort descending by calculated score
    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }

  /// Semantic filter helper for WorkloadScreen
  static List<DevTask> filterTasks(List<DevTask> tasks, String query) {
    if (query.trim().isEmpty) return tasks;
    final cleanQuery = query.trim();
    final activeConcepts = detectConcepts(cleanQuery);

    final scored = <({DevTask item, double score})>[];
    for (final task in tasks) {
      final (score, _) = calculateMatchScore(
        query: cleanQuery,
        title: task.title,
        body: '${task.description} ${task.relatedCourseName ?? ''} ${task.relatedProjectName ?? ''}',
        tags: [task.category, task.priority.name, task.status.name],
        activeConcepts: activeConcepts,
        isUrgentOrHigh: task.priority == TaskPriority.urgent || task.priority == TaskPriority.high,
        isCompleted: task.status == TaskStatus.completed,
      );
      if (score > 0) {
        scored.add((item: task, score: score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((s) => s.item).toList();
  }

  /// Semantic filter helper for NotesScreen
  static List<Note> filterNotes(List<Note> notes, String query) {
    if (query.trim().isEmpty) return notes;
    final cleanQuery = query.trim();
    final activeConcepts = detectConcepts(cleanQuery);

    final scored = <({Note item, double score})>[];
    for (final note in notes) {
      final (score, _) = calculateMatchScore(
        query: cleanQuery,
        title: note.title,
        body: note.content,
        tags: [...note.tags, note.category],
        activeConcepts: activeConcepts,
      );
      if (score > 0) {
        scored.add((item: note, score: score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((s) => s.item).toList();
  }

  /// Semantic filter helper for ProjectsScreen
  static List<Project> filterProjects(List<Project> projects, String query) {
    if (query.trim().isEmpty) return projects;
    final cleanQuery = query.trim();
    final activeConcepts = detectConcepts(cleanQuery);

    final scored = <({Project item, double score})>[];
    for (final project in projects) {
      final (score, _) = calculateMatchScore(
        query: cleanQuery,
        title: project.title,
        body: '${project.description} ${project.technologies.join(" ")}',
        tags: project.technologies,
        activeConcepts: activeConcepts,
      );
      if (score > 0) {
        scored.add((item: project, score: score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((s) => s.item).toList();
  }
}
