import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../providers/auth_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/empty_state.dart';
import '../widgets/haptic.dart';
import '../widgets/pro_badge.dart';
import '../widgets/stat_card.dart';
import '../widgets/streak_flame.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStateProvider).valueOrNull;
    final ach = ref.watch(achievementsProvider);
    final isAuthed = user != null && !user.isAnonymous;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
        children: [
          Row(
            mainAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PROFILE',
                        style: AppText.label(size: 10, color: AppColors.inkMute)),
                    const SizedBox(height: 4),
                    Text(_greeting(user),
                        style: AppText.display(size: 32),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (isAuthed && user.streakCurrent > 0)
                StreakFlame(days: user.streakCurrent),
            ],
          ),
          const SizedBox(height: 16),
          if (!isAuthed) _anonBanner(context) else _authBanner(context, ref, user),

          const SizedBox(height: 24),

          // Stats — use real data, hide zeros with friendly labels
          Row(
            children: [
              Expanded(child: StatCard(
                label: 'Level',
                value: '${user?.level ?? 1}',
                icon: '🌿',
                hint: '${user?.xp ?? 0} XP',
              )),
              const SizedBox(width: 12),
              Expanded(child: StatCard(
                label: 'Lessons',
                value: '${user?.totalLessons ?? 0}',
                icon: '📖',
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: StatCard(
                label: 'Quotes read',
                value: '${user?.quotesRead ?? 0}',
                icon: '📜',
              )),
              const SizedBox(width: 12),
              Expanded(child: StatCard(
                label: 'Longest streak',
                value: _streakLabel(user?.streakLongest ?? 0),
                icon: '🏔️',
              )),
            ],
          ),

          const SizedBox(height: 28),
          Text('Achievements', style: AppText.display(size: 22)),
          const SizedBox(height: 4),
          Text(
            isAuthed
                ? 'Unlocked as you practice.'
                : 'Sign in to start collecting.',
            style: AppText.body(size: 13, color: AppColors.inkMute),
          ),
          const SizedBox(height: 12),
          ach.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, _) => ErrorView(
              message: 'Couldn\'t load achievements.',
              onRetry: () => ref.invalidate(achievementsProvider),
            ),
            data: (achievements) {
              if (achievements.isEmpty) {
                return const EmptyState(
                  icon: '🌱',
                  title: 'No achievements yet',
                  body: 'Finish a lesson to start collecting.',
                );
              }
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
                physics: const NeverScrollableScrollPhysics(),
                children: achievements.map((a) {
                  final unlocked = !a.isPro || (user?.isPro ?? false);
                  return AchievementBadge(achievement: a, unlocked: unlocked);
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: () {
              Haptic.light();
              context.push('/settings');
            },
            icon: const Icon(Icons.settings_outlined, size: 18),
            label: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  String _greeting(user) {
    if (user == null || user.isAnonymous) return 'You';
    final name = user.displayName;
    if (name == null || name.isEmpty) return 'Welcome back.';
    return 'Hi, $name.';
  }

  String _streakLabel(int days) {
    if (days == 0) return '—';
    if (days == 1) return '1 day';
    return '$days days';
  }

  Widget _anonBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.paperWarm,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sign in to keep your streak', style: AppText.display(size: 20)),
          const SizedBox(height: 6),
          Text(
            'Your practice, your XP, your favorites — all sync across devices.',
            style: AppText.body(size: 13, color: AppColors.inkMute, height: 1.5),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => context.push('/signin'),
            child: const Text('Sign in'),
          ),
        ],
      ),
    );
  }

  Widget _authBanner(BuildContext context, WidgetRef ref, user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: user.isPro
            ? AppColors.proGoldSoft.withValues(alpha: 0.4)
            : AppColors.paperWarm,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: user.isPro ? AppColors.proGold : AppColors.ink.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                user.isPro ? 'RiseUP Pro' : 'RiseUP Free',
                style: AppText.display(
                  size: 22,
                  color: user.isPro ? AppColors.proGold : AppColors.ink,
                ),
              ),
              const Spacer(),
              if (user.isPro) const ProBadge(),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            user.isPro
                ? 'You have access to everything. Practice on.'
                : 'Unlock the full library, daily reminders, favorites sync, and offline reading.',
            style: AppText.body(size: 13, color: AppColors.inkMute, height: 1.5),
          ),
          const SizedBox(height: 12),
          if (!user.isPro)
            ElevatedButton(
              onPressed: () => context.push('/paywall'),
              child: const Text('See plans'),
            )
          else
            OutlinedButton(
              onPressed: () => _manageSub(context, ref, user),
              child: const Text('Manage subscription'),
            ),
        ],
      ),
    );
  }

  Future<void> _manageSub(BuildContext context, WidgetRef ref, user) async {
    Haptic.light();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Pro?'),
        content: const Text(
          'Your Pro access stays active until the end of the current period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Pro'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(appwriteProvider).cancelSubscription(user.userId);
      await ref.read(userStateProvider.notifier).refresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pro cancelled. Access stays until period end.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Couldn\'t cancel: $e')),
        );
      }
    }
  }
}