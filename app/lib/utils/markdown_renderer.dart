import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Renders lesson markdown with the warm-paper / serif aesthetic.
class LessonMarkdown extends StatelessWidget {
  const LessonMarkdown({super.key, required this.data});
  final String data;

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: AppText.body(size: 16, height: 1.7, color: AppColors.inkSoft),
        h1: AppText.display(size: 30, weight: FontWeight.w500),
        h2: AppText.display(size: 24, weight: FontWeight.w500).copyWith(
          color: AppColors.ink, height: 1.2,
        ),
        h3: AppText.display(size: 20, weight: FontWeight.w500).copyWith(
          color: AppColors.ink, height: 1.2,
        ),
        blockquote: AppText.display(size: 18, color: AppColors.ink).copyWith(
          fontStyle: FontStyle.italic,
        ),
        blockquotePadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        blockquoteDecoration: BoxDecoration(
          color: AppColors.paperWarm.withValues(alpha: 0.6),
          border: const Border(
            left: BorderSide(color: AppColors.accent, width: 4),
          ),
        ),
        listBullet: AppText.body(size: 16, color: AppColors.inkSoft),
        listIndent: 24,
        code: AppText.body(size: 14, color: AppColors.inkSoft).copyWith(
          fontFamily: 'monospace',
          backgroundColor: AppColors.paperWarm,
        ),
        codeblockDecoration: BoxDecoration(
          color: AppColors.paperWarm,
          borderRadius: BorderRadius.circular(8),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        a: AppText.body(size: 16, color: AppColors.accent).copyWith(
          decoration: TextDecoration.underline,
        ),
        strong: AppText.body(size: 16, weight: FontWeight.w600, color: AppColors.ink),
        em: AppText.body(size: 16, color: AppColors.ink).copyWith(
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
