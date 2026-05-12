import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_model.dart';
import '../models/monthly_budget_model.dart';
import '../models/transaction_model.dart';
import 'notification_service.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // -------------------------------------------------------
  // HELPERS: Firestore references
  // -------------------------------------------------------

  // Helper: Get the path to a user's budgets sub-collection
  CollectionReference _budgetsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('budgets');

  // Helper: Get the path to a user's transactions sub-collection
  CollectionReference _transactionsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('transactions');

  // Helper: Get the path to a user's monthly budgets sub-collection
  // Each document represents a month (ID format: "YYYY-MM")
  CollectionReference _monthlyBudgetsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('monthlyBudgets');

  // -------------------------------------------------------
  // STREAM: Listen to monthly budget in real-time
  // Returns null if no monthly budget exists yet
  // -------------------------------------------------------
  Stream<MonthlyBudgetModel?> getMonthlyBudgetStream(
      String userId, String monthId) {
    return _monthlyBudgetsRef(userId).doc(monthId).snapshots().map((doc) {
      if (!doc.exists) return null;

      // Convert Firebase document into MonthlyBudgetModel
      return MonthlyBudgetModel.fromMap(
          doc.id, doc.data() as Map<String, dynamic>);
    });
  }

  // -------------------------------------------------------
  // CREATE/UPDATE: Set a monthly budget
  // If it exists → overwrite
  // If not → create new
  // -------------------------------------------------------
  Future<void> setMonthlyBudget({
    required String userId,
    required String monthId,
    required double totalAmount,
  }) async {
    final model = MonthlyBudgetModel(
      id: monthId,
      userId: userId,
      totalAmount: totalAmount,
      createdAt: DateTime.now(),
    );

    await _monthlyBudgetsRef(userId).doc(monthId).set(model.toMap());
  }

  // -------------------------------------------------------
  // STREAM: Listen to category budgets for a specific month
  // The UI will automatically refresh when data changes
  // -------------------------------------------------------
  Stream<List<BudgetModel>> getCategoryBudgetsStream(
      String userId, String monthId) {
    return _budgetsRef(userId)
        .where('monthlyBudgetId', isEqualTo: monthId)
        .snapshots()
        .map((snapshot) {
      // Convert each Firebase document into a BudgetModel object
      final budgets = snapshot.docs
          .map((doc) =>
          BudgetModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      // Sort by creation date (oldest → newest)
      budgets.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      return budgets;
    });
  }

  // -------------------------------------------------------
  // CREATE: Add a new category budget linked to a month
  // -------------------------------------------------------
  Future<void> addBudget({
    required String userId,
    required String monthlyBudgetId,
    required String title,
    required String subtitle,
    required double allocated,
    String iconName = 'category',
    String colorScheme = 'green',
  }) async {
    // Let Firestore auto-generate a unique ID
    DocumentReference docRef = _budgetsRef(userId).doc();

    BudgetModel newBudget = BudgetModel(
      id: docRef.id,
      userId: userId,
      monthlyBudgetId: monthlyBudgetId,
      title: title,
      subtitle: subtitle,
      allocated: allocated,
      spent: 0.0,
      iconName: iconName,
      colorScheme: colorScheme,
      createdAt: DateTime.now(),
    );

    await docRef.set(newBudget.toMap());
  }

  // -------------------------------------------------------
  // WITHDRAW: User spends money from a budget
  // -------------------------------------------------------
  Future<void> withdraw({
    required String userId,
    required BudgetModel budget,
    required double amount,
    String note = '',
  }) async {
    double newSpent = budget.spent + amount;

    // Update the budget's spent amount in Firestore
    await _budgetsRef(userId).doc(budget.id).update({'spent': newSpent});

    // Save this as a transaction in history
    await _saveTransaction(
      userId: userId,
      budget: budget,
      amount: amount,
      type: 'withdraw',
      note: note,
    );

    // Check if user is near limit → send notification
    double newRatio = newSpent / budget.allocated;
    if (newRatio >= 0.8) {
      await NotificationService.showBudgetWarning(
        budgetTitle: budget.title,
        percentUsed: (newRatio * 100).round(),
      );
    }
  }

  // -------------------------------------------------------
  // DEPOSIT: User adds money back to a budget
  // -------------------------------------------------------
  Future<void> deposit({
    required String userId,
    required BudgetModel budget,
    required double amount,
    String note = '',
  }) async {
    double newSpent = (budget.spent - amount).clamp(0.0, double.infinity);

    await _budgetsRef(userId).doc(budget.id).update({'spent': newSpent});

    await _saveTransaction(
      userId: userId,
      budget: budget,
      amount: amount,
      type: 'deposit',
      note: note,
    );
  }

  // -------------------------------------------------------
  // EDIT: Change allocated amount
  // -------------------------------------------------------
  Future<void> editAllocated({
    required String userId,
    required String budgetId,
    required double newAllocated,
  }) async {
    await _budgetsRef(userId)
        .doc(budgetId)
        .update({'allocated': newAllocated});
  }

  // -------------------------------------------------------
  // DELETE: Remove a budget entirely
  // -------------------------------------------------------
  Future<void> deleteBudget({
    required String userId,
    required String budgetId,
  }) async {
    await _budgetsRef(userId).doc(budgetId).delete();
  }

  // -------------------------------------------------------
  // PRIVATE HELPER: Save transaction history
  // Called internally by withdraw() and deposit()
  // -------------------------------------------------------
  Future<void> _saveTransaction({
    required String userId,
    required BudgetModel budget,
    required double amount,
    required String type,
    String note = '',
  }) async {
    DocumentReference docRef = _transactionsRef(userId).doc();

    TransactionModel transaction = TransactionModel(
      id: docRef.id,
      budgetId: budget.id,
      budgetTitle: budget.title,
      amount: amount,
      type: type,
      note: note,
      createdAt: DateTime.now(),
    );

    await docRef.set(transaction.toMap());
  }

  // -------------------------------------------------------
  // STREAM: Get transaction history for a specific budget
  // -------------------------------------------------------
  Stream<List<TransactionModel>> getTransactionsStream({
    required String userId,
    required String budgetId,
  }) {
    return _transactionsRef(userId)
        .where('budgetId', isEqualTo: budgetId)
        .snapshots()
        .map((snapshot) {
      final transactions = snapshot.docs
          .map((doc) => TransactionModel.fromMap(
          doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      // Sort newest first
      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return transactions;
    });
  }
  // -------------------------------------------------------
// STREAM: Get ALL transactions for a user (all categories)
// Used by TransactionsScreen for full history + search
// -------------------------------------------------------
  Stream<List<TransactionModel>> getAllTransactionsStream(String userId) {
    return _transactionsRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TransactionModel.fromMap(
        doc.id, doc.data() as Map<String, dynamic>))
        .toList());
  }
}