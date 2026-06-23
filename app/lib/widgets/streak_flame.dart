import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StreakFlame extends StatelessWidget {
  const StreakFlame({super.key, required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.paperCard,
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$days', style: AppText.display(size: 16, height: 1)),
              const SizedBox(height: 2),
              Text('day streak', style: AppText.label(size: 9, color: AppColors.inkMute)),
            ],
          ),
        ],
      ),
    );
  }
}
