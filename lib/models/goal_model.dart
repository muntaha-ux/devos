class GoalMilestone {
  final String id;
  final String title;
  final bool isCompleted;

  GoalMilestone({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  factory GoalMilestone.fromJson(Map<String, dynamic> json) {
    return GoalMilestone(
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

  GoalMilestone copyWith({bool? isCompleted}) {
    return GoalMilestone(
      id: id,
      title: title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class Goal {
  final String id;
  final String title;
  final String description;
  final String category;
  final String targetDate;
  final int progressPercentage;
  final String status;
  final List<GoalMilestone> milestones;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetDate,
    required this.progressPercentage,
    required this.status,
    required this.milestones,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    var rawMiles = json['milestones'] as List? ?? [];
    List<GoalMilestone> milestoneList =
        rawMiles.map((m) => GoalMilestone.fromJson(m)).toList();

    return Goal(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Career',
      targetDate: json['target_date'] ?? '',
      progressPercentage: json['progress_percentage'] ?? 0,
      status: json['status'] ?? 'active',
      milestones: milestoneList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'target_date': targetDate,
        'progress_percentage': progressPercentage,
        'status': status,
        'milestones': milestones.map((m) => m.toJson()).toList(),
      };
}
