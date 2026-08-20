class ResearchPaper {
  final String id;
  final String title;
  final String authors;
  final int publicationYear;
  final String topic;
  final String paperLink;
  final String personalNotes;
  final String keyFindings;
  final String status; // 'saved', 'reading', 'completed', 'important'
  final String? attachmentUrl; // Cloudflare R2 object reference

  ResearchPaper({
    required this.id,
    required this.title,
    required this.authors,
    required this.publicationYear,
    required this.topic,
    required this.paperLink,
    required this.personalNotes,
    required this.keyFindings,
    required this.status,
    this.attachmentUrl,
  });

  factory ResearchPaper.fromJson(Map<String, dynamic> json) {
    return ResearchPaper(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      authors: json['authors'] ?? '',
      publicationYear: json['publication_year'] ?? DateTime.now().year,
      topic: json['topic'] ?? '',
      paperLink: json['paper_link'] ?? '',
      personalNotes: json['personal_notes'] ?? '',
      keyFindings: json['key_findings'] ?? '',
      status: json['status'] ?? 'saved',
      attachmentUrl: json['attachment_url'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'authors': authors,
        'publication_year': publicationYear,
        'topic': topic,
        'paper_link': paperLink,
        'personal_notes': personalNotes,
        'key_findings': keyFindings,
        'status': status,
        'attachment_url': attachmentUrl,
      };

  ResearchPaper copyWith({
    String? id,
    String? title,
    String? authors,
    int? publicationYear,
    String? topic,
    String? paperLink,
    String? personalNotes,
    String? keyFindings,
    String? status,
    String? attachmentUrl,
  }) {
    return ResearchPaper(
      id: id ?? this.id,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      publicationYear: publicationYear ?? this.publicationYear,
      topic: topic ?? this.topic,
      paperLink: paperLink ?? this.paperLink,
      personalNotes: personalNotes ?? this.personalNotes,
      keyFindings: keyFindings ?? this.keyFindings,
      status: status ?? this.status,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }
}

