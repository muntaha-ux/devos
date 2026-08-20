class Note {
  final String id;
  final String title;
  final String content;
  final String category;
  final bool isFavorite;
  final List<String> tags;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.isFavorite = false,
    required this.tags,
    required this.createdAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    var rawTags = json['tags'] as List? ?? [];
    List<String> tagsList = rawTags.map((t) => t.toString()).toList();

    return Note(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'General',
      isFavorite: json['is_favorite'] ?? false,
      tags: tagsList,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'category': category,
        'is_favorite': isFavorite,
        'tags': tags,
        'created_at': createdAt.toIso8601String(),
      };

  Note copyWith({bool? isFavorite}) {
    return Note(
      id: id,
      title: title,
      content: content,
      category: category,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags,
      createdAt: createdAt,
    );
  }
}
