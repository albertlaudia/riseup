import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/auth_providers.dart';
import 'router/app_router.dart';
import 'services/notification_service.dart';
import 'services/onboarding_service.dart';
import 'services/reminder_scheduler.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: RiseUpApp()));
}

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
      // Notifications first (lightweight, idempotent).
      await NotificationService.instance.init();
      // Then warm the rest.
      ref.read(userStateProvider.notifier).bootstrap();
      ref.read(sharedPrefsProvider);
      // Reschedule any daily reminder.
      await ref.read(reminderSchedulerProvider.notifier).reschedule();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'RiseUP — Stoic practice',
      theme: AppTheme.light(),
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
