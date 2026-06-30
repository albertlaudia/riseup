import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_providers.dart';
import '../providers/auth_providers.dart';
import '../services/notification_service.dart';
import '../services/reminder_scheduler.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _theme = 'auto';
  bool _notifications = true;
  String _reminderTime = '07:00';
  String _fontSize = 'medium';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = ref.read(userStateProvider).valueOrNull;
    if (user == null || user.userId.isEmpty) return;
    final s = await ref.read(appwriteProvider).getSettings(user.userId);
    if (!mounted) return;
    setState(() {
      _theme = s['theme'] as String? ?? 'auto';
      _notifications = s['notifications'] as bool? ?? true;
      _reminderTime = s['dailyReminderTime'] as String? ?? '07:00';
      _fontSize = s['fontSize'] as String? ?? 'medium';
      _loaded = true;
    });
  }

  Future<void> _save() async {
    final user = ref.read(userStateProvider).valueOrNull;
    if (user == null || user.userId.isEmpty) return;
    await ref.read(appwriteProvider).saveSettings(user.userId, {
      'theme': _theme,
      'notifications': _notifications,
      'dailyReminderTime': _reminderTime,
      'fontSize': _fontSize,
    });
    // Mirror to local prefs so the scheduler can read even when offline.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder.notifications', _notifications);
    await prefs.setString('reminder.time', _reminderTime);
    // Re-schedule the daily reminder (or cancel if off).
    await ref.read(reminderSchedulerProvider.notifier).reschedule();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved.')),
      );
    }
  }

  /// Reschedule immediately when the toggle flips — the user shouldn't
  /// have to tap Save for the reminder to engage.
  Future<void> _onNotifChanged(bool v) async {
    setState(() => _notifications = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder.notifications', v);
    await ref.read(reminderSchedulerProvider.notifier).reschedule();
    // Also persist to Appwrite if signed in.
    final user = ref.read(userStateProvider).valueOrNull;
    if (user != null && user.userId.isNotEmpty) {
      try {
        await ref.read(appwriteProvider).saveSettings(user.userId, {
          'notifications': v,
          'dailyReminderTime': _reminderTime,
        });
      } catch (_) {/* fire-and-forget */}
    }
  }

  Future<void> _onTimeChanged(String v) async {
    setState(() => _reminderTime = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reminder.time', v);
    await ref.read(reminderSchedulerProvider.notifier).reschedule();
    final user = ref.read(userStateProvider).valueOrNull;
    if (user != null && user.userId.isNotEmpty) {
      try {
        await ref.read(appwriteProvider).saveSettings(user.userId, {
          'notifications': _notifications,
          'dailyReminderTime': v,
        });
      } catch (_) {/* fire-and-forget */}
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userStateProvider).valueOrNull;
    final isAuthed = user != null && user.userId.isNotEmpty;

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
                  Text('Sign in to sync your settings', style: AppText.body(size: 14, weight: FontWeight.w500)),
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
            options: const [
              ('auto', 'Auto'),
              ('light', 'Light'),
              ('dark', 'Dark'),
            ],
            onChanged: (v) => setState(() => _theme = v),
          ),
          const SizedBox(height: 12),
          _label('Reading font size'),
          _segmented<String>(
            value: _fontSize,
            options: const [
              ('small', 'Small'),
              ('medium', 'Medium'),
              ('large', 'Large'),
            ],
            onChanged: (v) => setState(() => _fontSize = v),
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
                    'Tap the switch to start the daily nudge.',
                    style: AppText.body(size: 11, color: AppColors.inkMute),
                  ),
          ),
          if (_notifications) ...[
            const SizedBox(height: 8),
            _label('Time'),
            _segmented<String>(
              value: _reminderTime,
              options: const [
                ('06:00', '6:00'),
                ('07:00', '7:00'),
                ('08:00', '8:00'),
                ('21:00', '21:00'),
              ],
              onChanged: _onTimeChanged,
            ),
            const SizedBox(height: 8),
            Text(
              'Scheduled locally on your device. No data leaves the phone unless you sign in.',
              style: AppText.body(size: 11, color: AppColors.inkMute, height: 1.4),
            ),
          ],
          const SizedBox(height: 24),

          if (isAuthed) SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: _save, child: const Text('Save')),
          ),
          const SizedBox(height: 16),

          if (isAuthed) TextButton(
            onPressed: () async {
              await ref.read(userStateProvider.notifier).signOut();
              if (context.mounted) context.go('/');
            },
            child: const Text('Sign out'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.push('/about'),
            child: const Text('About RiseUP'),
          ),
        ],
      ),
    );
  }

  String _formatTime(String hhmm) {
    if (hhmm.length != 5) return hhmm;
    final h = hhmm.substring(0, 2);
    final m = hhmm.substring(3);
    final hour = int.tryParse(h) ?? 0;
    final ampm = hour < 12 ? 'am' : 'pm';
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$h12:$m $ampm';
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title.toUpperCase(), style: AppText.label(size: 11, color: AppColors.inkMute)),
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
                duration: const Duration(milliseconds: 120),
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
