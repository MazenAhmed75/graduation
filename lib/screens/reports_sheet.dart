import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';          // ✅ FIX 1: needed for addPostFrameCallback
import 'package:fl_chart/fl_chart.dart';
import '../models/budget_model.dart';
import '../theme.dart';
import 'package:mindful_curator/l10n/app_localizations.dart';
import '../utils/category_localization.dart';
import 'package:intl/intl.dart';
import '../utils/currency_formatter.dart';

/// Open with: showReportsSheet(context, budgets)
///
/// To enable month navigation and yearly view, supply the optional callbacks:
///   onLoadMonth      – called when the user taps < / >, returns budgets for that month
///   onLoadYearlyTotals – called once; returns Map<month(1-12), totalSpent> for the year
///   initialMonth     – which month is "current" (defaults to DateTime.now())
void showReportsSheet(
    BuildContext context,
    List<BudgetModel> budgets, {
      DateTime? initialMonth,
      Future<List<BudgetModel>> Function(DateTime month)? onLoadMonth,
      Future<Map<int, double>> Function(int year)? onLoadYearlyTotals,
    }) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,                        // ✅ FIX 2: prevents mouse-tracker crash on dismiss
    builder: (_) => ReportsSheet(
      budgets: budgets,
      initialMonth: initialMonth ?? DateTime.now(),
      onLoadMonth: onLoadMonth,
      onLoadYearlyTotals: onLoadYearlyTotals,
    ),
  );
}

class ReportsSheet extends StatefulWidget {
  final List<BudgetModel> budgets;
  final DateTime initialMonth;
  final Future<List<BudgetModel>> Function(DateTime month)? onLoadMonth;
  final Future<Map<int, double>> Function(int year)? onLoadYearlyTotals;

  const ReportsSheet({
    super.key,
    required this.budgets,
    required this.initialMonth,
    this.onLoadMonth,
    this.onLoadYearlyTotals,
  });

  @override
  State<ReportsSheet> createState() => _ReportsSheetState();
}

class _ReportsSheetState extends State<ReportsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  int _touchedPieIndex = -1;

  // ── Month navigation state ─────────────────────────────────────────────
  late DateTime _selectedMonth;
  late List<BudgetModel> _displayedBudgets;
  bool _isLoadingMonth = false;

  // ── Yearly data state ──────────────────────────────────────────────────
  Map<int, double> _yearlyTotals = {}; // key = month 1-12, value = total spent
  bool _isLoadingYear = false;

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

  bool get _showYearlyTab => widget.onLoadYearlyTotals != null;

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _selectedMonth.year == now.year &&
        _selectedMonth.month == now.month;
  }

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _showYearlyTab ? 3 : 2, vsync: this);
    _selectedMonth = DateTime(
      widget.initialMonth.year,
      widget.initialMonth.month,
    );
    _displayedBudgets = widget.budgets;

    if (_showYearlyTab) _loadYearlyData();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  // ── Data loading helpers ───────────────────────────────────────────────

  Future<void> _navigateMonth(int delta) async {
    if (widget.onLoadMonth == null) return;

    final newMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + delta,
    );

    setState(() {
      _isLoadingMonth = true;
      _touchedPieIndex = -1;
    });

    try {
      final budgets = await widget.onLoadMonth!(newMonth);
      if (mounted) {
        setState(() {
          _selectedMonth = newMonth;
          _displayedBudgets = budgets;
          _isLoadingMonth = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMonth = false);
    }
  }

  Future<void> _loadYearlyData() async {
    if (widget.onLoadYearlyTotals == null) return;
    setState(() => _isLoadingYear = true);
    try {
      final totals = await widget.onLoadYearlyTotals!(_selectedMonth.year);
      if (mounted) {
        setState(() {
          _yearlyTotals = totals;
          _isLoadingYear = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingYear = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final budgets = _displayedBudgets;
    final totalAllocated = budgets.fold(0.0, (s, b) => s + b.allocated);
    final totalSpent = budgets.fold(0.0, (s, b) => s + b.spent);
    final totalRemaining =
    (totalAllocated - totalSpent).clamp(0.0, double.infinity);

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
            // ── Handle ──────────────────────────────────────────────────
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

            // ── Header ──────────────────────────────────────────────────
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
            const SizedBox(height: 12),

            // ── Month navigator (only when onLoadMonth is supplied) ──────
            if (widget.onLoadMonth != null) _buildMonthNavigator(),

            const SizedBox(height: 12),

            // ── Loading spinner while fetching a different month ─────────
            if (_isLoadingMonth)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              // ── Summary totals ─────────────────────────────────────────
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

              // ── Tabs ───────────────────────────────────────────────────
              TabBar(
                controller: _tab,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.onSurfaceVariant,
                indicatorColor: AppTheme.primary,
                tabs: [
                  Tab(text: l10n.breakdown),
                  Tab(text: l10n.byCategory),
                  // TODO: add l10n.yearly once you update your ARB files
                  if (_showYearlyTab)  Tab(text: l10n.yearly),
                ],
              ),

              // ── Tab views ──────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _buildPieTab(
                        budgets, totalSpent, totalAllocated, controller),
                    _buildBarTab(budgets, controller),
                    if (_showYearlyTab) _buildYearlyTab(controller),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── MONTH NAVIGATOR ──────────────────────────────────────────────────────

  Widget _buildMonthNavigator() {
    final monthLabel = DateFormat('MMMM yyyy').format(_selectedMonth);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _isLoadingMonth ? null : () => _navigateMonth(-1),
            icon: const Icon(Icons.chevron_left_rounded),
            color: AppTheme.primary,
          ),
          Text(
            monthLabel,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
            ),
          ),
          IconButton(
            onPressed: (_isLoadingMonth || _isCurrentMonth)
                ? null
                : () => _navigateMonth(1),
            icon: Icon(
              Icons.chevron_right_rounded,
              color: _isCurrentMonth
                  ? Colors.grey.shade300
                  : AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ── PIE CHART TAB ────────────────────────────────────────────────────────

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

    final localeCode = Localizations.localeOf(context).languageCode;
    final spentPercent =
    ((totalSpent / totalAllocated) * 100).clamp(0.0, 100.0).round();

    final sections = <PieChartSectionData>[];
    int sectionIndex = 0;
    for (var i = 0; i < budgets.length; i++) {
      final b = budgets[i];
      if (b.spent <= 0) continue;
      // Change 'i == _touchedPieIndex' to check against sectionIndex instead:
      final isTouched = sectionIndex == _touchedPieIndex;
      sections.add(
        PieChartSectionData(
          value: b.spent,
          color: _palette[i % _palette.length],
          radius: isTouched ? 70 : 58,
          title: isTouched
              ? CategoryLocalization.getCategoryName(
            context,
            b.categoryKey,
            b.customTitle,
          )
              : '',
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      sectionIndex++;
    }

    if (sections.isEmpty) {
      return Center(child: Text(l10n.noBudgetData));
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
                    // ✅ FIX 3: defer setState to after the mouse-tracker
                    //    finishes its current update cycle — fixes the
                    //    !_debugDuringDeviceUpdate crash on web
                    touchCallback: (event, response) {
                      final newIndex =
                      (event.isInterestedForInteractions &&
                          response?.touchedSection != null)
                          ? response!
                          .touchedSection!.touchedSectionIndex
                          : -1;

                      if (newIndex != _touchedPieIndex) {
                        Future(() {
                          if (mounted) {
                            setState(() => _touchedPieIndex = newIndex);
                          }
                        });
                      }
                    },
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${NumberFormat.decimalPattern(localeCode).format(spentPercent)}%'
                        .toLocalizedDigits(localeCode),
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
          final intFormatter = NumberFormat.decimalPattern(localeCode);
          final percentFormatter = NumberFormat.decimalPattern(localeCode)
            ..maximumFractionDigits = 1;
          final pctValue =
          totalAllocated > 0 ? ((b.spent / totalAllocated) * 100) : 0.0;

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
                    CategoryLocalization.getCategoryName(
                      context,
                      b.categoryKey,
                      b.customTitle,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '${intFormatter.format(b.spent)}  (${percentFormatter.format(pctValue)}%)'
                      .toLocalizedDigits(localeCode),
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

  // ── BAR CHART TAB ────────────────────────────────────────────────────────

  Widget _buildBarTab(List<BudgetModel> budgets, ScrollController scroll) {
    final l10n = AppLocalizations.of(context)!;
    if (budgets.isEmpty) {
      return Center(child: Text(l10n.noBudgetData));
    }

    final localeCode = Localizations.localeOf(context).languageCode;

    final maxY = budgets
        .map((b) => b.allocated > b.spent ? b.allocated : b.spent)
        .reduce((a, b) => a > b ? a : b) *
        1.15;

    final groups = List.generate(budgets.length, (i) {
      final b = budgets[i];
      final bool isOverspent = b.spent > b.allocated;
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
            color:
            isOverspent ? Colors.redAccent : _palette[i % _palette.length],
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
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      NumberFormat.decimalPattern(localeCode)
                          .format(rod.toY)
                          .toLocalizedDigits(localeCode),
                      const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
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
                      NumberFormat.decimalPattern(localeCode)
                          .format(value)
                          .toLocalizedDigits(localeCode),
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
                      final label = CategoryLocalization.getCategoryName(
                        context,
                        budgets[i].categoryKey,
                        budgets[i].customTitle,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
          final detailsFormatter = NumberFormat.decimalPattern(localeCode);
          final bool isOverspent = b.spent > b.allocated;

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
                        CategoryLocalization.getCategoryName(
                          context,
                          b.categoryKey,
                          b.customTitle,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      '${detailsFormatter.format(b.spent)} / ${detailsFormatter.format(b.allocated)}'
                          .toLocalizedDigits(localeCode),
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
                      isOverspent
                          ? Colors.redAccent
                          : _palette[i % _palette.length],
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

  // ── YEARLY TAB ───────────────────────────────────────────────────────────

  Widget _buildYearlyTab(ScrollController scroll) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;

    if (_isLoadingYear) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_yearlyTotals.isEmpty) {
      return  Center(child: Text(l10n.noYearlyData));
    }

    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    final maxVal = _yearlyTotals.values.isEmpty
        ? 1.0
        : _yearlyTotals.values.reduce((a, b) => a > b ? a : b) * 1.2;

    final currentMonthNum = _selectedMonth.month; // 1-based

    final groups = List.generate(12, (i) {
      final monthNum = i + 1;
      final spent = _yearlyTotals[monthNum] ?? 0.0;
      final isCurrent = monthNum == currentMonthNum;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: spent,
            color: isCurrent
                ? AppTheme.primary
                : AppTheme.primary.withOpacity(0.35),
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    final yearlyTotal = _yearlyTotals.values.fold(0.0, (a, b) => a + b);
    final monthsWithData =
        _yearlyTotals.values.where((v) => v > 0).length;
    final monthlyAvg =
    monthsWithData > 0 ? yearlyTotal / monthsWithData : 0.0;
    final formatter = NumberFormat.decimalPattern(localeCode);

    return ListView(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // ── Year summary chips ─────────────────────────────────────────
        Row(
          children: [
            _TotalChip(
              label: l10n.yearlyTotal(_selectedMonth.year),
              amount: yearlyTotal,
              color: AppTheme.primary,
            ),
            const SizedBox(width: 8),
            _TotalChip(
              label: l10n.monthlyAverage,
              amount: monthlyAvg,
              color: const Color(0xFF43A047),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── 12-month bar chart ─────────────────────────────────────────
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: maxVal,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${monthNames[group.x]}\n'
                          '${formatter.format(rod.toY).toLocalizedDigits(localeCode)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
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
                    reservedSize: 44,
                    getTitlesWidget: (value, _) => Text(
                      formatter
                          .format(value)
                          .toLocalizedDigits(localeCode),
                      style: const TextStyle(
                        fontSize: 9,
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
                      if (i < 0 || i > 11) return const SizedBox.shrink();
                      final isCurrent = (i + 1) == currentMonthNum;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          monthNames[i],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isCurrent
                                ? AppTheme.primary
                                : AppTheme.onSurfaceVariant,
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

        // ── Monthly breakdown list ─────────────────────────────────────
        ...List.generate(12, (i) {
          final monthNum = i + 1;
          final spent = _yearlyTotals[monthNum] ?? 0.0;
          if (spent <= 0) return const SizedBox.shrink();
          final isCurrent = monthNum == currentMonthNum;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                // Month badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppTheme.primary.withOpacity(0.12)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    monthNames[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isCurrent
                          ? AppTheme.primary
                          : AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Progress bar
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: maxVal > 0
                          ? (spent / maxVal).clamp(0.0, 1.0)
                          : 0,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(
                        isCurrent
                            ? AppTheme.primary
                            : AppTheme.primary.withOpacity(0.45),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Amount
                Text(
                  formatter
                      .format(spent)
                      .toLocalizedDigits(localeCode),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                    isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isCurrent
                        ? AppTheme.primary
                        : AppTheme.onSurfaceVariant,
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

// ── Helper widgets ───────────────────────────────────────────────────────────

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
    final localeCode = Localizations.localeOf(context).languageCode;
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
              NumberFormat.decimalPattern(localeCode)
                  .format(amount)
                  .toLocalizedDigits(localeCode),
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
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}