class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final String eventType; // 'exam', 'assignment', 'project_deadline', 'learning_session', 'general'
  final DateTime startTime;
  final DateTime? endTime;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.eventType,
    required this.startTime,
    this.endTime,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      eventType: json['event_type'] ?? 'general',
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : DateTime.now(),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'event_type': eventType,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
      };

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    String? eventType,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventType: eventType ?? this.eventType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

