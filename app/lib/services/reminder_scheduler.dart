import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lesson.dart';
import '../models/quote.dart';
import '../providers/app_providers.dart';
import 'daily_pick.dart';
import 'notification_service.dart';

/// Orchestrator for the daily reminder.
///
/// - On app start, after sign-in, or when settings change:
///   1. Read user's preference (notifications on/off, time)
///   2. If off → cancel any scheduled notification
///   3. If on → pick today's lesson + quote, schedule for that HH:MM
///
/// For MVP, scheduling is local-only (flutter_local_notifications on the
/// device). When the server-push / FCM layer ships, this same class becomes
/// the "write my intent" layer — the actual delivery moves to FCM, but
/// the logic of *what* to deliver stays here.
class ReminderScheduler {
  ReminderScheduler(this._ref);
  final Ref _ref;

  static const _spKeyNotifications = 'reminder.notifications';
  static const _spKeyTime = 'reminder.time';

  /// Default reminder time if the user hasn't picked one yet.
  static const defaultTime = '07:00';

  /// Triggered from main.dart at app start, from auth_providers on sign-in,
  /// and from settings_screen when the user toggles the switch or picks
  /// a new time.
  Future<void> reschedule() async {
    // Anonymous users can still get reminders; we use local prefs.
    final user = _ref.read(userStateProvider).valueOrNull;
    final prefs = await SharedPreferences.getInstance();

    bool notifications = prefs.getBool(_spKeyNotifications) ?? true;
    String time = prefs.getString(_spKeyTime) ?? defaultTime;

    // If signed in, prefer the per-user setting from Appwrite.
    if (user != null && user.userId.isNotEmpty) {
      try {
        final settings = await _ref.read(appwriteProvider).getSettings(user.userId);
        if (settings['notifications'] is bool) {
          notifications = settings['notifications'] as bool;
        }
        if (settings['dailyReminderTime'] is String) {
          time = settings['dailyReminderTime'] as String;
        }
      } catch (_) {/* noop */}
    }

    if (!notifications) {
      await NotificationService.instance.cancelDailyReminder();
      await prefs.setString(_spKeyTime, time);
      return;
    }

    // Pick today's content (same deterministic algorithm the home screen uses).
    final lesson = await _pickTodaysLesson();
    final quote = await _pickTodaysQuote();
    if (lesson == null) return;   // no content yet; skip silently

    final title = _buildTitle(lesson, quote);
    final body = _buildBody(lesson, quote);

    final ok = await NotificationService.instance.scheduleDailyReminder(
      time: time,
      title: title,
      body: body,
      lessonSlug: lesson.slug,
    );
    if (ok) {
      await prefs.setString(_spKeyTime, time);
    }
  }

  /// Cancel the daily reminder entirely (e.g. on sign-out).
  Future<void> cancel() async {
    await NotificationService.instance.cancelDailyReminder();
  }

  Future<Lesson?> _pickTodaysLesson() async {
    try {
      final all = await _ref.read(pocketBaseProvider).getLessons();
      if (all.isEmpty) return null;
      final idx = DailyPick.dayIndex(all.length);
      return all[idx];
    } catch (_) {
      return null;
    }
  }

  Future<Quote?> _pickTodaysQuote() async {
    try {
      final all = await _ref.read(pocketBaseProvider).getQuotes(featuredOnly: true);
      if (all.isEmpty) {
        // Fallback: any quote
        final any = await _ref.read(pocketBaseProvider).getQuotes();
        if (any.isEmpty) return null;
        return any[DailyPick.dayIndex(any.length)];
      }
      return all[DailyPick.dayIndex(all.length)];
    } catch (_) {
      return null;
    }
  }

  String _buildTitle(Lesson lesson, Quote? quote) {
    // Title = today's lesson title. Short, recognizable.
    return lesson.title;
  }

  String _buildBody(Lesson lesson, Quote? quote) {
    // Body = action-oriented. ~10-14 words so it fits on one line.
    if (quote != null) {
      return '5 minutes. Today\'s practice.';
    }
    return 'Today\'s practice is ready. ~5 min.';
  }
}

/// Riverpod-style entry points for the rest of the app.
class ReminderSchedulerNotifier extends StateNotifier<AsyncValue<void>> {
  ReminderSchedulerNotifier(this._ref) : super(const AsyncValue.data(null));
  final Ref _ref;

  Future<void> reschedule() async {
    state = const AsyncValue.loading();
    try {
      await ReminderScheduler(_ref).reschedule();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> cancel() async {
    await ReminderScheduler(_ref).cancel();
    state = const AsyncValue.data(null);
  }
}

final reminderSchedulerProvider =
    StateNotifierProvider<ReminderSchedulerNotifier, AsyncValue<void>>((ref) {
  return ReminderSchedulerNotifier(ref);
});
