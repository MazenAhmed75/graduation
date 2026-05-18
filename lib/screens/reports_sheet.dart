import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/budget_model.dart';
import '../theme.dart';
import 'package:mindful_curator/l10n/app_localizations.dart';

/// Open with: showReportsSheet(context, budgets)
void showReportsSheet(BuildContext context, List<BudgetModel> budgets) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ReportsSheet(budgets: budgets),
  );
}

class ReportsSheet extends StatefulWidget {
  final List<BudgetModel> budgets;

  const ReportsSheet({super.key, required this.budgets});

  @override
  State<ReportsSheet> createState() => _ReportsSheetState();
}

class _ReportsSheetState extends State<ReportsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  int _touchedPieIndex = -1;

  // A simple palette for chart slices
  static const _palette = [
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFFC107),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFFFF5722),
    Color(0xFF795548),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final budgets = widget.budgets;
    final totalAllocated = budgets.fold(0.0, (s, b) => s + b.allocated);
    final totalSpent = budgets.fold(0.0, (s, b) => s + b.spent);
    final totalRemaining = (totalAllocated - totalSpent).clamp(0.0, double.infinity);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // ── Handle ──────────────────────────────────────────────────────
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
                      color: AppTheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.analytics_rounded,
                      color: AppTheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                   Text(
                    l10n.spendingReport,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Manrope',
                      color: AppTheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Summary totals ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _TotalChip(
                    label: l10n.allocated,
                    amount: totalAllocated,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  _TotalChip(
                    label: l10n.spent,
                    amount: totalSpent,
                    color: const Color(0xFFE57373),
                  ),
                  const SizedBox(width: 8),
                  _TotalChip(
                    label: l10n.remaining,
                    amount: totalRemaining,
                    color: const Color(0xFF43A047),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Tabs ─────────────────────────────────────────────────────────
            TabBar(
              controller: _tab,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.onSurfaceVariant,
              indicatorColor: AppTheme.primary,
              tabs:  [
              Tab(text: l10n.breakdown),
                Tab(text: l10n.byCategory),
              ],
            ),

            // ── Tab views ────────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  // TAB 1 — Pie chart (spent vs remaining)
                  _buildPieTab(budgets, totalSpent, totalAllocated, controller),

                  // TAB 2 — Bar chart (allocated vs spent per category)
                  _buildBarTab(budgets, controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── PIE CHART TAB ──────────────────────────────────────────────────────────

  Widget _buildPieTab(
      List<BudgetModel> budgets,
      double totalSpent,
      double totalAllocated,
      ScrollController scroll,
      ) {
    final l10n = AppLocalizations.of(context)!;
    if (budgets.isEmpty || totalAllocated == 0) {
      return Center(child: Text(l10n.noBudgetData));
    }

    final spentPercent =
    ((totalSpent / totalAllocated) * 100).clamp(0.0, 100.0).round();

    final sections = <PieChartSectionData>[];
    for (var i = 0; i < budgets.length; i++) {
      final b = budgets[i];
      if (b.spent <= 0) continue;
      final isTouched = i == _touchedPieIndex;
      sections.add(
        PieChartSectionData(
          value: b.spent,
          color: _palette[i % _palette.length],
          radius: isTouched ? 70 : 58,
          title: isTouched ? b.title : '',
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return ListView(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 60,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.touchedSection == null) {
                          _touchedPieIndex = -1;
                          return;
                        }
                        _touchedPieIndex =
                            response.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$spentPercent%',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.onSurface,
                    ),
                  ),
                   Text(
  l10n.used,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Legend
        ...List.generate(budgets.length, (i) {
          final b = budgets[i];
          final pct = totalAllocated > 0
              ? ((b.spent / totalAllocated) * 100).toStringAsFixed(1)
              : '0';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _palette[i % _palette.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    b.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '${b.spent.toStringAsFixed(0)}  ($pct%)',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── BAR CHART TAB ──────────────────────────────────────────────────────────

  Widget _buildBarTab(List<BudgetModel> budgets, ScrollController scroll) {
    final l10n = AppLocalizations.of(context)!;
    if (budgets.isEmpty) {
      return  Center(child: Text(l10n.noBudgetData));
    }

    final maxY = budgets
        .map((b) => b.allocated > b.spent ? b.allocated : b.spent)
        .reduce((a, b) => a > b ? a : b) *
        1.15;

    final groups = List.generate(budgets.length, (i) {
      final b = budgets[i];
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: b.allocated,
            color: _palette[i % _palette.length].withOpacity(0.35),
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: b.spent,
            color: _palette[i % _palette.length],
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        barsSpace: 4,
      );
    });

    return ListView(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: Colors.grey.shade400, label: l10n.allocated),
            const SizedBox(width: 16),
            _LegendDot(color: AppTheme.primary, label: l10n.spent),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: Colors.grey.shade200,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, _) => Text(
                      value.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final i = value.toInt();
                      if (i < 0 || i >= budgets.length) {
                        return const SizedBox.shrink();
                      }
                      final label = budgets[i].title;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          label.length > 6
                              ? '${label.substring(0, 6)}…'
                              : label,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              barGroups: groups,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Category detail rows
        ...List.generate(budgets.length, (i) {
          final b = budgets[i];
          final ratio = b.spentRatio.clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _palette[i % _palette.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        b.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      '${b.spent.toStringAsFixed(0)} / ${b.allocated.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 5,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(
                      _palette[i % _palette.length],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _TotalChip extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _TotalChip({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              amount.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
        ),
      ],
    );
  }
}