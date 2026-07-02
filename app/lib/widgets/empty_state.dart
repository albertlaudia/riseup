/// Reusable empty / error / loading state widgets.
///
/// Three flavors:
///   - [EmptyState] — when there's nothing to show (empty list, no results)
///   - [ErrorView]  — when a load failed
///   - [Skeleton]   — shimmering placeholder while loading
///
/// All three use the Walrus paper palette and respect the app's typography.
/// Pass the [icon] as a Unicode emoji or a Material icon code point.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'haptic.dart';

class EmptyState extends StatelessWidget {
  final String icon;
  final String title;
  final String body;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.ctaLabel,
    this.onCta,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 56, height: 1.2)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.display(size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppText.body(size: 14, color: AppColors.inkSoft, height: 1.5),
            ),
            if (ctaLabel != null) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  Haptic.light();
                  onCta?.call();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.paper,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                ),
                child: Text(ctaLabel!, style: AppText.body(size: 14)),
              ),
            ],
            if (secondaryLabel != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Haptic.light();
                  onSecondary?.call();
                },
                child: Text(secondaryLabel!,
                    style: AppText.body(size: 13, color: AppColors.inkMute)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String icon;

  const ErrorView({
    super.key,
    this.message = 'Something went sideways.',
    this.onRetry,
    this.icon = '🌧️',
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: icon,
      title: 'We hit a snag',
      body: message,
      ctaLabel: onRetry != null ? 'Try again' : null,
      onCta: onRetry,
    );
  }
}

/// Skeleton placeholder for cards — shimmers gently.
/// Use as a 1:1 stand-in for the real widget shape.
class Skeleton extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  const Skeleton({super.key, this.width, this.height = 16, this.borderRadius});

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(6),
            gradient: LinearGradient(
              begin: Alignment(-1 + t * 2, 0),
              end: Alignment(1 + t * 2, 0),
              colors: const [
                AppColors.walrus,
                AppColors.paper,
                AppColors.walrus,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A skeleton for a list of cards — drop-in while loading.
class SkeletonCardList extends StatelessWidget {
  final int count;
  final double height;
  const SkeletonCardList({super.key, this.count = 3, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: count,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => Container(
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.walrus),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Skeleton(width: 200, height: 18),
            Skeleton(width: double.infinity, height: 12),
            Skeleton(width: 120, height: 12),
          ],
        ),
      ),
    );
  }
}

/// Inline pull-to-refresh wrapper that adds haptics + a friendly message.
class PullToRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String? hint;
  const PullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.paper,
      onRefresh: () async {
        Haptic.medium();
        await onRefresh();
        if (hint != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(hint!),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: child,
    );
  }
}

/// Small stat-card skeleton for the profile screen.
class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.walrus),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Skeleton(width: 60, height: 10),
            SizedBox(height: 8),
            Skeleton(width: 80, height: 22),
            SizedBox(height: 4),
            Skeleton(width: 40, height: 10),
          ],
        ),
      );
}