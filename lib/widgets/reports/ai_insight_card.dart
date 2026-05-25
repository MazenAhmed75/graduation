// lib/widgets/reports/ai_insight_card.dart
//
// Shows the Gemini insight at the top of the Reports screen.
// Handles all three states: loading (skeleton), ready, error.

import 'package:flutter/material.dart';

import '../../models/insight_model.dart';
import '../../services/report_insight_service.dart';

class AiInsightCard extends StatelessWidget {
  const AiInsightCard({
    super.key,
    required this.service,
    required this.isArabic,
    required this.onRefresh,
  });

  final ReportInsightService service;
  final bool isArabic;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final state  = service.aiState;
    final colors = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: switch (state.status) {
        AiInsightStatus.loading => _SkeletonCard(isArabic: isArabic),
        AiInsightStatus.ready   => _ReadyCard(
          insight: state.insight!,
          isArabic: isArabic,
          onRefresh: onRefresh,
          colors: colors,
          tt: tt,
        ),
        AiInsightStatus.error   => _ErrorCard(
          isArabic: isArabic,
          onRetry: onRefresh,
        ),
        AiInsightStatus.idle    => const SizedBox.shrink(),
      },
    );
  }
}

// ── Ready card ────────────────────────────────────────────────────────────────

class _ReadyCard extends StatelessWidget {
  const _ReadyCard({
    required this.insight,
    required this.isArabic,
    required this.onRefresh,
    required this.colors,
    required this.tt,
  });

  final String insight;
  final bool isArabic;
  final VoidCallback onRefresh;
  final ColorScheme colors;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    final labelEn = 'AI Financial Insight';
    final labelAr = 'رؤية مالية ذكية';

    return Card(
      key: const ValueKey('ai_ready'),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.primary.withOpacity(0.25)),
      ),
      color: colors.primaryContainer.withOpacity(0.35),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          children: [
            // Sparkle icon
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: colors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Text block
            Expanded(
              child: Column(
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? labelAr : labelEn,
                    style: tt.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    insight,
                    style: tt.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      height: 1.45,
                    ),
                    textDirection: isArabic
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                  ),
                ],
              ),
            ),
            // Refresh button
            IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                size: 18,
                color: colors.onSurface.withOpacity(0.4),
              ),
              tooltip: isArabic ? 'تحديث' : 'Refresh',
              onPressed: onRefresh,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton / shimmer card ───────────────────────────────────────────────────

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard({required this.isArabic});
  final bool isArabic;

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final base  = colors.surfaceVariant;
        final glow  = colors.primary.withOpacity(0.08 + _anim.value * 0.08);
        return Card(
          key: const ValueKey('ai_loading'),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colors.primary.withOpacity(0.15)),
          ),
          color: Color.lerp(base, glow, _anim.value),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: widget.isArabic
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              children: [
                _bone(36, 36, radius: 10),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: widget.isArabic
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      _bone(80, 10),
                      const SizedBox(height: 10),
                      _bone(double.infinity, 13),
                      const SizedBox(height: 6),
                      _bone(160, 13),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bone(double w, double h, {double radius = 6}) => Container(
    width: w == double.infinity ? null : w,
    height: h,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

// ── Error card ────────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.isArabic, required this.onRetry});
  final bool isArabic;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      key: const ValueKey('ai_error'),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.error.withOpacity(0.3)),
      ),
      color: colors.errorContainer.withOpacity(0.25),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          textDirection:
          isArabic ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Icon(Icons.cloud_off_rounded,
                color: colors.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isArabic
                    ? 'تعذّر تحميل الرؤية الذكية.'
                    : 'Could not load AI insight.',
                style: TextStyle(color: colors.onErrorContainer),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}