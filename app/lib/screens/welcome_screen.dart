import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/app_constants.dart';
import '../providers/app_providers.dart';
import '../providers/auth_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/haptic.dart';
import '../widgets/lesson_card.dart';

/// One-shot post-signup screen. Removed from the back-stack via router
/// redirect logic in app_router.dart.
class WelcomeScreen extends ConsumerWidget {
  final String displayName;
  const WelcomeScreen({super.key, required this.displayName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStateProvider).valueOrNull;
    final todayLesson = ref.watch(todaysLessonProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          children: [
            // Greeting
            Text('WELCOME', style: AppText.label(size: 11, color: AppColors.inkMute)),
            const SizedBox(height: 8),
            Text(
              _greeting(displayName),
              style: AppText.display(size: 30, height: 1.15),
            ),
            const SizedBox(height: 12),
            Text(
              'Your first lesson is ready. Each morning, take five minutes with a Stoic. Carry the quote through the day.',
              style: AppText.body(size: 15, color: AppColors.inkSoft, height: 1.55),
            ),

            const SizedBox(height: 32),

            // Today's lesson preview
            if (todayLesson.valueOrNull != null) ...[
              Text("TODAY'S LESSON",
                  style: AppText.label(size: 11, color: AppColors.inkMute)),
              const SizedBox(height: 12),
              LessonCard(lesson: todayLesson.valueOrNull!),
            ],

            const SizedBox(height: 40),

            // Begin CTA — full width, accent
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: () async {
                  Haptic.medium();
                  // Mark onboarding complete
                  if (user != null && user.userId.isNotEmpty) {
                    try {
                      await ref.read(appwriteProvider).saveSettings(user.userId, {
                        'onboardingCompletedAt': DateTime.now().toUtc().toIso8601String(),
                        'marketingOptIn': false,
                      });
                    } catch (_) {/* fire-and-forget */}
                  }
                  if (context.mounted) {
                    context.go('/library?highlight=today-lesson');
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.paper,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Begin',
                  style: AppText.display(size: 18, color: AppColors.paper),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () {
                  Haptic.light();
                  if (context.mounted) context.go('/library');
                },
                child: Text('Skip for now',
                    style: AppText.body(size: 13, color: AppColors.inkMute)),
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: Text(
                'You can revisit this from Settings → Reset onboarding.',
                style: AppText.body(size: 11, color: AppColors.inkMute),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting(String name) {
    final hour = DateTime.now().hour;
    final time = hour < 5
        ? 'You\'re up late.'
        : hour < 12
            ? 'Good morning.'
            : hour < 17
                ? 'Good afternoon.'
                : 'Good evening.';
    if (name.isEmpty) return time;
    return '$time\nWelcome, $name.';
  }
}