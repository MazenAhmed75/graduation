class TransactionModel {
  final String id;
  final String budgetId;         // Which budget this belongs to
  final String categoryKey;      // Category the user chooses from
  final String customTitle;      // custom title the user makes
  final double amount;           // How much money moved
  final String type;             // "deposit" or "withdraw"
  final String note;             // Optional note from user
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.budgetId,
    required this.categoryKey,
    required this.customTitle,
    required this.amount,
    required this.type,
    this.note = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'budgetId': budgetId,
      'categoryKey': categoryKey,
      'customTitle': customTitle,
      'amount': amount,
      'type': type,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(String id, Map<String, dynamic> map) {
    return TransactionModel(
      id: id,
      budgetId: map['budgetId'] ?? '',
      categoryKey: map['categoryKey'] ?? 'custom',
      customTitle: map['customTitle'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      type: map['type'] ?? 'withdraw',
      note: map['note'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}