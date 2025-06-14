import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones(); // Initialize timezone data

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showBudgetAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!await _shouldShowNotification()) return;

    try {
      // Show immediate notification instead of scheduling
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'budget_alerts',
            'Budget Alerts',
            channelDescription: 'Notifications for budget thresholds',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          );

      final DarwinNotificationDetails iOSDetails =
          const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      // Show notification immediately
      await flutterLocalNotificationsPlugin.show(id, title, body, details);

      await _saveLastNotificationTime();
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  Future<bool> _shouldShowNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final lastNotificationTime = DateTime.fromMillisecondsSinceEpoch(
      prefs.getInt('last_notification_time') ?? 0,
    );

    // Check if at least 6 hours have passed since last notification
    return DateTime.now().difference(lastNotificationTime).inHours >= 6;
  }

  Future<void> _saveLastNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'last_notification_time',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Add helper method to request exact alarm permission if needed
  // Future<bool> _requestExactAlarmPermission() async {
  // This would require adding the exact alarm permission to Android Manifest
  // and implementing a method channel to request it
  // For now, we'll just show immediate notifications
  //   return false;
  // }
}
