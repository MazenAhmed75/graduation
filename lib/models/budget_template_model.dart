// ============================================================
// BudgetTemplateModel
//
// A saved snapshot of a month's category setup.
// Stores category names + allocated amounts only —
// NOT spent amounts (templates are for planning, not history).
//
// Stored in Firestore at:
//   users/{userId}/budgetTemplates/{templateId}
// ============================================================

class TemplateCategory {
  final String title;
  final String subtitle;
  final double allocated;
  final String iconName;
  final String colorScheme;

  TemplateCategory({
    required this.title,
    required this.subtitle,
    required this.allocated,
    required this.iconName,
    required this.colorScheme,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'subtitle': subtitle,
    'allocated': allocated,
    'iconName': iconName,
    'colorScheme': colorScheme,
  };

  factory TemplateCategory.fromMap(Map<String, dynamic> map) =>
      TemplateCategory(
        title: map['title'] ?? '',
        subtitle: map['subtitle'] ?? '',
        allocated: (map['allocated'] ?? 0).toDouble(),
        iconName: map['iconName'] ?? 'category',
        colorScheme: map['colorScheme'] ?? 'green',
      );
}

// ─────────────────────────────────────────────────────────────

class BudgetTemplateModel {
  final String id;
  final String userId;
  final String name;                     // e.g. "My Monthly Budget"
  final double totalAmount;             // total budget amount
  final List<TemplateCategory> categories;
  final DateTime createdAt;

  BudgetTemplateModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.totalAmount,
    required this.categories,
    required this.createdAt,
  });

  // ── How many categories this template has ────────────────────
  int get categoryCount => categories.length;

  // ── Sum of all allocated amounts in the template ─────────────
  double get totalAllocated =>
      categories.fold(0.0, (sum, c) => sum + c.allocated);

  // ============================================================
  // FIREBASE: Dart → Firestore
  // ============================================================
  Map<String, dynamic> toMap() => {
    'userId': userId,
    'name': name,
    'totalAmount': totalAmount,
    'categories': categories.map((c) => c.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  // ============================================================
  // FIREBASE: Firestore → Dart
  // ============================================================
  factory BudgetTemplateModel.fromMap(String id, Map<String, dynamic> map) {
    final rawCats = map['categories'] as List<dynamic>? ?? [];
    return BudgetTemplateModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? 'Unnamed Template',
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      categories: rawCats
          .map((c) => TemplateCategory.fromMap(c as Map<String, dynamic>))
          .toList(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}