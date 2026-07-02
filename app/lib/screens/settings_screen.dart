import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_constants.dart';
import '../providers/app_providers.dart';
import '../providers/auth_providers.dart';
import '../services/reminder_scheduler.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/haptic.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _theme = 'auto';
  bool _notifications = true;
  String _reminderTime = AppConstants.defaultReminderTime;
  String _fontSize = 'medium';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Local prefs first
    final prefs = await SharedPreferences.getInstance();
    final localNotif = prefs.getBool('reminder.notifications') ?? true;
    final localTime = prefs.getString('reminder.time') ?? AppConstants.defaultReminderTime;
    if (mounted) {
      setState(() {
        _notifications = localNotif;
        _reminderTime = localTime;
        _loaded = true;
      });
    }
    // Then sync from server if signed in
    final user = ref.read(userStateProvider).valueOrNull;
    if (user != null && !user.isAnonymous) {
      try {
        final s = await ref.read(appwriteProvider).getSettings(user.userId);
        if (!mounted) return;
        setState(() {
          _theme = s['theme'] as String? ?? _theme;
          _notifications = s['notifications'] as bool? ?? _notifications;
          _reminderTime = s['dailyReminderTime'] as String? ?? _reminderTime;
          _fontSize = s['fontSize'] as String? ?? _fontSize;
        });
      } catch (_) {/* offline-first is fine */}
    }
  }

  Future<void> _save({String? theme, String? fontSize}) async {
    final user = ref.read(userStateProvider).valueOrNull;
    final patch = <String, dynamic>{
      'theme': theme ?? _theme,
      'notifications': _notifications,
      'dailyReminderTime': _reminderTime,
      'fontSize': fontSize ?? _fontSize,
    };
    if (user != null && !user.isAnonymous) {
      try {
        await ref.read(appwriteProvider).saveSettings(user.userId, patch);
      } catch (_) {/* offline; will retry */}
    }
    // Always mirror to local prefs (anonymous + offline)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder.notifications', _notifications);
    await prefs.setString('reminder.time', _reminderTime);
    await prefs.setString('app.theme', _theme);
    await prefs.setString('app.fontSize', _fontSize);
    await ref.read(reminderSchedulerProvider.notifier).reschedule();
  }

  Future<void> _onNotifChanged(bool v) async {
    Haptic.light();
    setState(() => _notifications = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder.notifications', v);
    await ref.read(reminderSchedulerProvider.notifier).reschedule();
    final user = ref.read(userStateProvider).valueOrNull;
    if (user != null && !user.isAnonymous) {
      try {
        await ref.read(appwriteProvider).saveSettings(user.userId, {
          'notifications': v,
          'dailyReminderTime': _reminderTime,
        });
      } catch (_) {/* fire-and-forget */}
    }
  }

  Future<void> _onTimeChanged(String v) async {
    Haptic.selection();
    setState(() => _reminderTime = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reminder.time', v);
    await ref.read(reminderSchedulerProvider.notifier).reschedule();
    final user = ref.read(userStateProvider).valueOrNull;
    if (user != null && !user.isAnonymous) {
      try {
        await ref.read(appwriteProvider).saveSettings(user.userId, {
          'notifications': _notifications,
          'dailyReminderTime': v,
        });
      } catch (_) {/* fire-and-forget */}
    }
  }

  Future<void> _onThemeChanged(String v) async {
    Haptic.selection();
    setState(() => _theme = v);
    await _save(theme: v);
  }

  Future<void> _onFontSizeChanged(String v) async {
    Haptic.selection();
    setState(() => _fontSize = v);
    await _save(fontSize: v);
  }

  Future<void> _signOut() async {
    Haptic.medium();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'Your data stays on this device until you sign in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(userStateProvider.notifier).signOut();
    if (context.mounted) context.go('/');
  }

  Future<void> _deleteAccount() async {
    Haptic.heavy();
    final confirm = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This is permanent. We\'ll erase your email, progress, journal, and favorites. You can create a new account any time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'first'),
            child: const Text('I understand'),
          ),
        ],
      ),
    );
    if (confirm != 'first') return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Type DELETE to confirm'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'DELETE'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete forever'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(appwriteProvider).deleteAccount();
      await ref.read(userStateProvider.notifier).signOut();
      if (context.mounted) context.go('/');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Couldn\'t delete: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userStateProvider).valueOrNull;
    final isAuthed = user != null && !user.isAnonymous;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
        children: [
          if (!isAuthed)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.paperWarm,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sign in to sync your settings',
                      style: AppText.body(size: 14, weight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.push('/signin'),
                    child: const Text('Sign in'),
                  ),
                ],
              ),
            ),

          _section('Appearance'),
          _segmented<String>(
            value: _theme,
            options: const [('auto', 'Auto'), ('light', 'Light'), ('dark', 'Dark')],
            onChanged: _onThemeChanged,
          ),
          const SizedBox(height: 12),
          _label('Reading font size'),
          _segmented<String>(
            value: _fontSize,
            options: const [('small', 'Small'), ('medium', 'Medium'), ('large', 'Large')],
            onChanged: _onFontSizeChanged,
          ),
          const SizedBox(height: 24),

          _section('Daily reminder'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _notifications,
            onChanged: _onNotifChanged,
            title: Text('Send me a daily reminder', style: AppText.body(size: 14)),
            subtitle: _notifications
                ? Text(
                    'Schedules a local notification at ${_formatTime(_reminderTime)} every day. Tap to open today\'s lesson.',
                    style: AppText.body(size: 11, color: AppColors.inkMute),
                  )
                : Text(
                    'Quiet for now. We\'ll be here.',
                    style: AppText.body(size: 11, color: AppColors.inkMute),
                  ),
          ),
          if (_notifications) ...[
            const SizedBox(height: 8),
            _label('Time'),
            _segmented<String>(
              value: _reminderTime,
              options: AppConstants.reminderTimeOptions,
              onChanged: _onTimeChanged,
            ),
            const SizedBox(height: 8),
            Text(
              'Scheduled locally on your device. No data leaves the phone unless you sign in.',
              style: AppText.body(size: 11, color: AppColors.inkMute, height: 1.4),
            ),
          ],
          const SizedBox(height: 24),

          if (isAuthed) ...[
            _section('Account'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout, size: 20),
              title: const Text('Sign out'),
              onTap: _signOut,
            ),
            const SizedBox(height: 16),
            _section('Danger zone'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.delete_outline, size: 20, color: Colors.red[700]),
              title: Text('Delete account', style: TextStyle(color: Colors.red[700])),
              subtitle: const Text(
                'Permanently erases your email, progress, journal, and favorites.',
                style: TextStyle(fontSize: 11),
              ),
              onTap: _deleteAccount,
            ),
            const SizedBox(height: 24),
          ],

          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline, size: 20),
            title: const Text('About RiseUP'),
            onTap: () => context.push('/about'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.bug_report_outlined, size: 20),
            title: const Text('System info'),
            subtitle: Text(
              'Version · env · sign-out debug',
              style: AppText.body(size: 11, color: AppColors.inkMute),
            ),
            onTap: () => context.push('/system-info'),
          ),
        ],
      ),
    );
  }

  String _formatTime(String hhmm) {
    if (hhmm.length != 5) return hhmm;
    final h = int.tryParse(hhmm.substring(0, 2)) ?? 0;
    final m = hhmm.substring(3);
    final ampm = h < 12 ? 'am' : 'pm';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:$m $ampm';
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title.toUpperCase(),
            style: AppText.label(size: 11, color: AppColors.inkMute)),
      );

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 6),
        child: Text(s, style: AppText.body(size: 13, color: AppColors.inkSoft)),
      );

  Widget _segmented<T>({
    required T value,
    required List<(T, String)> options,
    required ValueChanged<T> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.paperWarm,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: options.map((o) {
          final selected = o.$1 == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(o.$1),
              child: AnimatedContainer(
                duration: AppConstants.shortAnim,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.ink : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    o.$2,
                    style: AppText.body(
                      size: 13,
                      color: selected ? AppColors.paper : AppColors.inkSoft,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}