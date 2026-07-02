/// Favorites, journal, achievements, search providers.
///
/// - Favorites: optimistic UI + Appwrite sync
/// - Journal: list of past reflection entries
/// - Achievements: tracks which codes the user has unlocked + auto-unlock engine
/// - Search: shared query state across screens
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_providers.dart';
import 'auth_providers.dart';

// ────────────── Favorites ──────────────

class FavoritesNotifier extends StateNotifier<AsyncValue<Set<String>>> {
  FavoritesNotifier(this._ref) : super(const AsyncValue.data({}));
  final Ref _ref;

  /// Load the user's favorites. Called on sign-in.
  Future<void> load() async {
    final user = _ref.read(userStateProvider).valueOrNull;
    if (user == null || user.isAnonymous) {
      state = const AsyncValue.data({});
      return;
    }
    state = const AsyncValue.loading();
    try {
      final list = await _ref.read(appwriteProvider).getFavorites(user.userId);
      final set = list.map((f) => '${f.kind}:${f.targetId}').toSet();
      state = AsyncValue.data(set);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Toggle favorite on/off. Optimistic. Returns the new state (true = favorited).
  Future<bool> toggle({required String kind, required String targetId}) async {
    final user = _ref.read(userStateProvider).valueOrNull;
    final current = state.valueOrNull ?? <String>{};
    final key = '$kind:$targetId';
    final isFav = current.contains(key);
    final next = {...current};
    if (isFav) {
      next.remove(key);
    } else {
      next.add(key);
    }
    state = AsyncValue.data(next);

    if (user == null || user.isAnonymous) {
      // Local-only; persists in memory until app restart.
      return !isFav;
    }

    try {
      if (isFav) {
        await _ref.read(appwriteProvider).removeFavorite(user.userId, kind, targetId);
      } else {
        await _ref.read(appwriteProvider).addFavorite(user.userId, kind, targetId);
      }
    } catch (_) {/* re-sync on next load */}
    return !isFav;
  }

  bool isFavorite({required String kind, required String targetId}) {
    final s = state.valueOrNull;
    if (s == null) return false;
    return s.contains('$kind:$targetId');
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, AsyncValue<Set<String>>>((ref) {
  return FavoritesNotifier(ref);
});

// ────────────── Journal ──────────────

class JournalNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  JournalNotifier(this._ref) : super(const AsyncValue.data([]));
  final Ref _ref;

  Future<void> load({int limit = 30}) async {
    final user = _ref.read(userStateProvider).valueOrNull;
    if (user == null || user.isAnonymous) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final list = await _ref.read(appwriteProvider).getJournalEntries(user.userId, limit: limit);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final journalProvider =
    StateNotifierProvider<JournalNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return JournalNotifier(ref);
});

// ────────────── Search ──────────────

class SearchQueryNotifier extends StateNotifier<String> {
  SearchQueryNotifier() : super('');
  void set(String q) => state = q;
  void clear() => state = '';
}

final searchQueryProvider =
    StateNotifierProvider<SearchQueryNotifier, String>((ref) {
  return SearchQueryNotifier();
});

// ────────────── Achievements ──────────────

class UnlockedAchievementsNotifier
    extends StateNotifier<AsyncValue<Set<String>>> {
  UnlockedAchievementsNotifier(this._ref) : super(const AsyncValue.data({}));
  final Ref _ref;

  Future<void> load() async {
    final user = _ref.read(userStateProvider).valueOrNull;
    if (user == null || user.isAnonymous) {
      state = const AsyncValue.data({});
      return;
    }
    try {
      final codes = await _ref.read(appwriteProvider).getUnlockedAchievements(user.userId);
      state = AsyncValue.data(codes.toSet());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Evaluate all PB-defined achievements against user state. Newly-earned
  /// ones are inserted and returned. Call this after `markLessonComplete`.
  Future<List<String>> evaluateAndUnlock() async {
    final user = _ref.read(userStateProvider).valueOrNull;
    if (user == null || user.isAnonymous) return [];
    final already = state.valueOrNull ?? <String>{};
    final newlyEarned = <String>[];
    try {
      final all = await _ref.read(pocketBaseProvider).getAchievements();
      final completed = await _ref.read(appwriteProvider).totalLessons(user.userId);
      final prefs = await SharedPreferences.getInstance();
      final streak = prefs.getInt('streak.current') ?? 0;
      final quotesRead = user.quotesRead;

      for (final a in all) {
        if (already.contains(a.code)) continue;
        bool earned = false;
        switch (a.conditionType) {
          case 'first_lesson':
            earned = completed >= 1;
            break;
          case 'lessons_completed':
            earned = completed >= a.conditionValue;
            break;
          case 'streak':
            earned = streak >= a.conditionValue;
            break;
          case 'quote_read':
            earned = quotesRead >= a.conditionValue;
            break;
          default:
            earned = false;
        }
        if (earned) {
          try {
            await _ref.read(appwriteProvider).unlockAchievement(user.userId, a.code);
            newlyEarned.add(a.code);
          } catch (_) {/* one-at-a-time; not critical */}
        }
      }
      if (newlyEarned.isNotEmpty) {
        state = AsyncValue.data({...already, ...newlyEarned});
      }
    } catch (_) {/* silent */}
    return newlyEarned;
  }
}

final unlockedAchievementsProvider =
    StateNotifierProvider<UnlockedAchievementsNotifier, AsyncValue<Set<String>>>((ref) {
  return UnlockedAchievementsNotifier(ref);
});