import 'package:flutter/material.dart';
import '../models/content.dart';
import '../models/lesson.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'pro_badge.dart';
import 'theme_pill.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.lesson,
    this.author,
    this.theme,
    this.variant = LessonCardVariant.defaultCard,
    this.locked = false,
    this.onTap,
  });

  final Lesson lesson;
  final Author? author;
  final Category? theme;
  final LessonCardVariant variant;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        switch (variant) {
          LessonCardVariant.hero         => _hero(context),
          LessonCardVariant.compact      => _compact(context),
          LessonCardVariant.defaultCard  => _defaultCard(context),
        },
        if (locked) LockedOverlay(),
      ],
    );
  }

  Widget _hero(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.paperCard, AppColors.paperWarm, AppColors.paper],
          ),
          border: Border.all(color: AppColors.ink.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (theme != null) ThemePill(category: theme!),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('✦ Today', style: AppText.label(size: 10, color: AppColors.accent)),
                ),
                if (lesson.isPro) ...[const SizedBox(width: 8), const ProBadge(compact: true)],
              ],
            ),
            const SizedBox(height: 20),
            Text(lesson.title, style: AppText.display(size: 30, height: 1.05)),
            if (lesson.intro != null) ...[
              const SizedBox(height: 12),
              Text(lesson.intro!, style: AppText.body(size: 15, color: AppColors.inkSoft, height: 1.5)),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                if (author != null)
                  Text('· ${author!.name}', style: AppText.body(size: 12, color: AppColors.inkMute)),
                const SizedBox(width: 12),
                Text('${lesson.readTimeMin ?? 4} min read', style: AppText.body(size: 12, color: AppColors.inkMute)),
                if (lesson.difficulty != null) ...[
                  const SizedBox(width: 8),
                  Text('· ${lesson.difficulty!.label}', style: AppText.body(size: 12, color: AppColors.inkMute)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _compact(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.paperCard,
          border: Border.all(color: AppColors.ink.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (theme != null)
              Container(
                width: 36, height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.forTheme(theme!.slug).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(theme!.icon ?? '✦'),
              ),
            if (theme != null) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: AppText.display(size: 15).copyWith(height: 1.2),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${author?.name ?? '—'} · ${lesson.readTimeMin ?? 4} min',
                    style: AppText.body(size: 11, color: AppColors.inkMute),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (lesson.isPro) ...[
              const SizedBox(width: 8),
              const ProBadge(compact: true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _defaultCard(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
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
                if (theme != null) ThemePill(category: theme!),
                if (lesson.difficulty != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.ink.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      lesson.difficulty!.label,
                      style: AppText.label(size: 9, color: AppColors.inkMute),
                    ),
                  ),
                ],
                if (lesson.isPro) ...[const SizedBox(width: 6), const ProBadge(compact: true)],
              ],
            ),
            const SizedBox(height: 14),
            Text(lesson.title, style: AppText.display(size: 20, height: 1.2)),
            if (lesson.intro != null) ...[
              const SizedBox(height: 6),
              Text(
                lesson.intro!,
                style: AppText.body(size: 13, height: 1.5, color: AppColors.inkSoft),
                maxLines: 2, overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (author != null)
                  Text('· ${author!.name}', style: AppText.body(size: 12, color: AppColors.inkMute)),
                Text('${lesson.readTimeMin ?? 4} min', style: AppText.body(size: 12, color: AppColors.inkMute)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum LessonCardVariant { hero, compact, defaultCard }
