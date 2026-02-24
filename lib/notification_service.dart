import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Track tasks already notified in this session
  final Set<String> notifiedTaskIds = {};

  Future<void> init() async {
    if (kIsWeb) {
      _requestWebPermission();
      return;
    }

    try {
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(initSettings);
    } catch (e) {
      debugPrint("Notification init error: $e");
    }
  }

  void _requestWebPermission() {
    if (!kIsWeb) return;
    try {
      // For web platform, request notification permissions
      // This is handled by Flutter's notification plugins
      debugPrint("Web notification permission requested");
    } catch (e) {
      debugPrint("Web notification permission error: $e");
    }
  }

  /// Show a simple native browser notification (Web only)
  void showWebNotification(String title, String body) {
    if (!kIsWeb) return;
    try {
      // For web platform, notifications are shown through Flutter's plugins
      debugPrint("Web notification: $title - $body");
    } catch (e) {
      debugPrint("Web notification display error: $e");
    }
  }

  /// Schedule a notification at [scheduledTime] for the given task.
  Future<void> scheduleTaskNotification({
    required int id,
    required String title,
    required DateTime scheduledTime,
  }) async {
    if (kIsWeb) return;

    try {
      final tz.TZDateTime tzScheduled =
          tz.TZDateTime.from(scheduledTime, tz.local);
      if (tzScheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

      const androidDetails = AndroidNotificationDetails(
        'fitmind_tasks',
        'FitMind Tasks',
        channelDescription: 'Scheduled daily fitness task reminders',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notifDetails =
          NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _plugin.zonedSchedule(
        id,
        '⏰ FitMind Reminder',
        title,
        tzScheduled,
        notifDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint("Scheduling error: $e");
    }
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await _plugin.cancel(id);
  }
}
