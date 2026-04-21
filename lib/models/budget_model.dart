class BudgetModel {
  final String id;           // Firebase document ID
  final String userId;       // Which user owns this budget
  String title;              // e.g. "Groceries"
  String subtitle;           // e.g. "Weekly shopping"
  double allocated;          // Total budget amount (e.g. 450.0)
  double spent;              // How much has been spent (e.g. 324.0)
  String iconName;           // Icon name as text (e.g. "shopping_cart")
  String colorScheme;        // Color label (e.g. "green", "blue")
  final DateTime createdAt;  // When it was created

  BudgetModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.subtitle,
    required this.allocated,
    required this.spent,
    required this.iconName,
    required this.colorScheme,
    required this.createdAt,
  });

  // --- How much money is left ---
  double get remaining => allocated - spent;

  // --- What percentage has been spent (0.0 to 1.0) ---
  double get spentRatio => allocated > 0 ? (spent / allocated).clamp(0.0, 1.0) : 0.0;

  // --- Is the user near their limit? (over 80% spent) ---
  bool get isNearLimit => spentRatio >= 0.8;

  // --- Is the budget fully used? ---
  bool get isOverBudget => spent >= allocated;

  // ============================================================
  // FIREBASE CONVERSION: Dart object → Firebase document
  // This runs when you SAVE to Firestore
  // ============================================================
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'subtitle': subtitle,
      'allocated': allocated,
      'spent': spent,
      'iconName': iconName,
      'colorScheme': colorScheme,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ============================================================
  // FIREBASE CONVERSION: Firebase document → Dart object
  // This runs when you READ from Firestore
  // ============================================================
  factory BudgetModel.fromMap(String id, Map<String, dynamic> map) {
    return BudgetModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? 'Unnamed Budget',
      subtitle: map['subtitle'] ?? '',
      allocated: (map['allocated'] ?? 0).toDouble(),
      spent: (map['spent'] ?? 0).toDouble(),
      iconName: map['iconName'] ?? 'category',
      colorScheme: map['colorScheme'] ?? 'green',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}