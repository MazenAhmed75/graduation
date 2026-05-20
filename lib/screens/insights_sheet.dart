import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../theme.dart';
import '../utils/budget_insight_helper.dart';
import 'package:mindful_curator/l10n/app_localizations.dart';

/// A bottom sheet that summarises all category insights for the current month.
/// Open it with: showInsightsSheet(context, budgets, daysLeft)
void showInsightsSheet(
    BuildContext context,
    List<BudgetModel> budgets,
    int daysLeft,
    ) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => InsightsSheet(budgets: budgets, daysLeft: daysLeft),
  );
}

class InsightsSheet extends StatelessWidget {
  final List<BudgetModel> budgets;
  final int daysLeft;

  const InsightsSheet({
    super.key,
    required this.budgets,
    required this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;


    final insights = BudgetInsightHelper.getAllInsights(
      context,
      budgets,
      daysLeftInMonth: daysLeft,
    );

    final overBudget = budgets.where((b) => b.spent > b.allocated).length;
    final onTrack = budgets.length - overBudget;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // ── Drag handle ─────────────────────────────────────────────────
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.tips_and_updates_rounded,
                      color: AppTheme.onTertiaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.spendingInsights,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.onSurface,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      Text(
                        l10n.daysLeft(daysLeft),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Summary row ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _SummaryChip(
                    label: l10n.onTrack(onTrack),
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF43A047),
                  ),
                  const SizedBox(width: 8),
                  if (overBudget > 0)
                    _SummaryChip(
                      label: l10n.overBudget(overBudget),
                      icon: Icons.warning_rounded,
                      color: const Color(0xFFD32F2F),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),

            // ── Insight list ─────────────────────────────────────────────────
            Expanded(
              child: budgets.isEmpty
                  ?  Center(
                child: Text(
                  l10n.addBudgetCategoriesInsights,
                  style: const TextStyle(color: AppTheme.onSurfaceVariant),
                ),
              )
                  : ListView.separated(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                itemCount: insights.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final item = insights[i];
                  final ratio = item.budget.spentRatio.clamp(0.0, 1.0);
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: item.insight.color.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: item.insight.color.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              item.insight.icon,
                              color: item.insight.color,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.budget.customTitle.isNotEmpty ? item.budget.customTitle : item.budget.categoryKey,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: AppTheme.onSurface,
                                ),
                              ),
                            ),
                            Text(
                              '${(ratio * 100).round()}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: item.insight.color,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 6,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(
                              item.insight.color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.insight.text,
                          style: TextStyle(
                            fontSize: 13,
                            color: item.insight.color
                                .withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}