import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/lesson.dart';
import '../providers/app_providers.dart';
import '../providers/auth_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/markdown_renderer.dart';
import '../widgets/pro_badge.dart';
import '../widgets/quote_card.dart';
import '../widgets/theme_pill.dart';

class LessonDetailScreen extends ConsumerStatefulWidget {
  const LessonDetailScreen({super.key, required this.slug});
  final String slug;

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  bool _marking = false;
  bool _completed = false;

  Future<void> _markComplete() async {
    final user = ref.read(userStateProvider).valueOrNull;
    if (user == null || user.userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to mark lessons complete and earn XP.')),
      );
      return;
    }
    setState(() => _marking = true);
    try {
      await ref.read(appwriteProvider).markLessonComplete(user.userId, widget.slug, xpEarned: 10);
      await ref.read(userStateProvider.notifier).refresh();
      if (mounted) {
        setState(() => _completed = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lesson complete · +10 XP')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Couldn\'t save: $e')));
      }
    } finally {
      if (mounted) setState(() => _marking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonAsync = ref.watch(lessonBySlugProvider(widget.slug));
    final lookup = ref.watch(lookupMapsProvider);
    final quotes = ref.watch(allQuotesProvider);
    final allLessons = ref.watch(allLessonsProvider);
    final user = ref.watch(userStateProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(''),
      ),
      body: lessonAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (lesson) {
          if (lesson == null) {
            return const Center(child: Text('Lesson not found.'));
          }
          final author = lesson.authorId == null ? null : lookup.valueOrNull?.authors[lesson.authorId!];
          final theme  = lesson.themeId  == null ? null : lookup.valueOrNull?.categories[lesson.themeId!];
          final isLocked = lesson.isPro && (user?.isPro ?? false) == false;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
            children: [
              Wrap(spacing: 6, runSpacing: 6, children: [
                if (theme != null) ThemePill(category: theme),
                if (lesson.difficulty != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.ink.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(lesson.difficulty!.label, style: AppText.label(size: 10, color: AppColors.inkMute)),
                  ),
                if (lesson.isPro) const ProBadge(),
                Text('· ${lesson.readTimeMin ?? 4} min', style: AppText.body(size: 12, color: AppColors.inkMute)),
              ]),
              const SizedBox(height: 16),
              Text(lesson.title, style: AppText.display(size: 36, height: 1.05)),
              if (lesson.intro != null) ...[
                const SizedBox(height: 10),
                Text(lesson.intro!, style: AppText.body(size: 17, color: AppColors.inkSoft, height: 1.5)),
              ],
              if (author != null) ...[
                const SizedBox(height: 8),
                Text('· ${author.name}', style: AppText.body(size: 13, color: AppColors.inkMute)),
              ],
              const SizedBox(height: 24),

              if (isLocked)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.proGoldSoft.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.proGold),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.lock_outline, color: AppColors.ink, size: 28),
                      const SizedBox(height: 8),
                      Text('This is a Pro lesson', style: AppText.display(size: 20)),
                      const SizedBox(height: 4),
                      Text('Upgrade to read the full text and earn XP.', style: AppText.body(size: 13, color: AppColors.inkMute), textAlign: TextAlign.center),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: () => context.push('/paywall'),
                        child: const Text('See plans'),
                      ),
                    ],
                  ),
                )
              else ...[
                LessonMarkdown(data: lesson.content),
                if (lesson.keyTakeaway != null || lesson.actionStep != null) ...[
                  const SizedBox(height: 24),
                  if (lesson.keyTakeaway != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.paperWarm.withValues(alpha: 0.6),
                        border: const Border(left: BorderSide(color: AppColors.accent, width: 4)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('KEY TAKEAWAY', style: AppText.label(size: 10, color: AppColors.accent)),
                          const SizedBox(height: 6),
                          Text(lesson.keyTakeaway!, style: AppText.display(size: 18, height: 1.3)),
                        ],
                      ),
                    ),
                  if (lesson.actionStep != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.paperCard,
                        border: Border.all(color: AppColors.ink.withValues(alpha: 0.05)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ACTION STEP', style: AppText.label(size: 10, color: AppColors.inkMute)),
                          const SizedBox(height: 6),
                          Text(lesson.actionStep!, style: AppText.body(size: 14, color: AppColors.inkSoft, height: 1.5)),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _marking ? null : _markComplete,
                    icon: Icon(_completed ? Icons.check : Icons.check_circle_outline,
                        color: AppColors.paper),
                    label: Text(_completed ? 'Completed' : (_marking ? 'Saving…' : 'Mark complete · +10 XP')),
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Related quotes
              if (!isLocked) quotes.maybeWhen(
                data: (qs) {
                  final related = qs.where((q) {
                    final sameAuthor = author != null && q.authorId == author.id;
                    final sameTheme  = theme  != null && q.themeId  == theme.id;
                    return sameAuthor || sameTheme;
                  }).take(3).toList();
                  if (related.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Carry these with you', style: AppText.display(size: 22)),
                      const SizedBox(height: 12),
                      ...related.map((q) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: QuoteCard(
                              quote: q,
                              author: q.authorId == null ? null : lookup.valueOrNull?.authors[q.authorId!],
                              theme:  q.themeId  == null ? null : lookup.valueOrNull?.categories[q.themeId!],
                              size: QuoteCardSize.sm,
                              locked: q.isPro && (user?.isPro ?? false) == false,
                            ),
                          )),
                    ],
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),

              // More from same theme
              if (theme != null) allLessons.maybeWhen(
                data: (ls) {
                  final more = ls.where((l) => l.id != lesson.id && l.themeId == theme.id).take(3).toList();
                  if (more.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text('More on ${theme.name}', style: AppText.display(size: 22)),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.push('/library?theme=${theme.slug}'),
                            child: const Text('All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...more.map((l) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: lookup.when(
                              loading: () => const SizedBox(height: 100),
                              error: (e, _) => Text('$e'),
                              data: (_) => InkWell(
                                onTap: () => context.push('/library/${l.slug}'),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.paperCard,
                                    border: Border.all(color: AppColors.ink.withValues(alpha: 0.05)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(l.title, style: AppText.display(size: 15, height: 1.2)),
                                            const SizedBox(height: 2),
                                            Text('${(l.readTimeMin ?? 4)} min', style: AppText.body(size: 11, color: AppColors.inkMute)),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right, color: AppColors.inkMute),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )),
                    ],
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }
}
