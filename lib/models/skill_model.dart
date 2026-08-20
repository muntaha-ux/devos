class SkillTopic {
  final String id;
  final String title;
  final bool isCompleted;

  SkillTopic({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  factory SkillTopic.fromJson(Map<String, dynamic> json) {
    return SkillTopic(
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

  SkillTopic copyWith({bool? isCompleted}) {
    return SkillTopic(
      id: id,
      title: title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class Skill {
  final String id;
  final String name;
  final String category;
  final String proficiencyLevel;
  final int progressPercentage;
  final List<SkillTopic> topics;

  Skill({
    required this.id,
    required this.name,
    required this.category,
    required this.proficiencyLevel,
    required this.progressPercentage,
    required this.topics,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    var rawTopics = json['topics'] as List? ?? [];
    List<SkillTopic> topicsList = rawTopics.map((t) => SkillTopic.fromJson(t)).toList();

    return Skill(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'Development',
      proficiencyLevel: json['proficiency_level'] ?? 'Intermediate',
      progressPercentage: json['progress_percentage'] ?? 0,
      topics: topicsList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'proficiency_level': proficiencyLevel,
        'progress_percentage': progressPercentage,
        'topics': topics.map((t) => t.toJson()).toList(),
      };
}
