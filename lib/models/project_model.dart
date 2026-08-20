class ProjectMilestone {
  final String id;
  final String title;
  final String targetDate;
  final bool isCompleted;

  ProjectMilestone({
    required this.id,
    required this.title,
    required this.targetDate,
    this.isCompleted = false,
  });

  factory ProjectMilestone.fromJson(Map<String, dynamic> json) {
    return ProjectMilestone(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      targetDate: json['target_date'] ?? '',
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'target_date': targetDate,
        'is_completed': isCompleted,
      };

  ProjectMilestone copyWith({bool? isCompleted}) {
    return ProjectMilestone(
      id: id,
      title: title,
      targetDate: targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class Project {
  final String id;
  final String title;
  final String description;
  final List<String> technologies;
  final String githubUrl;
  final String liveUrl;
  final String startDate;
  final String targetCompletionDate;
  final String status; // 'planning', 'in_progress', 'completed', 'on_hold'
  final int progressPercentage;
  final List<ProjectMilestone> milestones;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.technologies,
    required this.githubUrl,
    required this.liveUrl,
    required this.startDate,
    required this.targetCompletionDate,
    required this.status,
    required this.progressPercentage,
    required this.milestones,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    var rawTech = json['technologies'] as List? ?? [];
    List<String> techList = rawTech.map((e) => e.toString()).toList();

    var rawMiles = json['milestones'] as List? ?? [];
    List<ProjectMilestone> milestoneList =
        rawMiles.map((m) => ProjectMilestone.fromJson(m)).toList();

    return Project(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      technologies: techList,
      githubUrl: json['github_url'] ?? '',
      liveUrl: json['live_url'] ?? '',
      startDate: json['start_date'] ?? '',
      targetCompletionDate: json['target_completion_date'] ?? '',
      status: json['status'] ?? 'in_progress',
      progressPercentage: json['progress_percentage'] ?? 0,
      milestones: milestoneList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'technologies': technologies,
        'github_url': githubUrl,
        'live_url': liveUrl,
        'start_date': startDate,
        'target_completion_date': targetCompletionDate,
        'status': status,
        'progress_percentage': progressPercentage,
        'milestones': milestones.map((m) => m.toJson()).toList(),
      };

  Project copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? technologies,
    String? githubUrl,
    String? liveUrl,
    String? startDate,
    String? targetCompletionDate,
    String? status,
    int? progressPercentage,
    List<ProjectMilestone>? milestones,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      technologies: technologies ?? this.technologies,
      githubUrl: githubUrl ?? this.githubUrl,
      liveUrl: liveUrl ?? this.liveUrl,
      startDate: startDate ?? this.startDate,
      targetCompletionDate: targetCompletionDate ?? this.targetCompletionDate,
      status: status ?? this.status,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      milestones: milestones ?? this.milestones,
    );
  }
}

