import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/lesson.dart';
import '../models/quote.dart';
import '../providers/app_providers.dart';
import '../services/daily_pick.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/lesson_card.dart';
import '../widgets/quote_card.dart';
import '../widgets/streak_flame.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = ref.watch(allLessonsProvider);
    final quotes  = ref.watch(featuredQuotesProvider);
    final lookup  = ref.watch(lookupMapsProvider);
    final user    = ref.watch(userStateProvider).valueOrNull;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allLessonsProvider);
          ref.invalidate(featuredQuotesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TODAY', style: AppText.label(size: 10, color: AppColors.inkMute)),
                    const SizedBox(height: 4),
                    Text('Rise above', style: AppText.display(size: 30, height: 1)),
                    Text('the mood of the moment.', style: AppText.display(size: 30, height: 1, color: AppColors.accent).copyWith(fontStyle: FontStyle.italic)),
                  ],
                ),
                if (user != null && user.userId.isNotEmpty) StreakFlame(days: user.streakCurrent),
              ],
            ),
            const SizedBox(height: 24),

            // Daily lesson
            lessons.when(
              loading: () => const _Skeletons(height: 220),
              error: (e, _) => _ErrorBlock(message: '$e'),
              data: (list) {
                if (list.isEmpty) return const SizedBox.shrink();
                final idx = DailyPick.dayIndex(list.length);
                final lesson = list[idx];
                return lookup.when(
                  loading: () => const _Skeletons(height: 220),
                  error: (e, _) => _ErrorBlock(message: '$e'),
                  data: (maps) {
                    return LessonCard(
                      lesson: lesson,
                      author: lesson.authorId == null ? null : maps.authors[lesson.authorId!],
                      theme:  lesson.themeId  == null ? null : maps.categories[lesson.themeId!],
                      variant: LessonCardVariant.hero,
                      locked: lesson.isPro && (user?.isPro ?? false) == false,
                      onTap: () => context.push('/library/${lesson.slug}'),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 28),

            // Quote of the day
            quotes.when(
              loading: () => const _Skeletons(height: 180),
              error: (e, _) => _ErrorBlock(message: '$e'),
              data: (list) {
                if (list.isEmpty) return const SizedBox.shrink();
                final idx = DailyPick.dayIndex(list.length);
                final q = list[idx];
                return lookup.when(
                  loading: () => const _Skeletons(height: 180),
                  error: (e, _) => _ErrorBlock(message: '$e'),
                  data: (maps) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Quote of the day', style: AppText.display(size: 22)),
                          TextButton(
                            onPressed: () => context.push('/quotes'),
                            child: const Text('All quotes'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      QuoteCard(
                        quote: q,
                        author: q.authorId == null ? null : maps.authors[q.authorId!],
                        theme:  q.themeId  == null ? null : maps.categories[q.themeId!],
                        size: QuoteCardSize.lg,
                        locked: q.isPro && (user?.isPro ?? false) == false,
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
                  onPressed: () => context.push('/library'),
                  child: const Text('All lessons'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Fifteen lessons across eight themes.', style: AppText.body(size: 13, color: AppColors.inkMute)),
            const SizedBox(height: 12),
            lessons.when(
              loading: () => const _Skeletons(height: 180),
              error: (e, _) => _ErrorBlock(message: '$e'),
              data: (list) {
                return lookup.when(
                  loading: () => const _Skeletons(height: 180),
                  error: (e, _) => _ErrorBlock(message: '$e'),
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
                          theme:  l.themeId  == null ? null : maps.categories[l.themeId!],
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

class _Skeletons extends StatelessWidget {
  const _Skeletons({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.paperWarm,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paperCard,
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('Couldn\'t load: $message', style: AppText.body(size: 12, color: AppColors.inkMute)),
    );
  }
}
