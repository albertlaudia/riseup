import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_state.dart';
import '../services/reminder_scheduler.dart';
import 'app_providers.dart';

/// Holds the current Appwrite user. `null` = signed out.
final currentAppwriteUserProvider = StateProvider<User?>((ref) => null);

/// Derived user state — combines auth + subscription.
class UserNotifier extends StateNotifier<AsyncValue<UserState>> {
  UserNotifier(this.ref) : super(const AsyncValue.data(UserState.anonymous));
  final Ref ref;

  Future<void> bootstrap() async {
    state = const AsyncValue.loading();
    try {
      final aw = ref.read(appwriteProvider);
      final user = await aw.currentUser();
      if (user == null) {
        state = const AsyncValue.data(UserState.anonymous);
        ref.read(currentAppwriteUserProvider.notifier).state = null;
        return;
      }
      ref.read(currentAppwriteUserProvider.notifier).state = user;
      await _refresh(user.$id, user.email, user.name);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final aw = ref.read(appwriteProvider);
      await aw.signInEmail(email, password);
      final user = await aw.currentUser();
      if (user == null) throw 'Sign-in succeeded but no user returned';
      ref.read(currentAppwriteUserProvider.notifier).state = user;
      await _refresh(user.$id, user.email, user.name);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    bool marketingOptIn = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      final aw = ref.read(appwriteProvider);
      await aw.signUpEmail(email, password, name: displayName);
      // Auto-sign-in after sign-up
      await signIn(email: email, password: password);
      // Now save settings against the authenticated user
      try {
        final user = ref.read(currentAppwriteUserProvider);
        if (user != null) {
          await aw.saveSettings(user.$id, {
            'marketingOptIn': marketingOptIn,
            'displayName': displayName,
          });
        }
      } catch (_) {/* fire-and-forget */}
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    final aw = ref.read(appwriteProvider);
    await aw.signOut();
    ref.read(currentAppwriteUserProvider.notifier).state = null;
    state = const AsyncValue.data(UserState.anonymous);
  }

  Future<void> _refresh(String userId, String email, String name) async {
    final aw = ref.read(appwriteProvider);
    final active = await aw.activeSubscription(userId);
    final tier = active == null ? UserTier.free : UserTier.pro;
    final completed = await aw.totalLessons(userId);
    final xpSum = await aw.totalXp(userId);
    final settings = await aw.getSettings(userId);
    final quotesRead = (settings['quotesRead'] as int?) ?? 0;
    final displayName = (settings['displayName'] as String?) ??
        (name.isEmpty ? email.split('@').first : name);
    // Streak from local prefs (offline-first). markLessonToday() updates it.
    final prefs = await SharedPreferences.getInstance();
    final streakCurrent = prefs.getInt('streak.current') ?? 0;
    final streakLongest = prefs.getInt('streak.longest') ?? 0;
    state = AsyncValue.data(UserState(
      userId: userId,
      email: email,
      displayName: displayName,
      tier: tier,
      activePlanCode: active?.planCode,
      activeExpiresAt: active?.expiresAt,
      totalLessons: completed,
      quotesRead: quotesRead,
      streakCurrent: streakCurrent,
      streakLongest: streakLongest,
      xp: xpSum,
      level: 1 + (xpSum ~/ 50),
    ));
  }

  /// Call after the user completes a lesson to bump the streak.
  /// Returns the new current streak value.
  Future<int> markLessonToday() async {
    await _syncStreak();
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('streak.current') ?? 0;
    // Refresh state so the UI updates.
    final user = ref.read(currentAppwriteUserProvider);
    if (user != null) {
      await _refresh(user.$id, user.email, user.name);
    } else {
      // Anonymous: bump state directly
      final s = state.valueOrNull ?? UserState.anonymous;
      state = AsyncValue.data(s.copyWith(
        streakCurrent: current,
        streakLongest: prefs.getInt('streak.longest') ?? 0,
      ));
    }
    return current;
  }

  /// After a mock checkout or webhook, refresh state.
  Future<void> refresh() async {
    final user = ref.read(currentAppwriteUserProvider);
    if (user == null) return;
    await _refresh(user.$id, user.email, user.name);
    // Re-schedule daily reminder in case preferences changed.
    await ref.read(reminderSchedulerProvider.notifier).reschedule();
  }
}


  /// Sync the user's daily streak. Reads/writes SharedPreferences:
  ///   - 'streak.lastActiveDate' (yyyy-MM-dd)
  ///   - 'streak.current' (int)
  ///   - 'streak.longest' (int)
  /// Called from auth_providers.refresh() and from markLessonComplete flow.
  /// Server-side streak tracking is deferred — local is good enough for v1.
  Future<void> _syncStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateOnly(DateTime.now());
    final todayKey = today.toIso8601String().substring(0, 10);
    final last = prefs.getString('streak.lastActiveDate');
    var current = prefs.getInt('streak.current') ?? 0;
    var longest = prefs.getInt('streak.longest') ?? 0;

    if (last == todayKey) {
      // already counted today
      return;
    }
    if (last == null) {
      current = 1;
    } else {
      final lastDate = DateTime.tryParse(last);
      if (lastDate != null) {
        final delta = today.difference(lastDate).inDays;
        if (delta == 1) {
          current += 1;       // consecutive day
        } else if (delta > 1) {
          current = 1;         // gap, restart
        } else if (delta < 0) {
          return;              // clock went backward; skip
        }
      }
    }
    if (current > longest) longest = current;
    await prefs.setString('streak.lastActiveDate', todayKey);
    await prefs.setInt('streak.current', current);
    await prefs.setInt('streak.longest', longest);
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
final userStateProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserState>>((ref) {
  return UserNotifier(ref);
});
