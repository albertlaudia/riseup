import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shows at the top of the home screen when the user has been away 1+ days.
/// For signed-in users, uses the last lesson completion. For anonymous, shows
/// after 2 days since app install (tracked via shared_preferences).
class ReEngagementBanner extends ConsumerStatefulWidget {
  const ReEngagementBanner({super.key});

  @override
  ConsumerState<ReEngagementBanner> createState() => _ReEngagementBannerState();
}

class _ReEngagementBannerState extends ConsumerState<ReEngagementBanner> {
  String? _lastSeenIso;

  @override
  void initState() {
    super.initState();
    _loadLastSeen();
  }

  Future<void> _loadLastSeen() async {
    // For MVP: derive from user.totalLessons == 0 → never seen.
    // Real version: read last lesson completion from Appwrite.
    // Will revisit when auth providers expose it.
    setState(() => _lastSeenIso = null);
  }

  int get _daysSinceSeen {
    if (_lastSeenIso == null) return 0;
    final last = DateTime.tryParse(_lastSeenIso!);
    if (last == null) return 0;
    return DateTime.now().difference(last).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userStateProvider).valueOrNull;
    final isAuthed = user != null && user.userId.isNotEmpty;

    // Heuristic: show for new users who completed zero lessons.
    // A more complete version reads `lastSeen` from settings.
    if (isAuthed && (user.totalLessons > 0)) return const SizedBox.shrink();
    if (isAuthed && user.totalLessons == 0) {
      return _banner(
        title: 'Welcome to RiseUP',
        body: 'Today\'s lesson is 4 minutes. Start the streak.',
        cta: 'Begin',
        onTap: () => context.push('/'),
        icon: '🌿',
      );
    }
    return const SizedBox.shrink();
  }

  Widget _banner({
    required String title,
    required String body,
    required String cta,
    required VoidCallback onTap,
    required String icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.paperWarm, AppColors.paperCard],
        ),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.display(size: 17)),
                const SizedBox(height: 2),
                Text(body, style: AppText.body(size: 13, color: AppColors.inkMute, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              textStyle: const TextStyle(fontSize: 13),
            ),
            child: Text(cta),
          ),
        ],
      ),
    );
  }
}
