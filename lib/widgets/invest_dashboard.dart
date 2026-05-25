// ignore_for_file: curly_braces_in_flow_control_structures, dead_code, unused_element, deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme.dart';
import '../Services/alpaca_service.dart';
import '../Services/gemini_service.dart';
import '../models/market_asset_model.dart';

class InvestDashboard extends StatefulWidget {
  final AlpacaAccount?               account;
  final List<AlpacaPosition>         positions;
  final List<MarketAssetModel>       liveAssets;
  final List<Map<String, dynamic>>   agentLog;
  final List<OpportunityCard>        opportunities;
  final bool                         scanningOpps;
  final bool                         autoTradeEnabled;
  final ValueChanged<bool>?          onToggleAutoTrade;
  final VoidCallback?                onScanOpportunities;
  final void Function(OpportunityCard)? onInvestOpportunity;

  const InvestDashboard({
    super.key,
    required this.account,
    required this.positions,
    required this.liveAssets,
    this.agentLog            = const [],
    this.opportunities       = const [],
    this.scanningOpps        = false,
    this.autoTradeEnabled    = false,
    this.onToggleAutoTrade,
    this.onScanOpportunities,
    this.onInvestOpportunity,
  });

  @override
  State<InvestDashboard> createState() => _InvestDashboardState();
}

class _InvestDashboardState extends State<InvestDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double>   _fade;
  String  _insight      = '';
  bool    _loadInsight  = false;
  int     _hoveredPie   = -1;
  List<FlSpot> _perfSpots = [];

  // ── colours ──────────────────────────────────────────────────────────────
  static const _pieColors = [
    Color(0xFF1B5E20), Color(0xFF0D47A1), Color(0xFF6A1B9A),
    Color(0xFFB8860B), Color(0xFFBF360C), Color(0xFF00695C),
  ];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
    _buildPerfChart();
    _fetchInsight();
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  void _buildPerfChart() {
    // Simulate equity curve from positions (fallback when no history API)
    final rng = Random(widget.positions.hashCode);
    final base = widget.account?.portfolioValue ?? 100000;
    _perfSpots = List.generate(30, (i) {
      final drift = (i / 30) * (widget.positions.fold(0.0, (s, p) => s + p.unrealizedPl));
      final noise = (rng.nextDouble() - 0.48) * base * 0.008;
      return FlSpot(i.toDouble(), base - drift + noise + drift * (i / 30));
    });
  }

  Future<void> _fetchInsight() async {
    setState(() => _loadInsight = true);
    final portfolio = widget.positions.isEmpty
        ? 'No positions yet.'
        : widget.positions.map((p) =>
            '${p.displayName}: \$${p.marketValue.toStringAsFixed(0)}, '
            '${p.isProfit ? '+' : ''}\$${p.unrealizedPl.toStringAsFixed(2)} P&L').join('; ');
    final text = await GeminiService().quickAsk(
      'Portfolio: $portfolio. Equity: \$${(_equity).toStringAsFixed(2)}. '
      'Give a 2-sentence portfolio assessment and one actionable recommendation. Be concise.',
      maxTokens: 200,
    );
    if (mounted) setState(() { _insight = text; _loadInsight = false; });
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  double get _totalPnl   => widget.positions.fold(0.0, (s,p) => s + p.unrealizedPl);
  double get _totalValue => widget.account?.portfolioValue ?? 0;
  double get _equity     => widget.account?.equity ?? 0;
  double get _cash       => widget.account?.cash ?? 0;
  double get _buyPower   => widget.account?.buyingPower ?? 0;

  // Approximate win-rate across positions
  double get _winRate {
    if (widget.positions.isEmpty) return 0;
    final wins = widget.positions.where((p) => p.isProfit).length;
    return wins / widget.positions.length * 100;
  }

  // Best / worst position
  AlpacaPosition? get _bestPos => widget.positions.isEmpty ? null
      : widget.positions.reduce((a, b) => a.unrealizedPl > b.unrealizedPl ? a : b);
  AlpacaPosition? get _worstPos => widget.positions.isEmpty ? null
      : widget.positions.reduce((a, b) => a.unrealizedPl < b.unrealizedPl ? a : b);

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: RefreshIndicator(
      onRefresh: () async { _buildPerfChart(); _fetchInsight(); },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          _heroCard(),
          const SizedBox(height: 16),
          _metricsRow(),
          const SizedBox(height: 16),
          // ── Auto-Trade Toggle ────────────────────────────────
          _autoTradeToggle(),
          const SizedBox(height: 16),
          // ── Opportunity Scanner ──────────────────────────────
          _scannerSection(),
          if (widget.positions.isNotEmpty) ...[
            const SizedBox(height: 16),
            _allocationCard(),
            const SizedBox(height: 16),
            _holdingsCard(),
          ],
          const SizedBox(height: 16),
          _agentActivityCard(),
        ],
      ),
    ),
  );

  // ── AUTO-TRADE TOGGLE ────────────────────────────────────────────────────
  Widget _autoTradeToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: widget.autoTradeEnabled 
            ? const Color(0xFF1B5E20).withOpacity(0.1)
            : AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.autoTradeEnabled 
              ? const Color(0xFF4CAF50).withOpacity(0.3)
              : AppTheme.outlineVariant.withOpacity(0.2),
        ),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.autoTradeEnabled 
                ? const Color(0xFF4CAF50).withOpacity(0.2)
                : AppTheme.surfaceContainerLow,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.smart_toy_rounded, size: 20,
              color: widget.autoTradeEnabled ? const Color(0xFF4CAF50) : AppTheme.onSurfaceVariant),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('AI Auto-Pilot Mode', style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.onSurface)),
            const SizedBox(height: 2),
            Text(widget.autoTradeEnabled 
                ? 'AI is actively managing your portfolio' 
                : 'Turn on for hourly portfolio optimization',
                style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
          ]),
        ),
        Switch(
          value: widget.autoTradeEnabled,
          onChanged: widget.onToggleAutoTrade,
          activeColor: const Color(0xFF4CAF50),
        ),
      ]),
    );
  }

  // ── OPPORTUNITY SCANNER SECTION ──────────────────────────────────────────
  Widget _scannerSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // Button
      GestureDetector(
        onTap: widget.scanningOpps ? null : widget.onScanOpportunities,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: widget.scanningOpps
                ? const LinearGradient(colors: [Color(0xFF1a1a2e), Color(0xFF16213e)])
                : const LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                    begin: Alignment.centerLeft, end: Alignment.centerRight),
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.scanningOpps ? [] : [
              BoxShadow(color: const Color(0xFF0D47A1).withOpacity(0.4),
                  blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (widget.scanningOpps) ...[
              const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white60)),
              const SizedBox(width: 12),
              const Text('AI scanning market...', style: TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14)),
            ] else ...[
              const Icon(Icons.radar_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              const Text('Find Opportunities', style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('AI POWERED', style: TextStyle(
                    color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
              ),
            ],
          ]),
        ),
      ),
      // Opportunity cards
      if (widget.opportunities.isNotEmpty) ...[
        const SizedBox(height: 12),
        ...widget.opportunities.map((opp) => _oppCard(opp)),
      ],
    ]);
  }

  Widget _oppCard(OpportunityCard opp) {
    final isBuy   = opp.signal == 'BUY';
    final color   = isBuy ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C);
    final bgGrad  = isBuy
        ? [const Color(0xFF1B5E20).withOpacity(0.08), const Color(0xFF2E7D32).withOpacity(0.04)]
        : [const Color(0xFFB71C1C).withOpacity(0.08), const Color(0xFFD32F2F).withOpacity(0.04)];
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: bgGrad, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
            child: Text(opp.signal, style: const TextStyle(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const SizedBox(width: 10),
          Text(opp.assetName, style: TextStyle(fontWeight: FontWeight.bold,
              fontSize: 15, color: color)),
          const Spacer(),
          Text(opp.timeHorizon, style: const TextStyle(
              fontSize: 11, color: AppTheme.onSurfaceVariant)),
        ]),
        const SizedBox(height: 8),
        Text(opp.reason, style: const TextStyle(
            fontSize: 13, color: AppTheme.onSurface, height: 1.4)),
        const SizedBox(height: 12),
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Suggested', style: TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant)),
            Text('\$${opp.suggestedUsd.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ]),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => widget.onInvestOpportunity?.call(opp),
            icon: const Icon(Icons.bolt_rounded, size: 16),
            label: const Text('Invest Now', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: color, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ]),
      ]),
    );
  }

  // ── HERO CARD ─────────────────────────────────────────────────────────────
  Widget _heroCard() {
    final isUp = _totalPnl >= 0;
    final pnlPct = _equity > 0 ? (_totalPnl / (_equity - _totalPnl).abs()) * 100 : 0.0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1628), Color(0xFF0D2137)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4),
            blurRadius: 30, offset: const Offset(0, 12))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('PORTFOLIO VALUE',
              style: TextStyle(color: Colors.white38, fontSize: 11,
                  fontWeight: FontWeight.bold, letterSpacing: 1.8)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AlpacaService().isConfigured
                  ? const Color(0xFF1B5E20).withOpacity(0.5)
                  : Colors.white10,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AlpacaService().isConfigured
                  ? const Color(0xFF4CAF50) : Colors.white24, width: 0.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AlpacaService().isConfigured
                    ? const Color(0xFF4CAF50) : Colors.white38)),
              const SizedBox(width: 6),
              Text(AlpacaService().isConfigured ? 'LIVE' : 'PAPER',
                  style: const TextStyle(color: Colors.white70, fontSize: 10,
                      fontWeight: FontWeight.bold, letterSpacing: 1)),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Text('\$${_fmt(_totalValue)}',
            style: const TextStyle(color: Colors.white, fontSize: 42,
                fontWeight: FontWeight.w800, letterSpacing: -1.5)),
        const SizedBox(height: 8),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (isUp ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C))
                  .withOpacity(0.35),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isUp ? const Color(0xFF69F0AE) : const Color(0xFFFF5252), size: 13),
              const SizedBox(width: 4),
              Text('${isUp ? '+' : ''}\$${_fmt2(_totalPnl)}  '
                  '(${isUp ? '+' : ''}${pnlPct.toStringAsFixed(2)}%)',
                  style: TextStyle(
                      color: isUp ? const Color(0xFF69F0AE) : const Color(0xFFFF5252),
                      fontWeight: FontWeight.bold, fontSize: 13)),
            ]),
          ),
          const SizedBox(width: 8),
          const Text('Unrealized P&L',
              style: TextStyle(color: Colors.white38, fontSize: 12)),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          _heroChip('Equity',      '\$${_fmt(_equity)}'),
          const SizedBox(width: 8),
          _heroChip('Cash',        '\$${_fmt(_cash)}'),
          const SizedBox(width: 8),
          _heroChip('Buying Power','\$${_fmt(_buyPower)}'),
        ]),
      ]),
    );
  }

  Widget _heroChip(String label, String value) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9,
            fontWeight: FontWeight.bold, letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white,
            fontWeight: FontWeight.bold, fontSize: 13)),
      ]),
    ),
  );

  // ── METRICS ROW ───────────────────────────────────────────────────────────
  Widget _metricsRow() => Row(children: [
    _metricCard('Win Rate', '${_winRate.toStringAsFixed(0)}%',
        Icons.track_changes_outlined,
        _winRate >= 50 ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C)),
    const SizedBox(width: 10),
    _metricCard('Positions', '${widget.positions.length}',
        Icons.pie_chart_outline, const Color(0xFF0D47A1)),
    const SizedBox(width: 10),
    _metricCard('Best',
        _bestPos != null ? '+\$${_fmt2(_bestPos!.unrealizedPl)}' : '—',
        Icons.trending_up, const Color(0xFF1B5E20)),
    const SizedBox(width: 10),
    _metricCard('Worst',
        _worstPos != null ? '\$${_fmt2(_worstPos!.unrealizedPl)}' : '—',
        Icons.trending_down, const Color(0xFFB71C1C)),
  ]);

  Widget _metricCard(String label, String value, IconData icon, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold,
            fontSize: 15, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppTheme.onSurfaceVariant,
            fontSize: 10, fontWeight: FontWeight.w500)),
      ]),
    ),
  );

  // ── PERFORMANCE CHART ─────────────────────────────────────────────────────
  Widget _perfCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppTheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.15)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Portfolio Performance',
            style: TextStyle(fontWeight: FontWeight.bold,
                fontSize: 15, color: AppTheme.onSurface)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8)),
          child: const Text('30D', style: TextStyle(fontSize: 11,
              fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
        ),
      ]),
      const SizedBox(height: 16),
      SizedBox(height: 140, child: _perfSpots.isEmpty
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : LineChart(LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (_perfSpots.map((s) => s.y).reduce(max) -
                    _perfSpots.map((s) => s.y).reduce(min)) / 4,
                getDrawingHorizontalLine: (_) => FlLine(
                    color: AppTheme.outlineVariant.withOpacity(0.1), strokeWidth: 1),
              ),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots.map((s) =>
                    LineTooltipItem('\$${_fmt(s.y)}',
                      const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold, fontSize: 12))).toList(),
                ),
              ),
              lineBarsData: [LineChartBarData(
                spots: _perfSpots,
                isCurved: true, curveSmoothness: 0.3,
                color: AppTheme.primary, barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true,
                    gradient: LinearGradient(
                      colors: [AppTheme.primary.withOpacity(0.2),
                               AppTheme.primary.withOpacity(0.0)],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              )],
            ))),
    ]),
  );

  // ── ALLOCATION PIE ────────────────────────────────────────────────────────
  Widget _allocationCard() {
    final total = widget.positions.fold(0.0, (s,p) => s + p.marketValue.abs());
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Allocation', style: TextStyle(fontWeight: FontWeight.bold,
            fontSize: 15, color: AppTheme.onSurface)),
        const SizedBox(height: 16),
        Row(children: [
          SizedBox(width: 160, height: 160,
            child: PieChart(PieChartData(
              sections: widget.positions.asMap().entries.map((e) {
                final pct = total > 0 ? e.value.marketValue.abs() / total * 100 : 0.0;
                final hov = _hoveredPie == e.key;
                return PieChartSectionData(
                  value: e.value.marketValue.abs(),
                  title: '${pct.toStringAsFixed(1)}%',
                  color: _pieColors[e.key % _pieColors.length],
                  radius: hov ? 72 : 60,
                  titleStyle: const TextStyle(color: Colors.white,
                      fontSize: 11, fontWeight: FontWeight.bold),
                );
              }).toList(),
              pieTouchData: PieTouchData(touchCallback: (_, r) => setState(() =>
                  _hoveredPie = r?.touchedSection?.touchedSectionIndex ?? -1)),
              sectionsSpace: 2,
              centerSpaceRadius: 36,
            )),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            children: widget.positions.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(
                    color: _pieColors[e.key % _pieColors.length],
                    borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 8),
                Expanded(child: Text(e.value.displayName,
                    style: const TextStyle(fontSize: 12, color: AppTheme.onSurface),
                    overflow: TextOverflow.ellipsis)),
                Text('${total > 0 ? (e.value.marketValue.abs()/total*100).toStringAsFixed(1) : 0}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface)),
              ]),
            )).toList(),
          )),
        ]),
      ]),
    );
  }

  // ── HOLDINGS TABLE ────────────────────────────────────────────────────────
  Widget _holdingsCard() => Container(
    decoration: BoxDecoration(
      color: AppTheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.15)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Text('Holdings', style: TextStyle(fontWeight: FontWeight.bold,
            fontSize: 15, color: AppTheme.onSurface)),
      ),
      const SizedBox(height: 8),
      // Header
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(children: const [
          Expanded(flex: 3, child: Text('ASSET', style: _hdrStyle)),
          Expanded(flex: 2, child: Text('MKT VALUE', style: _hdrStyle, textAlign: TextAlign.right)),
          Expanded(flex: 2, child: Text('P&L', style: _hdrStyle, textAlign: TextAlign.right)),
          Expanded(flex: 2, child: Text('RETURN', style: _hdrStyle, textAlign: TextAlign.right)),
        ]),
      ),
      const Divider(height: 1, color: Colors.black12),
      ...widget.positions.map((p) => _holdingRow(p)),
    ]),
  );

  static const _hdrStyle = TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
      color: AppTheme.onSurfaceVariant, letterSpacing: 0.8);

  Widget _holdingRow(AlpacaPosition p) {
    final pct = p.unrealizedPlpc * 100;
    final isUp = p.isProfit;
    final pnlColor = isUp ? const Color(0xFF2E7D32) : const Color(0xFFB71C1C);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5))),
      child: Row(children: [
        Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.symbol, style: const TextStyle(fontWeight: FontWeight.bold,
              fontSize: 14, color: AppTheme.onSurface)),
          Text('${p.qty.toStringAsFixed(4)} units  ·  avg \$${p.avgEntryPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant)),
        ])),
        Expanded(flex: 2, child: Text('\$${_fmt(p.marketValue)}',
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600,
                fontSize: 14, color: AppTheme.onSurface))),
        Expanded(flex: 2, child: Text('${isUp ? '+' : ''}\$${_fmt2(p.unrealizedPl)}',
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: pnlColor))),
        Expanded(flex: 2, child: Container(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: pnlColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6)),
            child: Text('${isUp ? '+' : ''}${pct.toStringAsFixed(2)}%',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: pnlColor)),
          ),
        )),
      ]),
    );
  }

  // ── AI INSIGHT ────────────────────────────────────────────────────────────
  Widget _insightCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppTheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.primaryContainer),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.primaryContainer,
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.psychology_outlined, size: 18, color: AppTheme.primary)),
        const SizedBox(width: 10),
        const Text('AI Advisor Insight', style: TextStyle(fontWeight: FontWeight.bold,
            fontSize: 15, color: AppTheme.primary)),
        const Spacer(),
        GestureDetector(onTap: _fetchInsight, child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.refresh_rounded, size: 16, color: AppTheme.primary),
        )),
      ]),
      const SizedBox(height: 14),
      if (_loadInsight)
        const Row(children: [
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 10),
          Text('Analyzing portfolio...', style: TextStyle(color: AppTheme.onSurfaceVariant)),
        ])
      else if (_insight.isEmpty)
        const Text('Connect Alpaca and tap refresh for AI analysis.',
            style: TextStyle(color: AppTheme.onSurfaceVariant))
      else
        Text(_insight, style: const TextStyle(color: AppTheme.onSurface, height: 1.6, fontSize: 14)),
    ]),
  );

  // ── formatters ────────────────────────────────────────────────────────────
  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(2)}M';
    if (v >= 1000)    return v.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return v.toStringAsFixed(2);
  }
  String _fmt2(double v) => v.abs() >= 1000
      ? v.abs().toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')
      : v.abs().toStringAsFixed(2);

  // ── AGENT ACTIVITY FEED ───────────────────────────────────────────────────
  Widget _agentActivityCard() {
    final isRunning = widget.agentLog.isNotEmpty ||
        true; // always show so user knows agent is active
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Row(children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRunning ? const Color(0xFF4CAF50) : Colors.grey,
                boxShadow: isRunning ? [BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.4),
                  blurRadius: 6, spreadRadius: 2)] : null,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Autonomous Agent',
                style: TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 15, color: AppTheme.onSurface)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('AUTO-TRADING',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50), letterSpacing: 1)),
            ),
          ]),
        ),
        const Divider(height: 1, color: Colors.black12),
        if (widget.agentLog.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(children: [
              SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2,
                      color: AppTheme.primary)),
              SizedBox(width: 12),
              Text('Agent is running due-diligence pipeline...',
                  style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13)),
            ]),
          )
        else
          ...widget.agentLog.take(8).map((entry) {
            final type  = entry['type'] as String? ?? 'status';
            final msg   = entry['msg'] as String? ?? '';
            final time  = entry['time'] as DateTime? ?? DateTime.now();
            final Color dotColor = type == 'trade'
                ? const Color(0xFF4CAF50)
                : type == 'error'
                    ? const Color(0xFFE53935)
                    : AppTheme.onSurfaceVariant.withOpacity(0.5);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Container(width: 6, height: 6,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(msg, style: TextStyle(fontSize: 12,
                      color: type == 'trade'
                          ? const Color(0xFF2E7D32)
                          : type == 'error'
                              ? const Color(0xFFE53935)
                              : AppTheme.onSurface,
                      fontWeight: type == 'trade'
                          ? FontWeight.bold : FontWeight.normal)),
                  const SizedBox(height: 2),
                  Text('${time.hour.toString().padLeft(2,'0')}:'
                      '${time.minute.toString().padLeft(2,'0')}:'
                      '${time.second.toString().padLeft(2,'0')}',
                      style: const TextStyle(fontSize: 10,
                          color: AppTheme.onSurfaceVariant)),
                ])),
              ]),
            );
          }),
      ]),
    );
  }
}
