// ============================================================
// RecurringTransactionModel
//
// Represents a saved "template" transaction that repeats
// automatically (weekly or monthly).
//
// Stored in Firestore at:
//   users/{userId}/recurringTransactions/{docId}
// ============================================================

class RecurringTransactionModel {
  final String id;           // Firestore document ID
  final String userId;       // Owner
  final String budgetId;     // Which category budget this applies to
  final String budgetTitle;  // Cached for display (e.g. "Groceries")
  final double amount;       // How much to withdraw/deposit each time
  final String type;         // 'withdraw' or 'deposit'
  final String note;         // Optional description (e.g. "Netflix sub")
  final String frequency;    // 'monthly' or 'weekly'
  final DateTime nextDueDate;// When this should fire next
  final bool isActive;       // User can pause without deleting
  final DateTime createdAt;

  RecurringTransactionModel({
    required this.id,
    required this.userId,
    required this.budgetId,
    required this.budgetTitle,
    required this.amount,
    required this.type,
    required this.note,
    required this.frequency,
    required this.nextDueDate,
    required this.isActive,
    required this.createdAt,
  });

  // ── Friendly label for the frequency ────────────────────────
  String get frequencyLabel =>
      frequency == 'weekly' ? 'Every week' : 'Every month';

  // ── Icon name for display ────────────────────────────────────
  String get typeLabel => type == 'withdraw' ? 'Expense' : 'Income';

  // ============================================================
  // FIREBASE: Dart → Firestore
  // ============================================================
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'budgetId': budgetId,
      'budgetTitle': budgetTitle,
      'amount': amount,
      'type': type,
      'note': note,
      'frequency': frequency,
      'nextDueDate': nextDueDate.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ============================================================
  // FIREBASE: Firestore → Dart
  // ============================================================
  factory RecurringTransactionModel.fromMap(
      String id, Map<String, dynamic> map) {
    return RecurringTransactionModel(
      id: id,
      userId: map['userId'] ?? '',
      budgetId: map['budgetId'] ?? '',
      budgetTitle: map['budgetTitle'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      type: map['type'] ?? 'withdraw',
      note: map['note'] ?? '',
      frequency: map['frequency'] ?? 'monthly',
      nextDueDate: map['nextDueDate'] != null
          ? DateTime.parse(map['nextDueDate'])
          : DateTime.now(),
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  // ── copyWith: create a modified copy (used when updating nextDueDate) ───
  RecurringTransactionModel copyWith({
    DateTime? nextDueDate,
    bool? isActive,
  }) {
    return RecurringTransactionModel(
      id: id,
      userId: userId,
      budgetId: budgetId,
      budgetTitle: budgetTitle,
      amount: amount,
      type: type,
      note: note,
      frequency: frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}