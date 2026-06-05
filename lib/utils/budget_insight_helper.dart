// ignore_for_file: unnecessary_non_null_assertion, unused_field

import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import 'package:mindful_curator/l10n/app_localizations.dart';
import '../utils/currency_formatter.dart'; // 👈 1. Import the extension

/// Generates a human-readable insight and icon for a single budget category
/// based on how much has been spent relative to the allocated amount and
/// how many days are left in the month.
class BudgetInsightHelper {
  static const _noInsight = '';

  /// Returns an [InsightResult] with a tip, icon, and color for a given budget.
  static InsightResult getInsight(
      BuildContext context,
      BudgetModel budget, {
        int daysLeftInMonth = 15,
      }) {
    final ratio = budget.spentRatio.clamp(0.0, 1.0);
    final remaining = budget.remaining;
    final spent = budget.spent;
    final allocated = budget.allocated;

    final l10n = AppLocalizations.of(context)!;
    // 👈 2. Get the current active language (e.g., 'ar')
    final locale = Localizations.localeOf(context).languageCode;

    // ── Fully used budget ───────────────────────────────────────
    if (spent == allocated && daysLeftInMonth > 0) {
      return InsightResult(
        // 👈 Apply extension to daysLeftInMonth
        text: l10n.budgetFullyUsedInsight(
          daysLeftInMonth.toString().toLocalizedDigits(locale),
        ),
        icon: Icons.lock_clock_rounded,
        color: const Color(0xFFE65100),
      );
    }

    // ── Over budget ──────────────────────────────────────────────────────────
    if (spent > allocated) {
      final over = spent - allocated;
      return InsightResult(
        // 👈 Pass locale to _fmt
        text: l10n.overBudgetInsight(
          _fmt(over, locale),
        ),
        icon: Icons.warning_rounded,
        color: const Color(0xFFD32F2F),
      );
    }

    // ── Critical: used 90%+ ──────────────────────────────────────────────────
    if (ratio >= 0.90) {
      return InsightResult(
        text: l10n.nearlyAtLimitInsight(
          _fmt(remaining, locale),
        ),
        icon: Icons.error_outline_rounded,
        color: const Color(0xFFF57C00),
      );
    }

    // ── Warning: used 75-90% ─────────────────────────────────────────────────
    if (ratio >= 0.75) {
      return InsightResult(
        // 👈 Apply extension to both numbers
        text: l10n.usedPercentInsight(
          ((ratio * 100).round()).toString().toLocalizedDigits(locale),
          daysLeftInMonth.toString().toLocalizedDigits(locale),
        ),
        icon: Icons.trending_up_rounded,
        color: const Color(0xFFF9A825),
      );
    }

    // ── On track: used 50-75% ────────────────────────────────────────────────
    if (ratio >= 0.50) {
      return InsightResult(
        text: l10n.halfwayBudgetInsight(
          _fmt(remaining, locale),
        ),
        icon: Icons.track_changes_rounded,
        color: const Color(0xFF0288D1),
      );
    }

    // ── Great control: month almost over but spending is low ─────────────────
    if (daysLeftInMonth <= 7 && ratio < 0.50) {
      return InsightResult(
        text: l10n.savedThisMonthInsight(
          _fmt(remaining, locale),
        ),
        icon: Icons.savings_rounded,
        color: const Color(0xFF388E3C),
      );
    }

    // ── Nothing spent yet ────────────────────────────────────────────────────
    if (spent == 0) {
      return InsightResult(
        text: l10n.noSpendingInsight(
          _fmt(allocated, locale),
        ),
        icon: Icons.account_balance_wallet_outlined,
        color: const Color(0xFF757575),
      );
    }

    // ── Default: healthy spending ────────────────────────────────────────────
    return InsightResult(
      text: l10n.onTrackInsight(
        _fmt(remaining, locale),
      ),
      icon: Icons.check_circle_outline_rounded,
      color: const Color(0xFF43A047),
    );
  }

  /// Returns a sorted list of insights for all categories, most urgent first.
  static List<CategoryInsight> getAllInsights(
      BuildContext context,
      List<BudgetModel> budgets, {
        int daysLeftInMonth = 15,
      }) {
    final results = budgets.map((b) {
      final insight = getInsight(
        context,
        b,
        daysLeftInMonth: daysLeftInMonth,
      );
      return CategoryInsight(budget: b, insight: insight);
    }).toList();

    // Sort: over budget first, then by spend ratio descending
    results.sort((a, b) {
      final aOver = a.budget.spent > a.budget.allocated ? 1 : 0;
      final bOver = b.budget.spent > b.budget.allocated ? 1 : 0;
      if (aOver != bOver) return bOver - aOver;
      return b.budget.spentRatio.compareTo(a.budget.spentRatio);
    });

    return results;
  }

  // 👈 3. Update the _fmt helper to accept locale and apply the extension
  static String _fmt(double amount, String locale) =>
      amount.toStringAsFixed(0).toLocalizedDigits(locale);
}

class InsightResult {
  final String text;
  final IconData icon;
  final Color color;

  const InsightResult({
    required this.text,
    required this.icon,
    required this.color,
  });
}

class CategoryInsight {
  final BudgetModel budget;
  final InsightResult insight;

  const CategoryInsight({required this.budget, required this.insight});
}