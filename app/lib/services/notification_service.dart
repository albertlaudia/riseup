import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../config/app_constants.dart';

/// Channel id for the daily reminder notification.
const _channelId = 'riseup_daily_reminder';
const _channelName = 'Daily reminder';
const _channelDescription =
    'A short morning nudge to start the practice. Tap to open today\'s lesson.';

/// Notification payload key — the slug of the lesson to deep-link to.
const _payloadKey = 'lessonSlug';

/// Singleton notification id we use for the daily reminder.
/// flutter_local_notifications replaces any existing notification with the
/// same id, so we always use this one.
const _dailyReminderId = 1001;

/// Wrapper around `flutter_local_notifications` for the daily reminder.
/// Local-first: schedules the reminder on the user's device. No server needed.
/// FCM plugs in later as a wake-up mechanism when the app hasn't been opened.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Last tapped payload (lesson slug). Consumed by the router.
  String? pendingLessonSlug;

  /// Initialize the plugin. Call once at app start.
  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,    // we request on demand
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onTap,
    );

    // Android: create the channel once. iOS uses the system defaults.
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.defaultImportance,
        ),
      );
    }

    // If the app was launched by tapping a notification (cold start)
    if (_plugin.getNotificationAppLaunchDetails != null) {
      final details = await _plugin.getNotificationAppLaunchDetails!();
      if (details?.didNotificationLaunchApp ?? false) {
        final payload = details?.notificationResponse?.payload;
        if (payload != null && payload.isNotEmpty) {
          pendingLessonSlug = payload;
        }
      }
    }

    _initialized = true;
  }

  /// Request OS-level permission (iOS first-run prompt; Android 13+ runtime).
  /// Returns true if granted (or not yet asked); false if explicitly denied.
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final ok = await ios?.requestPermissions(alert: true, badge: true, sound: true);
      return ok ?? false;
    }
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.areNotificationsEnabled() ?? true;
      return granted;
    }
    return true;
  }

  /// Schedule a daily reminder at the given local time (`HH:MM`).
  /// Title and body are baked into the FIRST notification; subsequent days
  /// get re-baked by [rebuildForToday] when the user opens the app.
  ///
  /// Returns true if scheduled. False if permission is denied.
  Future<bool> scheduleDailyReminder({
    required String time,           // "HH:MM" 24h
    required String title,
    required String body,
    required String lessonSlug,
  }) async {
    if (!_initialized) await init();
    final granted = await requestPermission();
    if (!granted) return false;

    final parts = time.split(':');
    if (parts.length != 2) return false;
    final hour = int.tryParse(parts[0]) ?? 7;
    final minute = int.tryParse(parts[1]) ?? 0;

    final scheduled = _nextInstanceOf(hour, minute);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      category: AndroidNotificationCategory.reminder,
      ticker: 'RiseUP — today\'s practice',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _plugin.zonedSchedule(
        _dailyReminderId,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,   // daily, same HH:MM
        payload: lessonSlug,
      );
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('scheduleDailyReminder failed: $e');
      return false;
    }
  }

  /// Cancel the daily reminder. Safe to call if none scheduled.
  Future<void> cancelDailyReminder() async {
    if (!_initialized) await init();
    await _plugin.cancel(_dailyReminderId);
  }

  /// One-off test reminder, ~5 seconds from now. Used by System Info screen
  /// to verify the notification channel is working.
  Future<bool> scheduleTestReminder({
    required String title,
    required String body,
    String? lessonSlug,
  }) async {
    if (!_initialized) await init();
    const androidDetails = AndroidNotificationDetails(
      AppConstants.notifChannelId,
      AppConstants.notifChannelName,
      channelDescription: AppConstants.notifChannelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    final scheduled = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
    try {
      await _plugin.zonedSchedule(
        9999, // different id from daily; both can coexist
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: lessonSlug,
      );
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('scheduleTestReminder failed: $e');
      return false;
    }
  }

  /// Build a fresh "today" notification on top of the scheduled one.
  /// Called when the user opens the app (e.g. the morning after).
  /// This lets us update the title + body without waiting for the next
  /// scheduled fire — useful for showing today's lesson, not yesterday's.
  Future<void> rebuildForToday({
    required String title,
    required String body,
    required String lessonSlug,
  }) async {
    if (!_initialized) await init();
    await cancelDailyReminder();
    // Read existing time from settings — for now this is hardwired; in v2
    // we read `user_settings.dailyReminderTime` and re-schedule.
    await scheduleDailyReminder(
      time: '07:00',
      title: title,
      body: body,
      lessonSlug: lessonSlug,
    );
  }

  /// Today's lesson in the user's local timezone.
  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final tzNow = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, tzNow.year, tzNow.month, tzNow.day, hour, minute);
    if (scheduled.isBefore(tzNow)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  void _onTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    pendingLessonSlug = payload;
    // The router listens via a stream — see NotificationRouterDelegate.
  }

  /// Stream of taps. The router subscribes to handle deep linking from
  /// either a cold-start tap or a warm tap.
  final _tapController = StreamController<String>.broadcast();
  Stream<String> get onTapPayload => _tapController.stream;

  /// Call this from your app's foreground message handler to react to taps
  /// while the app is open.
  void emitTap(String lessonSlug) {
    pendingLessonSlug = lessonSlug;
    _tapController.add(lessonSlug);
  }
}
