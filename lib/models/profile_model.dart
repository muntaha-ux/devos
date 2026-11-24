class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String avatarUrl;
  final String institution;
  final String major;
  final String academicYear;
  final int learningStreak;
  final String bio;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.avatarUrl,
    required this.institution,
    required this.major,
    required this.academicYear,
    required this.learningStreak,
    this.bio = '',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? 'Alex Dev',
      avatarUrl: json['avatar_url'] ?? '',
      institution: json['institution'] ?? 'University of Technology',
      major: json['major'] ?? 'Computer Science & Engineering',
      academicYear: json['academic_year'] ?? '3rd Year',
      learningStreak: json['learning_streak'] ?? 1,
      bio: json['bio'] ?? '',
    );
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? institution,
    String? major,
    String? academicYear,
    int? learningStreak,
    String? bio,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      institution: institution ?? this.institution,
      major: major ?? this.major,
      academicYear: academicYear ?? this.academicYear,
      learningStreak: learningStreak ?? this.learningStreak,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'institution': institution,
      'major': major,
      'academic_year': academicYear,
      'learning_streak': learningStreak,
      'bio': bio,
    };
  }
}
