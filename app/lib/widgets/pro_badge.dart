import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A small "Pro" chip used to mark premium content.
class ProBadge extends StatelessWidget {
  const ProBadge({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 1 : 3,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.proGold, AppColors.gold],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'PRO',
        style: AppText.label(
          size: compact ? 9 : 10,
          color: AppColors.paper,
        ).copyWith(letterSpacing: 0.8),
      ),
    );
  }
}

/// Lock icon overlay for premium content the user doesn't have access to.
class LockedOverlay extends StatelessWidget {
  const LockedOverlay({super.key, this.label = 'Pro'});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.paper.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, color: AppColors.inkMute, size: 22),
              const SizedBox(height: 6),
              ProBadge(),
              const SizedBox(height: 6),
              Text(
                'Unlock with $label',
                style: AppText.body(size: 12, color: AppColors.inkMute),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
