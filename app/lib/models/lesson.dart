enum LessonDifficulty {
  beginner,
  intermediate,
  advanced;

  String get label {
    switch (this) {
      case LessonDifficulty.beginner:     return 'Beginner';
      case LessonDifficulty.intermediate: return 'Intermediate';
      case LessonDifficulty.advanced:     return 'Advanced';
    }
  }

  static LessonDifficulty? fromString(String? s) {
    switch (s) {
      case 'beginner':     return LessonDifficulty.beginner;
      case 'intermediate': return LessonDifficulty.intermediate;
      case 'advanced':     return LessonDifficulty.advanced;
      default:             return null;
    }
  }
}

class Lesson {
  final String id;
  final String title;
  final String slug;
  final String? intro;
  final String content;
  final String? keyTakeaway;
  final String? actionStep;
  final String? authorId;
  final String? themeId;
  final int? readTimeMin;
  final LessonDifficulty? difficulty;
  final int? order;
  final bool isFeatured;
  final bool isPro;
  final String? coverUrl;

  const Lesson({
    required this.id,
    required this.title,
    required this.slug,
    this.intro,
    required this.content,
    this.keyTakeaway,
    this.actionStep,
    this.authorId,
    this.themeId,
    this.readTimeMin,
    this.difficulty,
    this.order,
    this.isFeatured = false,
    this.isPro = false,
    this.coverUrl,
  });

  factory Lesson.fromRecord(Map<String, dynamic> r) => Lesson(
        id: r['id'] as String,
        title: r['title'] as String? ?? '',
        slug: r['slug'] as String? ?? '',
        intro: r['intro'] as String?,
        content: r['content'] as String? ?? '',
        keyTakeaway: r['key_takeaway'] as String?,
        actionStep: r['action_step'] as String?,
        authorId: r['author'] as String?,
        themeId: r['theme'] as String?,
        readTimeMin: (r['read_time_min'] as num?)?.toInt(),
        difficulty: LessonDifficulty.fromString(r['difficulty'] as String?),
        order: (r['order'] as num?)?.toInt(),
        isFeatured: r['is_featured'] == true,
        isPro: r['is_pro'] == true,
        coverUrl: r['cover_url'] as String?,
      );
}
