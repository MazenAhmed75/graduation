import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_model.dart';
import '../Services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetChecker {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> runDailyCheck() async {
    // You need a userId here — read it from shared_preferences
    // where you saved it at login, since there's no auth context
    // in background tasks
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    final now = DateTime.now();
    final daysLeft = 30 - now.day;
    final percentOfMonthElapsed = now.day / 30;
    final monthId = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .where('monthlyBudgetId', isEqualTo: monthId)
        .get();

    for (final doc in snapshot.docs) {
      final budget = BudgetModel.fromMap(doc.id, doc.data());
      final percentUsed = budget.spent / budget.allocated;

      // Only notify if spending pace is ahead of time elapsed
      if (percentUsed > percentOfMonthElapsed + 0.20) {
        await NotificationService.showBudgetWarning(
          budgetTitle: budget.categoryKey,
          percentUsed: (percentUsed * 100).round(),
          daysLeftInMonth: daysLeft,
        );
      }
    }
  }
}