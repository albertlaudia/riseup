import 'package:flutter/material.dart';
import '../models/content.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ThemePill extends StatelessWidget {
  const ThemePill({super.key, required this.category, this.size = ThemePillSize.md});
  final Category category;
  final ThemePillSize size;

  @override
  Widget build(BuildContext context) {
    final color = _parseHex(category.color) ?? AppColors.inkSoft;
    final padH = size == ThemePillSize.sm ? 10.0 : 12.0;
    final padV = size == ThemePillSize.sm ? 2.0  : 4.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: AppColors.paperWarm,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.icon ?? '✦', style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            category.name,
            style: AppText.label(size: 11, color: color).copyWith(letterSpacing: 0.3),
          ),
        ],
      ),
    );
  }

  Color? _parseHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final clean = hex.replaceFirst('#', '');
    if (clean.length != 6) return null;
    return Color(int.parse('FF$clean', radix: 16));
  }
}

enum ThemePillSize { sm, md }
