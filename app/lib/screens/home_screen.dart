import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_constants.dart';
import '../models/lesson.dart';
import '../models/quote.dart';
import '../models/user_state.dart';
import '../providers/app_providers.dart';
import '../services/daily_pick.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/empty_state.dart';
import '../widgets/haptic.dart';
import '../widgets/lesson_card.dart';
import '../widgets/quote_card.dart';
import '../widgets/reengagement_banner.dart';
import '../widgets/streak_flame.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _highlightToday = false;

  @override
  void initState() {
    super.initState();
    _maybeHighlightFirstLaunch();
  }

  Future<void> _maybeHighlightFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final highlightedUntil = prefs.getInt('home.highlightedUntil') ?? 0;
    if (DateTime.now().millisecondsSinceEpoch < highlightedUntil) {
      if (mounted) setState(() => _highlightToday = true);
      // Auto-dismiss after the window
      await Future.delayed(const Duration(seconds: AppConstants.firstLaunchHighlightSeconds));
      if (mounted) setState(() => _highlightToday = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessons = ref.watch(allLessonsProvider);
    final quotes = ref.watch(featuredQuotesProvider);
    final lookup = ref.watch(lookupMapsProvider);
    final user = ref.watch(userStateProvider).valueOrNull;
    final hasUser = user != null && !user.isAnonymous;

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.paper,
        onRefresh: () async {
          Haptic.medium();
          ref.invalidate(allLessonsProvider);
          ref.invalidate(featuredQuotesProvider);
          // Brief delay so the spinner shows even on a fast cache hit
          await Future.delayed(const Duration(milliseconds: 250));
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TODAY',
                          style: AppText.label(size: 10, color: AppColors.inkMute)),
                      const SizedBox(height: 4),
                      _Greeting(user: user, hasUser: hasUser),
                    ],
                  ),
                ),
                if (hasUser && user.streakCurrent > 0) StreakFlame(days: user.streakCurrent),
              ],
            ),
            const SizedBox(height: 16),
            const ReEngagementBanner(),

            const SizedBox(height: 8),

            // Quick practice
            _QuickPracticeCard(onTap: () {
              Haptic.light();
              context.push('/quick-practice');
            }),
            const SizedBox(height: 8),

            // Daily lesson
            lessons.when(
              loading: () => const SkeletonCardList(count: 1, height: 220),
              error: (e, _) => ErrorView(
                message: 'Today\'s lesson hasn\'t arrived yet. Pull to refresh, or come back later.',
                onRetry: () => ref.invalidate(allLessonsProvider),
                icon: '🌧️',
              ),
              data: (list) {
                if (list.isEmpty) {
                  return const EmptyState(
                    icon: '🌱',
                    title: 'Today\'s lesson is brewing',
                    body: 'Pull down to refresh, or check back in a moment.',
                  );
                }
                final idx = DailyPick.dayIndex(list.length);
                final lesson = list[idx];
                return lookup.when(
                  loading: () => const SkeletonCardList(count: 1, height: 220),
                  error: (e, _) => ErrorView(
                    message: 'Couldn\'t load lesson details.',
                    onRetry: () => ref.invalidate(lookupMapsProvider),
                  ),
                  data: (maps) => _HighlightOnFirstLaunch(
                    active: _highlightToday,
                    onDismiss: () => setState(() => _highlightToday = false),
                    child: LessonCard(
                      lesson: lesson,
                      author: lesson.authorId == null
                          ? null
                          : maps.authors[lesson.authorId!],
                      theme: lesson.themeId == null
                          ? null
                          : maps.categories[lesson.themeId!],
                      variant: LessonCardVariant.hero,
                      locked: lesson.isPro && (user?.isPro ?? false) == false,
                      onTap: () => context.push('/library/${lesson.slug}'),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // Quote of the day
            quotes.when(
              loading: () => const SkeletonCardList(count: 1, height: 180),
              error: (e, _) => ErrorView(
                message: 'Couldn\'t load today\'s quote.',
                onRetry: () => ref.invalidate(featuredQuotesProvider),
                icon: '🌧️',
              ),
              data: (list) {
                if (list.isEmpty) return const SizedBox.shrink();
                final idx = DailyPick.dayIndex(list.length);
                final q = list[idx];
                return lookup.when(
                  loading: () => const SkeletonCardList(count: 1, height: 180),
                  error: (e, _) => ErrorView(message: 'Couldn\'t load quote details.'),
                  data: (maps) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Quote of the day', style: AppText.display(size: 22)),
                          TextButton(
                            onPressed: () {
                              Haptic.light();
                              context.push('/quotes');
                            },
                            child: const Text('All quotes'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      QuoteCard(
                        quote: q,
                        author: q.authorId == null ? null : maps.authors[q.authorId!],
                        theme: q.themeId == null ? null : maps.categories[q.themeId!],
                        size: QuoteCardSize.lg,
                        locked: q.isPro && (user?.isPro ?? false) == false,
                        onTap: () {
                          Haptic.medium();
                          // Increment read count optimistically
                          if (hasUser) {
                            ref.read(appwriteProvider).incrementQuotesRead(user.userId).then((_) {
                              ref.read(userStateProvider.notifier).refresh();
                            }).catchError((_) {/* fire-and-forget */});
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // Library preview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('The library', style: AppText.display(size: 22)),
                TextButton(
                  onPressed: () {
                    Haptic.light();
                    context.push('/library');
                  },
                  child: const Text('All lessons'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Fifteen lessons across eight themes.',
                style: AppText.body(size: 13, color: AppColors.inkMute)),
            const SizedBox(height: 12),
            lessons.when(
              loading: () => const SkeletonCardList(count: 2, height: 180),
              error: (e, _) => ErrorView(message: 'Couldn\'t load library.'),
              data: (list) {
                return lookup.when(
                  loading: () => const SkeletonCardList(count: 2, height: 180),
                  error: (e, _) => ErrorView(message: 'Couldn\'t load authors.'),
                  data: (maps) {
                    final preview = (list.toList()..shuffle()).take(4).toList();
                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                      physics: const NeverScrollableScrollPhysics(),
                      children: preview.map((l) {
                        return LessonCard(
                          lesson: l,
                          author: l.authorId == null ? null : maps.authors[l.authorId!],
                          theme: l.themeId == null ? null : maps.categories[l.themeId!],
                          locked: l.isPro && (user?.isPro ?? false) == false,
                          onTap: () => context.push('/library/${l.slug}'),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Returns a Stoic-toned greeting based on time of day, account state, and streak.
class _Greeting extends StatelessWidget {
  final UserState? user;
  final bool hasUser;
  const _Greeting({required this.user, required this.hasUser});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String time = hour < 5
        ? 'Late night.'
        : hour < 12
            ? 'Morning.'
            : hour < 17
                ? 'Afternoon.'
                : 'Evening.';

    String main = hasUser && (user.displayName?.isNotEmpty ?? false)
        ? 'Hello, ${user.displayName!}.'
        : 'Today, again.';

    String sub;
    if (!hasUser) {
      sub = 'Rise above the mood of the moment.';
    } else if (user.streakCurrent == 0) {
      sub = 'A fresh start awaits.';
    } else if (user.streakCurrent == 1) {
      sub = 'Day 1. You showed up.';
    } else if (user.streakCurrent < 7) {
      sub = 'Day ${user.streakCurrent}. Keep going.';
    } else if (user.streakCurrent < 30) {
      sub = 'Day ${user.streakCurrent}. A practice now.';
    } else {
      sub = 'Day ${user.streakCurrent}. The discipline holds.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(time, style: AppText.label(size: 11, color: AppColors.inkMute)),
        const SizedBox(height: 4),
        Text(main, style: AppText.display(size: 28, height: 1.1)),
        const SizedBox(height: 2),
        Text(sub,
            style: AppText.body(size: 14, color: AppColors.inkSoft, height: 1.4)
                .copyWith(fontStyle: FontStyle.italic)),
      ],
    );
  }
}

class _QuickPracticeCard extends StatelessWidget {
  final VoidCallback onTap;
  const _QuickPracticeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.paperCard,
          border: Border.all(color: AppColors.ink.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('⚡', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('60-second practice', style: AppText.display(size: 15)),
                  const SizedBox(height: 2),
                  Text(
                    'No time for a full lesson? A small dose.',
                    style: AppText.body(size: 12, color: AppColors.inkMute),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: AppColors.inkMute, size: 18),
          ],
        ),
      ),
    );
  }
}

/// Soft pulsing border that surrounds a widget for the first-launch
/// highlight window. Dismisses on tap.
class _HighlightOnFirstLaunch extends StatefulWidget {
  final Widget child;
  final bool active;
  final VoidCallback onDismiss;
  const _HighlightOnFirstLaunch({
    required this.child,
    required this.active,
    required this.onDismiss,
  });

  @override
  State<_HighlightOnFirstLaunch> createState() => _HighlightOnFirstLaunchState();
}

class _HighlightOnFirstLaunchState extends State<_HighlightOnFirstLaunch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _HighlightOnFirstLaunch old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.active) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return GestureDetector(
      onTap: () {
        Haptic.medium();
        widget.onDismiss();
      },
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.4 + 0.4 * _ctrl.value),
                        width: 2.5,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 12, right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Tap to begin',
                style: AppText.body(size: 11, color: AppColors.paper),
              ),
            ),
          ),
        ],
      ),
    );
  }
}