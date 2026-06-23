import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_state.dart';
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

  Future<void> signIn(String email, String password) async {
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

  Future<void> signUp(String email, String password, {String? name}) async {
    state = const AsyncValue.loading();
    try {
      final aw = ref.read(appwriteProvider);
      await aw.signUpEmail(email, password, name: name);
      await signIn(email, password);
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
    state = AsyncValue.data(UserState(
      userId: userId,
      email: email,
      displayName: name.isEmpty ? email.split('@').first : name,
      tier: tier,
      activePlanCode: active?.planCode,
      activeExpiresAt: active?.expiresAt,
      totalLessons: completed,
      xp: completed * 10,
      level: 1 + (completed ~/ 5),
    ));
  }

  /// After a mock checkout or webhook, refresh state.
  Future<void> refresh() async {
    final user = ref.read(currentAppwriteUserProvider);
    if (user == null) return;
    await _refresh(user.$id, user.email, user.name);
  }
}

final userStateProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserState>>((ref) {
  return UserNotifier(ref);
});
