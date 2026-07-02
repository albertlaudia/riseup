/// RiseUP — single source of truth for non-content constants.
///
/// Anything user-facing but not in PocketBase goes here.
/// Anything that's already in PocketBase (lessons, quotes, plans, etc.) does NOT
/// go here — read it from the data layer.
///
/// Categories:
///   [Branding]    - app name, tagline, support email, URLs
///   [Bundle]      - platform bundle identifiers
///   [Notifications] - local notification constants
///   [Engagement]  - XP rewards, streak defaults, prompts
///   [Limits]      - free tier, cache caps
///   [DailyPick]   - the deterministic day-of-year algorithm
///   [DeepLinks]   - URL schemes
class AppConstants {
  AppConstants._();

  // ────────── Branding ──────────
  static const String appName = 'RiseUP';
  static const String appTagline = 'A daily Stoic practice.';
  static const String supportEmail = 'support@riseup.app';
  static const String privacyUrl = 'https://riseup.app/privacy';
  static const String termsUrl = 'https://riseup.app/terms';
  static const String marketingUrl = 'https://riseup.app';

  // ────────── Bundle ──────────
  static const String bundleId = 'com.albertlaudia.riseup';

  // ────────── Notifications ──────────
  static const String notifChannelId = 'riseup_daily_reminder';
  static const String notifChannelName = 'Daily reminder';
  static const String notifChannelDescription =
      'Your morning nudge to today\'s Stoic practice.';
  static const int notifIdDailyReminder = 1001;

  /// Default reminder time when the user hasn't picked one yet.
  static const String defaultReminderTime = '07:00';

  /// Quick-pick options in the Settings reminder time picker.
  /// ('HH:MM', 'display label') pairs.
  static const List<(String, String)> reminderTimeOptions = [
    ('06:00', '6:00 am'),
    ('07:00', '7:00 am'),
    ('08:00', '8:00 am'),
    ('21:00', '9:00 pm'),
  ];

  static const String defaultNotifTitle = 'Today\'s practice';
  static const String defaultNotifBody = '5 minutes. It\'s ready.';

  // ────────── Engagement defaults ──────────
  /// XP earned per lesson completion (matches beginner lessons in seed).
  /// Pro lessons can override in PB via `rup_lessons.xp_reward`.
  static const int defaultXpPerLesson = 10;
  static const int xpPerQuoteRead = 2;

  /// Streak
  static const int streakFreezePerWeek = 2;
  static const int streakFreezeResetDay = 1; // Monday

  /// Rating prompt
  static const int ratingPromptAfterDays = 7;
  static const int ratingPromptAfterLessons = 5;

  /// Onboarding
  static const int firstLaunchHighlightSeconds = 8;

  // ────────── Free tier ──────────
  static const int freeLessonsPerWeek = 4;
  static const int freeReflectionPromptsPerWeek = 3;
  static const int freeQuickPracticesPerWeek = 7;

  // ────────── Cache limits ──────────
  static const int maxCachedLessons = 50;
  static const int maxCachedQuotes = 200;
  static const int cacheFreshHours = 24;

  // ────────── Download limits ──────────
  static const int maxDownloadsBytes = 500 * 1024 * 1024; // 500 MB
  static const int defaultSmartDownloadLessonCap = 5;
  static const int defaultSmartDownloadQuoteCap = 10;

  // ────────── DailyPick algorithm ──────────
  /// All "today" / "daily" deterministic picks share this anchor.
  /// index = daysSinceStart % totalItems
  static final DateTime dailyPickStart = DateTime.utc(2024, 1, 1);

  // ────────── Deep links ──────────
  static const String deepLinkScheme = 'riseup';
  // riseup://library/{slug}
  static const String deepLinkHostLibrary = 'library';

  // ────────── UI timings ──────────
  static const Duration shortAnim = Duration(milliseconds: 180);
  static const Duration mediumAnim = Duration(milliseconds: 280);
  static const Duration longAnim = Duration(milliseconds: 480);
}

/// Friendly error messages keyed by Appwrite exception type.
/// See lib/utils/errors.dart for the formatter.
class ErrorCopy {
  ErrorCopy._();
  // see lib/utils/errors.dart
}