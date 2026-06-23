import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    super.key,
    required this.achievement,
    required this.unlocked,
    this.progress,
  });

  final Achievement achievement;
  final bool unlocked;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: unlocked
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0x26C8A14A),
                  AppColors.paperCard,
                  AppColors.paperCard,
                ],
              )
            : null,
        color: unlocked ? null : AppColors.paperCard.withValues(alpha: 0.6),
        border: Border.all(
          color: unlocked
              ? AppColors.gold.withValues(alpha: 0.30)
              : AppColors.ink.withValues(alpha: 0.05),
        ),
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
        children: [
          Container(
            width: 52, height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: unlocked
                  ? AppColors.gold.withValues(alpha: 0.20)
                  : AppColors.ink.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Text(
              achievement.icon ?? '🏅',
              style: TextStyle(
                fontSize: 22,
                color: unlocked ? null : AppColors.inkMute,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: AppText.display(size: 14, height: 1.1).copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            achievement.description ?? '',
            textAlign: TextAlign.center,
            style: AppText.body(size: 11, height: 1.4, color: AppColors.inkMute),
            maxLines: 2, overflow: TextOverflow.ellipsis,
          ),
          if ((achievement.xpReward ?? 0) > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '+${achievement.xpReward} XP',
                style: AppText.label(size: 9, color: AppColors.inkMute),
              ),
            ),
          ],
          if (!unlocked && progress != null && progress! > 0) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress!.clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: AppColors.ink.withValues(alpha: 0.05),
                valueColor: const AlwaysStoppedAnimation(AppColors.accent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
