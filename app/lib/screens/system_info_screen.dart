import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../providers/app_providers.dart';
import '../providers/auth_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/haptic.dart';

class SystemInfoScreen extends ConsumerStatefulWidget {
  const SystemInfoScreen({super.key});

  @override
  ConsumerState<SystemInfoScreen> createState() => _SystemInfoScreenState();
}

class _SystemInfoScreenState extends ConsumerState<SystemInfoScreen> {
  PackageInfo? _info;
  Map<String, String> _prefs = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _info = info;
        _prefs = {
          for (final k in prefs.getKeys()) k: '${prefs.get(k)}',
        };
      });
    } catch (e) {
      if (mounted) {
        setState(() => _prefs = {'error': e.toString()});
      }
    }
  }

  Future<void> _copyAll() async {
    final user = ref.read(userStateProvider).valueOrNull;
    final buf = StringBuffer();
    buf.writeln('RiseUP system info');
    buf.writeln('==================');
    if (_info != null) {
      buf.writeln('appName: ${_info!.appName}');
      buf.writeln('packageName: ${_info!.packageName}');
      buf.writeln('version: ${_info!.version}');
      buf.writeln('buildNumber: ${_info!.buildNumber}');
    }
    buf.writeln('');
    buf.writeln('Config:');
    buf.writeln('  pbUrl: ${Config.pbUrl}');
    buf.writeln('  awEndpoint: ${Config.awEndpoint}');
    buf.writeln('  awProject: ${Config.awProject}');
    buf.writeln('');
    buf.writeln('User:');
    buf.writeln('  isAuthed: ${user != null && !user.isAnonymous}');
    buf.writeln('  userId: ${user?.userId ?? '—'}');
    buf.writeln('  tier: ${user?.tier.name ?? '—'}');
    buf.writeln('  xp: ${user?.xp ?? 0}');
    buf.writeln('  level: ${user?.level ?? 0}');
    buf.writeln('  streak: ${user?.streakCurrent ?? 0}');
    buf.writeln('');
    buf.writeln('Local prefs:');
    _prefs.forEach((k, v) => buf.writeln('  $k = $v'));

    await Clipboard.setData(ClipboardData(text: buf.toString()));
    Haptic.notify('success');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _resetOnboarding() async {
    Haptic.medium();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('home.highlightedUntil');
    await prefs.setInt('home.highlightedUntil',
        DateTime.now().millisecondsSinceEpoch + 30 * 1000);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Onboarding highlight armed. Open Home to see it.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _testNotification() async {
    Haptic.medium();
    try {
      // Trigger a one-off reminder 5 seconds from now for debugging.
      await ref.read(reminderSchedulerProvider.notifier).reschedule(forceImmediate: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test reminder scheduled. Watch for it in 5s.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Test failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userStateProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('System info'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy all',
            onPressed: _copyAll,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
        children: [
          _section('App'),
          _kv('App name', _info?.appName ?? '…'),
          _kv('Package', _info?.packageName ?? '…'),
          _kv('Version', _info?.version ?? '…'),
          _kv('Build', _info?.buildNumber ?? '…'),

          const SizedBox(height: 16),
          _section('Config'),
          _kv('PocketBase', Config.pbUrl),
          _kv('Appwrite endpoint', Config.awEndpoint),
          _kv('Appwrite project', Config.awProject),

          const SizedBox(height: 16),
          _section('User'),
          _kv('Authed', user != null && !user.isAnonymous ? 'yes' : 'no'),
          _kv('User ID', user?.userId.isNotEmpty == true ? user!.userId : '—'),
          _kv('Email', user?.email ?? '—'),
          _kv('Tier', user?.tier.name ?? '—'),
          _kv('Plan', user?.activePlanCode ?? '—'),
          _kv('XP', '${user?.xp ?? 0}'),
          _kv('Level', '${user?.level ?? 1}'),
          _kv('Streak', '${user?.streakCurrent ?? 0} d'),
          _kv('Longest', '${user?.streakLongest ?? 0} d'),
          _kv('Lessons', '${user?.totalLessons ?? 0}'),
          _kv('Quotes read', '${user?.quotesRead ?? 0}'),

          const SizedBox(height: 16),
          _section('Local prefs (${_prefs.length})'),
          for (final e in _prefs.entries) _kv(e.key, e.value),

          const SizedBox(height: 24),
          _section('Debug tools'),
          OutlinedButton.icon(
            onPressed: _testNotification,
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Schedule test reminder (5s)'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _resetOnboarding,
            icon: const Icon(Icons.replay_outlined),
            label: const Text('Re-arm first-launch highlight'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              Haptic.medium();
              await ref.invalidate(userStateProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User state invalidated.')),
                );
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh user state'),
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              'Build · ${_info?.buildNumber ?? '…'}',
              style: AppText.body(size: 11, color: AppColors.inkMute),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(s.toUpperCase(),
            style: AppText.label(size: 11, color: AppColors.inkMute)),
      );

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(k,
                  style: AppText.body(size: 12, color: AppColors.inkMute)),
            ),
            Expanded(
              child: SelectableText(
                v,
                style: AppText.body(size: 12, color: AppColors.ink),
              ),
            ),
          ],
        ),
      );
}