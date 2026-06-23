import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/quote_card.dart';

class QuotesScreen extends ConsumerWidget {
  const QuotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotes  = ref.watch(allQuotesProvider);
    final lookup  = ref.watch(lookupMapsProvider);
    final cats    = ref.watch(categoriesProvider);
    final user    = ref.watch(userStateProvider).valueOrNull;

    return Scaffold(
      body: quotes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (all) {
          final featured = all.where((q) => q.isFeatured).toList();
          final cats0 = cats.valueOrNull ?? const [];
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allQuotesProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
              children: [
                Text('Quotes', style: AppText.display(size: 36)),
                const SizedBox(height: 6),
                Text('${all.length} passages from the Stoics and a few modern voices.',
                    style: AppText.body(size: 14, color: AppColors.inkMute)),
                const SizedBox(height: 20),

                if (featured.isNotEmpty) ...[
                  Text('Featured', style: AppText.display(size: 22)),
                  const SizedBox(height: 12),
                  ...featured.map((q) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: lookup.when(
                          loading: () => const SizedBox(height: 100),
                          error: (e, _) => Text('$e'),
                          data: (maps) => QuoteCard(
                            quote: q,
                            author: q.authorId == null ? null : maps.authors[q.authorId!],
                            theme:  q.themeId  == null ? null : maps.categories[q.themeId!],
                            locked: q.isPro && (user?.isPro ?? false) == false,
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),
                ],

                for (final c in cats0)
                  Builder(builder: (_) {
                    final inCat = all.where((q) => q.themeId == c.id).toList();
                    if (inCat.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 36, height: 36, alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.forTheme(c.slug).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(c.icon ?? '✦'),
                              ),
                              const SizedBox(width: 10),
                              Text(c.name, style: AppText.display(size: 22)),
                              const SizedBox(width: 8),
                              Text('· ${inCat.length}', style: AppText.body(size: 13, color: AppColors.inkMute)),
                            ],
                          ),
                        ),
                        ...inCat.map((q) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: lookup.when(
                                loading: () => const SizedBox(height: 100),
                                error: (e, _) => Text('$e'),
                                data: (maps) => QuoteCard(
                                  quote: q,
                                  author: q.authorId == null ? null : maps.authors[q.authorId!],
                                  theme:  q.themeId  == null ? null : maps.categories[q.themeId!],
                                  size: QuoteCardSize.sm,
                                  locked: q.isPro && (user?.isPro ?? false) == false,
                                ),
                              ),
                            )),
                      ],
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
