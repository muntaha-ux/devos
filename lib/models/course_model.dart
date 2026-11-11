class CourseTopic {
  final String id;
  final String title;
  final bool isCompleted;

  CourseTopic({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  factory CourseTopic.fromJson(Map<String, dynamic> json) {
    return CourseTopic(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'is_completed': isCompleted,
  };

  CourseTopic copyWith({bool? isCompleted}) {
    return CourseTopic(
      id: id,
      title: title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class Course {
  final String id;
  final String name;
  final String code;
  final String instructor;
  final double creditHours;
  final String description;
  final String colorHex;
  final int progressPercentage;
  final List<CourseTopic> topics;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.instructor,
    required this.creditHours,
    required this.description,
    required this.colorHex,
    required this.progressPercentage,
    required this.topics,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    var rawTopics =
        json['topics'] as List? ?? json['course_topics'] as List? ?? [];
    List<CourseTopic> topicsList = rawTopics
        .map((t) => CourseTopic.fromJson(t))
        .toList();

    return Course(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      instructor: json['instructor'] ?? '',
      creditHours: (json['credit_hours'] as num?)?.toDouble() ?? 3.0,
      description: json['description'] ?? '',
      colorHex: json['color_hex'] ?? '#06B6D4',
      progressPercentage: json['progress_percentage'] ?? 0,
      topics: topicsList,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'instructor': instructor,
    'credit_hours': creditHours,
    'description': description,
    'color_hex': colorHex,
    'progress_percentage': progressPercentage,
    'topics': topics.map((t) => t.toJson()).toList(),
  };

  Course copyWith({
    String? id,
    String? name,
    String? code,
    String? instructor,
    double? creditHours,
    String? description,
    String? colorHex,
    int? progressPercentage,
    List<CourseTopic>? topics,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      instructor: instructor ?? this.instructor,
      creditHours: creditHours ?? this.creditHours,
      description: description ?? this.description,
      colorHex: colorHex ?? this.colorHex,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      topics: topics ?? this.topics,
    );
  }
}
