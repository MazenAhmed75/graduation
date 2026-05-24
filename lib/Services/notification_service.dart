import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  // The plugin that shows notifications on the device screen
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  // -------------------------------------------------------
  // SETUP: Call this once in main.dart before runApp()
  // -------------------------------------------------------
  static Future<void> initialize() async {
    // Android settings: the icon name references your app icon
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(settings);

    // Ask user permission for notifications (iOS / Android 13+)
    await FirebaseMessaging.instance.requestPermission();
  }

  // -------------------------------------------------------
  // NOTIFY: Show a warning when budget is near limit
  // Called automatically from BudgetService.withdraw()
  // -------------------------------------------------------
  static Future<void> showBudgetWarning({
    required String budgetTitle,
    required int percentUsed,
  }) async {
    String title;
    String body;

    if (percentUsed >= 100) {
      title = '🚨 Budget Exceeded: $budgetTitle';
      body = 'You have gone over your $budgetTitle budget!';
    } else {
      title = '⚠️ Budget Alert: $budgetTitle';
      body = 'You\'ve used $percentUsed% of your $budgetTitle budget.';
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'budget_alerts',       // Channel ID
      'Budget Alerts',       // Channel name (shown in Android settings)
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      budgetTitle.hashCode, // Unique ID per budget
      title,
      body,
      details,
    );
  }

  // -------------------------------------------------------
  // NOTIFY: Show a savings milestone notification
  // -------------------------------------------------------
  static Future<void> showSavingsMilestone(int percent) async {
    await _localNotifications.show(
      999,
      '🎉 Savings Goal Progress',
      'You\'re $percent% of the way to your monthly savings goal!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'savings_updates', 'Savings Updates',
          importance: Importance.defaultImportance,
        ),
      ),
    );
  }
}