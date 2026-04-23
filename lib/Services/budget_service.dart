import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import 'notification_service.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper: Get the path to a user's budgets sub-collection
  CollectionReference _budgetsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('budgets');
  }

  // Helper: Get the path to a user's transactions sub-collection
  CollectionReference _transactionsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('transactions');
  }

  // -------------------------------------------------------
  // STREAM: Listen to budgets in real-time
  // The UI will automatically refresh when data changes
  // -------------------------------------------------------
  Stream<List<BudgetModel>> getBudgetsStream(String userId) {
    return _budgetsRef(userId)
        .snapshots()
        .map((snapshot) {
      // Convert each Firebase document into a BudgetModel object
      final budgets = snapshot.docs.map((doc) => BudgetModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
      budgets.sort((a, b) => a.createdAt.compareTo(b.createdAt)); // ← Sort here
      return budgets;
    });
  }

  // -------------------------------------------------------
  // CREATE: Add a new budget
  // -------------------------------------------------------
  Future<void> addBudget({
    required String userId,
    required String title,
    required String subtitle,
    required double allocated,
    String iconName = 'category',
    String colorScheme = 'green',
  }) async {
    // Let Firestore auto-generate a unique ID for this budget
    DocumentReference docRef = _budgetsRef(userId).doc();

    BudgetModel newBudget = BudgetModel(
      id: docRef.id,
      userId: userId,
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

    // Check if user is now near their limit — send notification if so
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
  // EDIT: Change the allocated amount of a budget
  // -------------------------------------------------------
  Future<void> editAllocated({
    required String userId,
    required String budgetId,
    required double newAllocated,
  }) async {
    await _budgetsRef(userId).doc(budgetId).update({'allocated': newAllocated});
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
  // PRIVATE HELPER: Save a transaction to history
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

      // Sort newest first, client-side
      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return transactions;
    });
  }
}