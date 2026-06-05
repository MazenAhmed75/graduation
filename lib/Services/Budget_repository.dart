import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_model.dart';

/// Handles all Firestore reads needed by ReportsSheet.
///
/// Usage — create one instance per open sheet (or inject via your provider):
///
///   final repo = BudgetRepository(userId: currentUser.uid);
///
///   showReportsSheet(
///     context,
///     currentMonthBudgets,
///     initialMonth: DateTime.now(),
///     onLoadMonth: repo.getBudgetsForMonth,
///     onLoadYearlyTotals: repo.getMonthlySpendingTotals,
///   );
class BudgetRepository {
  // ⚠️ Change this if your Firestore collection has a different name
  static const _budgetsCollection = 'budgets';

  final FirebaseFirestore _db;
  final String userId;

  BudgetRepository({
    required this.userId,
    FirebaseFirestore? db,
  }) : _db = db ?? FirebaseFirestore.instance;

  // ── Helpers ─────────────────────────────────────────────────────────────

  /// Converts a DateTime to the "YYYY-MM" format used as monthlyBudgetId.
  /// e.g. DateTime(2026, 5, 14)  →  "2026-05"
  static String _monthId(DateTime month) =>
      '${month.year}-${month.month.toString().padLeft(2, '0')}';

  // ── onLoadMonth callback ─────────────────────────────────────────────────

  /// Returns all BudgetModels for the given month.
  /// Plug directly into ReportsSheet's [onLoadMonth] parameter.
  ///
  /// Firestore query:
  ///   budgets
  ///     WHERE userId        == <uid>
  ///     WHERE monthlyBudgetId == "2026-05"
  Future<List<BudgetModel>> getBudgetsForMonth(DateTime month) async {
    final snap = await _db
        .collection(_budgetsCollection)
        .where('userId', isEqualTo: userId)
        .where('monthlyBudgetId', isEqualTo: _monthId(month))
        .get();

    return snap.docs
        .map((doc) => BudgetModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  // ── onLoadYearlyTotals callback ──────────────────────────────────────────

  /// Returns total amount spent per month for [year].
  /// Map key = month number (1–12), value = sum of [BudgetModel.spent].
  /// Months with zero spending are excluded from the map.
  ///
  /// Plug directly into ReportsSheet's [onLoadYearlyTotals] parameter.
  ///
  /// Runs 12 Firestore queries in parallel — one per month — using
  /// Future.wait, so latency ≈ the slowest single query, not the sum.
  Future<Map<int, double>> getMonthlySpendingTotals(int year) async {
    final futures = List.generate(12, (i) async {
      final monthNum = i + 1;
      final monthKey = '$year-${monthNum.toString().padLeft(2, '0')}';

      final snap = await _db
          .collection(_budgetsCollection)
          .where('userId', isEqualTo: userId)
          .where('monthlyBudgetId', isEqualTo: monthKey)
          .get();

      final total = snap.docs.fold<double>(
        0.0,
            (sum, doc) =>
        sum + ((doc.data()['spent'] as num?)?.toDouble() ?? 0.0),
      );

      return MapEntry(monthNum, total);
    });

    final entries = await Future.wait(futures);

    // Only include months that have actual spending
    return Map.fromEntries(entries.where((e) => e.value > 0));
  }
}