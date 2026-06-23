import 'package:flutter/material.dart';
import '../models/content.dart';
import '../models/quote.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'pro_badge.dart';
import 'theme_pill.dart';

class QuoteCard extends StatelessWidget {
  const QuoteCard({
    super.key,
    required this.quote,
    this.author,
    this.theme,
    this.size = QuoteCardSize.md,
    this.locked = false,
    this.onTap,
  });

  final Quote quote;
  final Author? author;
  final Category? theme;
  final QuoteCardSize size;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLg = size == QuoteCardSize.lg;
    final isSm = size == QuoteCardSize.sm;
    final padding = isLg ? 24.0 : (isSm ? 16.0 : 20.0);
    final quoteSize = isLg ? 22.0 : (isSm ? 15.0 : 18.0);
    final quoteHeight = isLg ? 1.3 : 1.4;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: AppColors.paperCard,
              border: Border.all(color: AppColors.ink.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (quote.isPro) ...[
                  Row(
                    children: [
                      const ProBadge(compact: true),
                      if (author != null) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '· ${author!.name}',
                            style: AppText.body(size: 11, color: AppColors.inkMute),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                Text(
                  '“',
                  style: AppText.display(size: 40, color: AppColors.accent.withValues(alpha: 0.35)),
                ),
                const SizedBox(height: 4),
                Text(
                  quote.text,
                  style: AppText.display(size: quoteSize, height: quoteHeight, color: AppColors.ink),
                ),
                if (quote.reflection != null && !isSm) ...[
                  const SizedBox(height: 12),
                  Text(
                    quote.reflection!,
                    style: AppText.body(size: 13, height: 1.5, color: AppColors.inkMute),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (theme != null) ThemePill(category: theme!, size: ThemePillSize.sm),
                  ],
                ),
              ],
            ),
          ),
          if (locked) LockedOverlay(),
        ],
      ),
    );
  }
}

enum QuoteCardSize { sm, md, lg }
