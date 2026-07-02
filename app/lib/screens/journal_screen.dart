import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/empty_state.dart';

/// Read-only view of past reflection entries. Anonymous users see a CTA
/// to sign in.
class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStateProvider).valueOrNull;
    final journal = ref.watch(journalProvider);
    final isAuthed = user != null && !user.isAnonymous;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Journal'),
      ),
      body: !isAuthed
          ? EmptyState(
              icon: '📖',
              title: 'A journal of small reflections',
              body:
                  'Sign in to save reflections from each lesson. They\'ll be here when you want to look back.',
              ctaLabel: 'Sign in',
              onCta: () => context.push('/signin'),
            )
          : journal.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorView(
                message: 'Couldn\'t load your reflections.',
                onRetry: () => ref.read(journalProvider.notifier).load(),
              ),
              data: (entries) {
                if (entries.isEmpty) {
                  return const EmptyState(
                    icon: '✍️',
                    title: 'No reflections yet',
                    body: 'Finish a lesson, and we\'ll ask what stood out. Your answer lives here.',
                    ctaLabel: 'Find today\'s lesson',
                    onCta: () => context.go('/library'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(journalProvider.notifier).load(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final e = entries[i];
                      final createdAt = e['createdAt'] as DateTime?;
                      return _JournalCard(
                        lessonSlug: e['lessonSlug'] as String? ?? '',
                        promptText: e['promptText'] as String? ?? '',
                        responseText: e['responseText'] as String? ?? '',
                        createdAt: createdAt ?? DateTime.now(),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  final String lessonSlug;
  final String promptText;
  final String responseText;
  final DateTime createdAt;

  const _JournalCard({
    required this.lessonSlug,
    required this.promptText,
    required this.responseText,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        if (lessonSlug.isNotEmpty) {
          context.push('/library/$lessonSlug');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.ink.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _formatDate(createdAt),
                  style: AppText.label(size: 10, color: AppColors.inkMute),
                ),
                const Spacer(),
                if (lessonSlug.isNotEmpty)
                  Icon(Icons.chevron_right, size: 16, color: AppColors.inkMute),
              ],
            ),
            const SizedBox(height: 8),
            Text(promptText,
                style: AppText.body(size: 13, color: AppColors.inkSoft, height: 1.5)),
            const SizedBox(height: 10),
            Text(responseText,
                style: AppText.display(size: 16, height: 1.4)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dt = DateTime(d.year, d.month, d.day);
    final diff = today.difference(dt).inDays;
    if (diff == 0) return 'TODAY';
    if (diff == 1) return 'YESTERDAY';
    if (diff < 7) return '$diff DAYS AGO';
    return DateFormat('MMM d').format(d).toUpperCase();
  }
}