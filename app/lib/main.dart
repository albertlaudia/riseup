import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/auth_providers.dart';
import 'providers/favorites_provider.dart';
import 'router/app_router.dart';
import 'services/notification_service.dart';
import 'services/onboarding_service.dart';
import 'services/reminder_scheduler.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: RiseUpApp()));
}

/// Reads the user's theme preference from SharedPreferences. Live updates
/// when settings_screen changes the value via `setMode(...)`.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    state = _parse(p.getString('app.theme') ?? 'auto');
  }
  Future<void> setMode(String v) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('app.theme', v);
    state = _parse(v);
  }
  ThemeMode _parse(String v) => switch (v) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class RiseUpApp extends ConsumerStatefulWidget {
  const RiseUpApp({super.key});

  @override
  ConsumerState<RiseUpApp> createState() => _RiseUpAppState();
}

class _RiseUpAppState extends ConsumerState<RiseUpApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Theme first so we don't flash light/dark.
      await ref.read(themeModeProvider.notifier).load();
      // Notifications first (lightweight, idempotent).
      await NotificationService.instance.init();
      // Then warm the rest.
      await ref.read(userStateProvider.notifier).bootstrap();
      ref.read(sharedPrefsProvider);
      // Load favorites + achievements after auth state resolves.
      Future.microtask(() {
        ref.read(favoritesProvider.notifier).load();
        ref.read(unlockedAchievementsProvider.notifier).load();
        ref.read(journalProvider.notifier).load();
      });
      // Reschedule any daily reminder.
      await ref.read(reminderSchedulerProvider.notifier).reschedule();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'RiseUP — Stoic practice',
      theme: AppTheme.light(),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          // Clamp the text scale so the layout doesn't break with large fonts.
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.3),
          ),
          child: child!,
        );
      },
    );
  }
}