import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recurring_transaction_model.dart';
import '../models/budget_model.dart';
import 'budget_service.dart';

// ============================================================
// RecurringService
//
// Handles all recurring transaction logic:
//   - Saving a new recurring template
//   - Processing overdue ones on app launch
//   - Streaming the list for a management UI
//   - Toggling active/paused
//   - Deleting
//
// HOW IT WORKS:
//   1. User checks "Make recurring" when withdrawing/depositing.
//   2. A RecurringTransactionModel is saved to Firestore.
//   3. Every time the app starts, processDueTransactions() runs.
//   4. Any recurring transaction whose nextDueDate is in the past
//      is auto-applied to the correct budget, and its nextDueDate
//      is pushed forward by one period.
// ============================================================
class RecurringService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reuse the existing BudgetService for withdraw/deposit logic
  // (keeps notification checks, transaction history saving, etc.)
  final BudgetService _budgetService = BudgetService();

  // ── Firestore reference helper ───────────────────────────────
  CollectionReference _recurringRef(String userId) => _firestore
      .collection('users')
      .doc(userId)
      .collection('recurringTransactions');

  // ── Firestore reference to a single budget doc ───────────────
  // Needed to fetch the live BudgetModel before applying
  DocumentReference _budgetDocRef(String userId, String budgetId) =>
      _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budgetId);

  // ============================================================
  // CREATE: Save a new recurring transaction template
  //
  // Call this right after the user completes a withdraw/deposit
  // and has "Make recurring" checked.
  // ============================================================
  Future<void> addRecurringTransaction({
    required String userId,
    required BudgetModel budget,
    required double amount,
    required String type,        // 'withdraw' or 'deposit'
    required String frequency,   // 'monthly' or 'weekly'
    String note = '',
  }) async {
    final docRef = _recurringRef(userId).doc();

    // Next due date = today + one period
    // (it already fired once manually, so the next run is 1 period away)
    final nextDueDate = _nextDate(DateTime.now(), frequency);

    final model = RecurringTransactionModel(
      id: docRef.id,
      userId: userId,
      budgetId: budget.id,
      budgetTitle: budget.customTitle.isNotEmpty ? budget.customTitle : budget.categoryKey,
      amount: amount,
      type: type,
      note: note.isNotEmpty ? note : '${budget.customTitle.isNotEmpty ? budget.customTitle : budget.categoryKey} (recurring)',
      frequency: frequency,
      nextDueDate: nextDueDate,
      isActive: true,
      createdAt: DateTime.now(),
    );

    await docRef.set(model.toMap());
  }

  // ============================================================
  // PROCESS: Auto-apply any overdue recurring transactions
  //
  // Call this in home_screen.dart or app startup (initState).
  // Safe to call every launch — it only acts on overdue ones.
  // ============================================================
  Future<void> processDueTransactions(String userId) async {
    final now = DateTime.now();

    // Fetch all active recurring transactions for this user
    final snapshot = await _recurringRef(userId)
        .where('isActive', isEqualTo: true)
        .get();

    for (final doc in snapshot.docs) {
      final recurring = RecurringTransactionModel.fromMap(
          doc.id, doc.data() as Map<String, dynamic>);

      // Skip if not due yet
      if (recurring.nextDueDate.isAfter(now)) continue;

      // Fetch the live BudgetModel so spent/allocated are current
      final budgetDoc =
      await _budgetDocRef(userId, recurring.budgetId).get();

      // Budget might have been deleted — skip gracefully
      if (!budgetDoc.exists) continue;

      final budget = BudgetModel.fromMap(
          budgetDoc.id, budgetDoc.data() as Map<String, dynamic>);

      // Apply the transaction (reuses existing notification logic)
      if (recurring.type == 'withdraw') {
        await _budgetService.withdraw(
          userId: userId,
          budget: budget,
          amount: recurring.amount,
          note: '[Auto] ${recurring.note}',
        );
      } else {
        await _budgetService.deposit(
          userId: userId,
          budget: budget,
          amount: recurring.amount,
          note: '[Auto] ${recurring.note}',
        );
      }

      // Push nextDueDate forward by one period
      final newDueDate = _nextDate(recurring.nextDueDate, recurring.frequency);
      await _recurringRef(userId)
          .doc(recurring.id)
          .update({'nextDueDate': newDueDate.toIso8601String()});
    }
  }

  // ============================================================
  // STREAM: Listen to all recurring transactions (for a list UI)
  // ============================================================
  Stream<List<RecurringTransactionModel>> getRecurringStream(
      String userId) {
    return _recurringRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RecurringTransactionModel.fromMap(
        doc.id, doc.data() as Map<String, dynamic>))
        .toList());
  }

  // ============================================================
  // TOGGLE: Pause or resume a recurring transaction
  // ============================================================
  Future<void> toggleActive(
      {required String userId,
        required String recurringId,
        required bool isActive}) async {
    await _recurringRef(userId)
        .doc(recurringId)
        .update({'isActive': isActive});
  }

  // ============================================================
  // DELETE: Remove a recurring transaction permanently
  // ============================================================
  Future<void> deleteRecurring(
      {required String userId, required String recurringId}) async {
    await _recurringRef(userId).doc(recurringId).delete();
  }

  // ============================================================
  // PRIVATE: Calculate the next due date from a given base date
  // ============================================================
  DateTime _nextDate(DateTime from, String frequency) {
    if (frequency == 'weekly') {
      return from.add(const Duration(days: 7));
    }
    // Monthly: same day next month
    int nextMonth = from.month + 1;
    int nextYear = from.year;
    if (nextMonth > 12) {
      nextMonth = 1;
      nextYear += 1;
    }
    // Clamp day to valid range for that month (e.g. Jan 31 → Feb 28)
    final lastDay = DateTime(nextYear, nextMonth + 1, 0).day;
    final nextDay = from.day.clamp(1, lastDay);
    return DateTime(nextYear, nextMonth, nextDay);
  }
}