import 'package:flutter/material.dart';
import '../models/plan.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A card on the paywall screen showing one plan.
class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.plan,
    this.selected = false,
    this.onTap,
  });

  final Plan plan;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: plan.highlight
              ? AppColors.proGoldSoft.withValues(alpha: 0.35)
              : AppColors.paperCard,
          border: Border.all(
            color: selected
                ? AppColors.accent
                : (plan.highlight
                    ? AppColors.proGold
                    : AppColors.ink.withValues(alpha: 0.05)),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(plan.name, style: AppText.display(size: 20)),
                if (plan.highlight)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.proGold,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('Best value', style: AppText.label(size: 9, color: AppColors.paper)),
                  ),
              ],
            ),
            if (plan.tagline != null) ...[
              const SizedBox(height: 4),
              Text(plan.tagline!, style: AppText.body(size: 13, color: AppColors.inkMute)),
            ],
            const SizedBox(height: 16),
            Text(
              plan.priceWithInterval,
              style: AppText.display(size: 26, weight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            ...plan.features.take(4).map((f) => _featureLine(f)),
          ],
        ),
      ),
    );
  }

  Widget _featureLine(String code) {
    final label = _humanize(code);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check, size: 14, color: AppColors.accent),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: AppText.body(size: 13, color: AppColors.inkSoft))),
        ],
      ),
    );
  }

  String _humanize(String code) {
    switch (code) {
      case 'unlimited_lessons':   return 'Unlimited lessons';
      case 'unlimited_quotes':    return 'Unlimited quotes';
      case 'favorites_sync':      return 'Favorites sync across devices';
      case 'offline_reading':     return 'Offline reading';
      case 'daily_reminders':     return 'Daily reminders';
      case 'premium_themes':      return 'Premium themes & quotes';
      case 'premium_quotes':      return 'Premium quote reflections';
      case 'premium_lessons':     return 'Premium deep lessons';
      case 'priority_support':    return 'Priority support';
      case 'lifetime_updates':    return 'Lifetime updates';
      case 'read_daily_lesson':   return 'Daily lesson';
      case 'quote_of_the_day':    return 'Quote of the day';
      case 'streak_tracking':     return 'Streak tracking';
      case 'basic_themes':        return 'Core themes';
      default:                    return code.replaceAll('_', ' ');
    }
  }
}
