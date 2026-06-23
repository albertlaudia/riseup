import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.hint,
  });

  final String label;
  final String value;
  final String? icon;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Text(icon!, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
              ],
              Text(label.toUpperCase(), style: AppText.label(size: 10, color: AppColors.inkMute)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: AppText.display(size: 26, height: 1)),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(hint!, style: AppText.body(size: 11, color: AppColors.inkMute)),
          ],
        ],
      ),
    );
  }
}
