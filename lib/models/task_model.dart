enum TaskPriority { low, medium, high, urgent }

enum TaskStatus { pending, inProgress, completed }

class DevTask {
  final String id;
  final String title;
  final String description;
  final String category; // 'course', 'project', 'skill', 'research', 'general'
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final String? relatedCourseId;
  final String? relatedCourseName;
  final String? relatedProjectId;
  final String? relatedProjectName;

  DevTask({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.dueDate,
    this.relatedCourseId,
    this.relatedCourseName,
    this.relatedProjectId,
    this.relatedProjectName,
  });

  factory DevTask.fromJson(Map<String, dynamic> json) {
    return DevTask(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'general',
      priority: _parsePriority(json['priority']),
      status: _parseStatus(json['status']),
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'])
          : null,
      relatedCourseId: json['related_course_id']?.toString(),
      relatedCourseName: json['related_course_name'],
      relatedProjectId: json['related_project_id']?.toString(),
      relatedProjectName: json['related_project_name'],
    );
  }

  static TaskPriority _parsePriority(String? p) {
    switch (p?.toLowerCase()) {
      case 'urgent':
        return TaskPriority.urgent;
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.medium;
      case 'low':
      default:
        return TaskPriority.low;
    }
  }

  static TaskStatus _parseStatus(String? s) {
    switch (s?.toLowerCase()) {
      case 'completed':
        return TaskStatus.completed;
      case 'in_progress':
      case 'in progress':
      case 'inprogress':
        return TaskStatus.inProgress;
      case 'pending':
      default:
        return TaskStatus.pending;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'priority': priority.name,
    'status': status == TaskStatus.inProgress ? 'in_progress' : status.name,
    'due_date': dueDate?.toIso8601String(),
    'related_course_id': relatedCourseId,
    'related_course_name': relatedCourseName,
    'related_project_id': relatedProjectId,
    'related_project_name': relatedProjectName,
  };

  DevTask copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    String? relatedCourseId,
    String? relatedCourseName,
    String? relatedProjectId,
    String? relatedProjectName,
  }) {
    return DevTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      relatedCourseId: relatedCourseId ?? this.relatedCourseId,
      relatedCourseName: relatedCourseName ?? this.relatedCourseName,
      relatedProjectId: relatedProjectId ?? this.relatedProjectId,
      relatedProjectName: relatedProjectName ?? this.relatedProjectName,
    );
  }
}
