import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../services/onboarding_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _index = 0;

  Future<void> _finish() async {
    final prefsAsync = ref.read(sharedPrefsProvider);
    final prefs = prefsAsync.valueOrNull;
    if (prefs != null) {
      await prefs.setBool('hasOnboarded', true);
    }
    ref.read(hasOnboardedProvider.notifier).state = true;
    if (mounted) context.go('/');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(onboardingProvider);
    return Scaffold(
      body: SafeArea(
        child: cards.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _fallback(context, ref, e),
          data: (list) {
            if (list.isEmpty) return _fallback(context, ref, 'No onboarding content yet');
            return Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _finish,
                    child: Text('Skip', style: AppText.body(size: 14, color: AppColors.inkMute)),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _OnboardingPage(card: list[i]),
                  ),
                ),
                _Dots(count: list.length, index: _index),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_index < list.length - 1) {
                          _pageController.nextPage(
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOut);
                        } else {
                          _finish();
                        }
                      },
                      child: Text(
                        _index < list.length - 1
                            ? (list[_index].cta ?? 'Next')
                            : (list[_index].cta ?? 'Begin'),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _fallback(BuildContext context, WidgetRef ref, Object err) {
    // No content yet (e.g. PB not seeded) — show a tiny built-in flow.
    final fb = const [
      _FbCard(icon: '🌿', title: 'A small, daily practice', body: 'A short lesson in the morning. A quote to carry through the day.', cta: 'Next'),
      _FbCard(icon: '🔥', title: 'Streaks, with mercy', body: 'Build a real practice, not a perfect one. You get one free freeze per month.', cta: 'Next'),
      _FbCard(icon: '🔔', title: 'Your reminder', body: 'Pick a time for the daily nudge. Quiet hours respected. Change it any time.', cta: 'Begin'),
    ];
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: TextButton(onPressed: _finish, child: const Text('Skip')),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: fb.length,
            itemBuilder: (_, i) => _OnboardingPage(card: fb[i]),
          ),
        ),
        _Dots(count: fb.length, index: _index),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (_index < fb.length - 1) {
                  _pageController.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
                } else {
                  _finish();
                }
              },
              child: Text(fb[_index].cta),
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.card});
  final dynamic card; // OnboardingCard | _FbCard

  @override
  Widget build(BuildContext context) {
    final icon = card.icon as String? ?? '✦';
    final title = card.title as String;
    final body = card.body as String;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 24),
          Text(title, textAlign: TextAlign.center, style: AppText.display(size: 32)),
          const SizedBox(height: 16),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppText.body(size: 16, color: AppColors.inkSoft, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.accent : AppColors.ink.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _FbCard {
  final String icon;
  final String title;
  final String body;
  final String cta;
  const _FbCard({required this.icon, required this.title, required this.body, required this.cta});
}
