import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/app_state.dart';               // 👈 Tracks whether the app is currently open
import '../utils/notification_strings.dart';    // 👈 Provides localized notification text

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
AndroidInitializationSettings('@mipmap/ic_launcher');

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
required int daysLeftInMonth,
}) async {
// Skip entirely if the user is currently using the app
if (AppState.isInForeground) return;

final String title;
final String body;

if (percentUsed >= 100) {
title = await NotificationStrings.budgetExceededTitle(budgetTitle);
body = await NotificationStrings.budgetExceededBody(budgetTitle);
} else {
title = await NotificationStrings.budgetWarningTitle(budgetTitle);
body = await NotificationStrings.budgetWarningBody(
budgetTitle, percentUsed, daysLeftInMonth);
}

await _localNotifications.show(
budgetTitle.hashCode, // Unique ID per budget
title,
body,
const NotificationDetails(
android: AndroidNotificationDetails(
'budget_alerts',       // Channel ID
'Budget Alerts',       // Channel name (shown in Android settings)
importance: Importance.high,
priority: Priority.high,
),
),
);
}

// -------------------------------------------------------
// NOTIFY: Savings milestone
// -------------------------------------------------------
static Future<void> showSavingsMilestone(int percent) async {
// Skip entirely if the user is currently using the app
if (AppState.isInForeground) return;

await _localNotifications.show(
999,
await NotificationStrings.savingsTitle(),
await NotificationStrings.savingsBody(percent),
const NotificationDetails(
android: AndroidNotificationDetails(
'savings_updates', // Channel ID
'Savings Updates', // Channel name
importance: Importance.defaultImportance,
),
),
);
}

// -------------------------------------------------------
// NOTIFY: Weekly spending recap
// -------------------------------------------------------
static Future<void> showWeeklySummary({
required double totalSpent,
required double totalBudget,
required String worstCategory,
}) async {
// Skip entirely if the user is currently using the app
if (AppState.isInForeground) return;

// Convert spending ratio into a whole-number percentage
final percent = ((totalSpent / totalBudget) * 100).toInt();

await _localNotifications.show(
1001,
await NotificationStrings.weeklyTitle(),
await NotificationStrings.weeklyBody(percent, worstCategory),
const NotificationDetails(
android: AndroidNotificationDetails(
'weekly_recap', // Channel ID
'Weekly Recap', // Channel name
importance: Importance.defaultImportance,
),
),
);
}
}
