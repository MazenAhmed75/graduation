// lib/widgets/reports/local_insights_section.dart
//
// Displays the rule-based insight chips/cards — always visible,
// rendered synchronously, no API calls.

import 'package:flutter/material.dart';

import '../../models/insight_model.dart';

class LocalInsightsSection extends StatelessWidget {
  const LocalInsightsSection({
    super.key,
    required this.insights,
    required this.isArabic,
  });

  final List<LocalInsight> insights;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();

    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            isArabic ? 'ملاحظات فورية' : 'Quick Insights',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            textDirection:
            isArabic ? TextDirection.rtl : TextDirection.ltr,
          ),
        ),
        ...insights.map(
              (insight) => _InsightTile(
            insight: insight,
            isArabic: isArabic,
          ),
        ),
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.insight, required this.isArabic});

  final LocalInsight insight;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final colors  = Theme.of(context).colorScheme;
    final tt      = Theme.of(context).textTheme;
    final config  = _insightConfig(insight.type, colors);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: config.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: config.border, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            textDirection:
            isArabic ? TextDirection.rtl : TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(config.icon, color: config.iconColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  insight.localizedMessage(isArabic),
                  style: tt.bodySmall?.copyWith(
                    color: colors.onSurface,
                    height: 1.4,
                  ),
                  textDirection: isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _TileConfig _insightConfig(InsightType type, ColorScheme c) {
    return switch (type) {
      InsightType.overBudget => _TileConfig(
        icon: Icons.warning_amber_rounded,
        iconColor: c.error,
        bg: c.errorContainer.withOpacity(0.3),
        border: c.error.withOpacity(0.3),
      ),
      InsightType.warning => _TileConfig(
        icon: Icons.trending_up_rounded,
        iconColor: Colors.orange.shade700,
        bg: Colors.orange.shade50,
        border: Colors.orange.shade200,
      ),
      InsightType.highestSpending => _TileConfig(
        icon: Icons.bar_chart_rounded,
        iconColor: c.primary,
        bg: c.primaryContainer.withOpacity(0.3),
        border: c.primary.withOpacity(0.25),
      ),
      InsightType.underUtilized => _TileConfig(
        icon: Icons.savings_rounded,
        iconColor: Colors.teal.shade600,
        bg: Colors.teal.shade50,
        border: Colors.teal.shade200,
      ),
      InsightType.greatProgress => _TileConfig(
        icon: Icons.check_circle_outline_rounded,
        iconColor: Colors.green.shade600,
        bg: Colors.green.shade50,
        border: Colors.green.shade200,
      ),
      InsightType.tip => _TileConfig(
        icon: Icons.lightbulb_outline_rounded,
        iconColor: Colors.amber.shade700,
        bg: Colors.amber.shade50,
        border: Colors.amber.shade200,
      ),
    };
  }
}

class _TileConfig {
  final IconData icon;
  final Color iconColor;
  final Color bg;
  final Color border;
  const _TileConfig({
    required this.icon,
    required this.iconColor,
    required this.bg,
    required this.border,
  });
}