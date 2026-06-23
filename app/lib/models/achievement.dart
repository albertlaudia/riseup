enum AchievementCondition {
  streak,
  lessonsCompleted,
  themesExplored,
  favorites,
  firstLesson,
  quoteRead,
  unknown;

  String get code {
    switch (this) {
      case AchievementCondition.streak:           return 'streak';
      case AchievementCondition.lessonsCompleted: return 'lessons_completed';
      case AchievementCondition.themesExplored:   return 'themes_explored';
      case AchievementCondition.favorites:        return 'favorites';
      case AchievementCondition.firstLesson:      return 'first_lesson';
      case AchievementCondition.quoteRead:        return 'quote_read';
      case AchievementCondition.unknown:          return 'unknown';
    }
  }

  static AchievementCondition fromString(String? s) {
    switch (s) {
      case 'streak':             return AchievementCondition.streak;
      case 'lessons_completed':  return AchievementCondition.lessonsCompleted;
      case 'themes_explored':    return AchievementCondition.themesExplored;
      case 'favorites':          return AchievementCondition.favorites;
      case 'first_lesson':       return AchievementCondition.firstLesson;
      case 'quote_read':         return AchievementCondition.quoteRead;
      default:                   return AchievementCondition.unknown;
    }
  }
}

class Achievement {
  final String id;
  final String code;
  final String title;
  final String? description;
  final String? icon;
  final int? xpReward;
  final AchievementCondition conditionType;
  final int? conditionValue;
  final int? order;
  final bool isPro;

  const Achievement({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    this.icon,
    this.xpReward,
    this.conditionType = AchievementCondition.unknown,
    this.conditionValue,
    this.order,
    this.isPro = false,
  });

  factory Achievement.fromRecord(Map<String, dynamic> r) => Achievement(
        id: r['id'] as String,
        code: r['code'] as String? ?? '',
        title: r['title'] as String? ?? '',
        description: r['description'] as String?,
        icon: r['icon'] as String?,
        xpReward: (r['xp_reward'] as num?)?.toInt(),
        conditionType: AchievementCondition.fromString(r['condition_type'] as String?),
        conditionValue: (r['condition_value'] as num?)?.toInt(),
        order: (r['order'] as num?)?.toInt(),
        isPro: r['is_pro'] == true,
      );
}
