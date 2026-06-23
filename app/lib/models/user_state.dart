/// The user state the app cares about — derived from Appwrite.
/// `tier` is a denormalized cache. The source of truth is `user_subscriptions`.
enum UserTier { free, pro }

class UserState {
  final String userId;             // Appwrite user id
  final String? email;
  final String? displayName;
  final UserTier tier;
  final String? activePlanCode;    // e.g. "pro_yearly"
  final DateTime? activeExpiresAt;
  final int xp;
  final int level;
  final int streakCurrent;
  final int streakLongest;
  final int totalLessons;

  const UserState({
    required this.userId,
    this.email,
    this.displayName,
    this.tier = UserTier.free,
    this.activePlanCode,
    this.activeExpiresAt,
    this.xp = 0,
    this.level = 1,
    this.streakCurrent = 0,
    this.streakLongest = 0,
    this.totalLessons = 0,
  });

  bool get isPro => tier == UserTier.pro;

  UserState copyWith({
    String? userId,
    String? email,
    String? displayName,
    UserTier? tier,
    String? activePlanCode,
    DateTime? activeExpiresAt,
    int? xp,
    int? level,
    int? streakCurrent,
    int? streakLongest,
    int? totalLessons,
  }) =>
      UserState(
        userId: userId ?? this.userId,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        tier: tier ?? this.tier,
        activePlanCode: activePlanCode ?? this.activePlanCode,
        activeExpiresAt: activeExpiresAt ?? this.activeExpiresAt,
        xp: xp ?? this.xp,
        level: level ?? this.level,
        streakCurrent: streakCurrent ?? this.streakCurrent,
        streakLongest: streakLongest ?? this.streakLongest,
        totalLessons: totalLessons ?? this.totalLessons,
      );

  static const UserState anonymous = UserState(userId: '');
}
