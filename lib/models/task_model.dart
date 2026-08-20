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
  final String? relatedCourseName;
  final String? relatedProjectName;

  DevTask({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.dueDate,
    this.relatedCourseName,
    this.relatedProjectName,
  });

  factory DevTask.fromJson(Map<String, dynamic> json) {
    return DevTask(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'general',
      priority: _parsePriority(json['priority']),
      status: _parseStatus(json['status']),
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date']) : null,
      relatedCourseName: json['related_course_name'],
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
        'status': status.name,
        'due_date': dueDate?.toIso8601String(),
        'related_course_name': relatedCourseName,
        'related_project_name': relatedProjectName,
      };

  DevTask copyWith({
    TaskStatus? status,
    TaskPriority? priority,
  }) {
    return DevTask(
      id: id,
      title: title,
      description: description,
      category: category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate,
      relatedCourseName: relatedCourseName,
      relatedProjectName: relatedProjectName,
    );
  }
}
