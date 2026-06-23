import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether the user has finished the 3-card onboarding flow.
class OnboardingService {
  OnboardingService(this._prefs);
  final SharedPreferences _prefs;

  static const _key = 'hasOnboarded';

  bool get hasOnboarded => _prefs.getBool(_key) ?? false;
  Future<void> markOnboarded() async => _prefs.setBool(_key, true);
  Future<void> reset() async => _prefs.remove(_key);
}

/// FutureProvider — call once at app start.
final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// Has the user seen the onboarding flow?
final hasOnboardedProvider = StateProvider<bool>((ref) {
  final prefsAsync = ref.watch(sharedPrefsProvider);
  return prefsAsync.maybeWhen(data: (p) => p.getBool('hasOnboarded') ?? false, orElse: () => false);
});
