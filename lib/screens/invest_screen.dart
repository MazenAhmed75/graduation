// ignore_for_file: curly_braces_in_flow_control_structures, unused_field, deprecated_member_use, unused_element, unused_local_variable, unused_shown_name

import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/market_asset_model.dart';
import '../models/budget_model.dart';
import '../models/user_model.dart';
import '../Services/market_service.dart';
import '../Services/gemini_service.dart';
import '../Services/auth_service.dart';
import '../Services/user_service.dart';
import '../Services/budget_service.dart';
import '../Services/news_service.dart';
import '../Services/alpaca_service.dart';
import '../Services/autonomous_agent_service.dart';
import '../widgets/invest_widgets.dart';
import '../widgets/invest_dashboard.dart';
import '../Services/gemini_service.dart' show ChatMessage, AgentAction, OpportunityCard, GeminiService;
import 'alpaca_settings_screen.dart';
import 'package:mindful_curator/l10n/app_localizations.dart';

class InvestScreen extends StatefulWidget {
  const InvestScreen({super.key});

  @override
  State<InvestScreen> createState() => _InvestScreenState();
}

class _InvestScreenState extends State<InvestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  final _marketSvc = MarketService();
  final _geminiSvc = GeminiService();
  final _authSvc   = AuthService();
  final _userSvc   = UserService();
  final _budgetSvc = BudgetService();
  final _newsSvc   = NewsService();
  final _alpacaSvc = AlpacaService();

  final _chatController  = TextEditingController();
  final _scrollController = ScrollController();

  List<MarketAssetModel> _assets    = [];
  List<NewsHeadline>     _news      = [];
  AlpacaAccount?         _account;
  List<AlpacaPosition>   _positions = [];

  bool _loadingMarkets = true;
  bool _loadingAlpaca  = true;
  bool _agentThinking  = false;
  bool _sessionStarted = false;
  bool _scanningOpps   = false;
  Timer? _priceTimer;
  Timer? _alpacaTimer;
  DateTime? _lastPriceUpdate;

  // Autonomous agent activity log
  final List<Map<String, dynamic>> _agentLog = [];
  // AI-scanned opportunities shown on Dashboard
  List<OpportunityCard> _opportunities = [];
  // Auto-trade toggle
  bool _autoTradeEnabled = false;


  String get _uid => _authSvc.currentUser!.uid;
  String get _monthId {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _loadAll();
    // Auto-refresh prices every 30 seconds
    _priceTimer = Timer.periodic(const Duration(seconds: 30), (_) => _silentPriceRefresh());
    // Auto-refresh Alpaca P&L every 30 seconds
    _alpacaTimer = Timer.periodic(const Duration(seconds: 30), (_) => _silentAlpacaRefresh());
  }

  @override
  void dispose() {
    _priceTimer?.cancel();
    _alpacaTimer?.cancel();
    AutonomousAgentService().disable();
    _tabs.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Silent background price refresh — no loading spinner
  Future<void> _silentPriceRefresh() async {
    try {
      final assets = await _marketSvc.fetchAllPrices();
      if (mounted) setState(() { _assets = assets; _lastPriceUpdate = DateTime.now(); });
    } catch (_) {}
  }

  /// Silent Alpaca P&L refresh — updates positions and account in background
  Future<void> _silentAlpacaRefresh() async {
    if (!_alpacaSvc.isConfigured) return;
    try {
      final results = await Future.wait([
        _alpacaSvc.getAccount(),
        _alpacaSvc.getPositions(),
      ]);
      if (mounted) setState(() {
        _account   = results[0] as AlpacaAccount?;
        _positions = results[1] as List<AlpacaPosition>;
      });
    } catch (_) {}
  }

  // ── Auto-trade toggle ─────────────────────────────────────────────────────

  void _toggleAutoTrade(bool enabled) {
    setState(() => _autoTradeEnabled = enabled);
    if (enabled) {
      _enableAutoTrade();
    } else {
      AutonomousAgentService().disable();
      _logAgent(
        '⏸ ${AppLocalizations.of(context).autoTradeDisabled}',
        type: 'status',
      );
    }
  }

  void _enableAutoTrade() {
    if (!_alpacaSvc.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).connectAlpacaFirst)));
      setState(() => _autoTradeEnabled = false);
      return;
    }
    _logAgent(
      '🤖 ${AppLocalizations.of(context).autoTradeEnabled}',
      type: 'status',
    );

    AutonomousAgentService().enable(
      cycleInterval: const Duration(hours: 1),
      onLog: (msg, {bool isError = false, bool isTrade = false}) {
        if (mounted) _logAgent(msg,
            type: isError ? 'error' : isTrade ? 'trade' : 'status');
      },
      // Auto-sell: agent closes positions autonomously
      onAutoSell: (symbol) async {
        final result = await _alpacaSvc.closePosition(symbol);
        if (mounted) {
          _logAgent(
            result.success
                ? '✅ ${AppLocalizations.of(context).autoSold(symbol)}'
                : '❌ ${AppLocalizations.of(context).autoSellFailed(result.error ?? "")}',
            type: result.success ? 'trade' : 'error',
          );
          await _silentAlpacaRefresh();
          await Future.delayed(const Duration(seconds: 3));
          if (mounted) await _silentAlpacaRefresh();
        }
      },
      // Buy opportunities: shown to user for approval (NOT auto-executed)
      onBuyOpps: (opps) {
        if (!mounted) return;
        setState(() {
          _opportunities = opps.map((o) => OpportunityCard(
            assetId:      o.assetId,
            assetName:    o.assetName,
            signal:       'BUY',
            reason:       o.reasoning,
            suggestedUsd: o.suggestedUsd,
            timeHorizon:  o.timeHorizon,
          )).toList();
        });
        // Jump user to Dashboard to see opportunities
        _tabs.animateTo(0);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: const Color(0xFF0D47A1),
          content: Text(
            '🤖 ${AppLocalizations.of(context).aiFoundOpportunities(opps.length)}',
          ),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
              label: AppLocalizations.of(context).view, textColor: Colors.white,
              onPressed: () => _tabs.animateTo(0)),
        ));
      },
    );
  }

  void _logAgent(String msg, {String type = 'status'}) {
    if (!mounted) return;
    setState(() {
      _agentLog.insert(0, {'time': DateTime.now(), 'msg': msg, 'type': type});
      if (_agentLog.length > 100) _agentLog.removeLast();
    });
  }


  Future<void> _loadAll() async {
    await Future.wait([_loadMarkets(), _loadAlpaca()]);
  }

  Future<void> _loadMarkets() async {
    setState(() => _loadingMarkets = true);
    try {
      final results = await Future.wait([
        _marketSvc.fetchAllPrices(),
        _newsSvc.fetchFinancialNews(),
      ]);
      setState(() {
        _assets         = results[0] as List<MarketAssetModel>;
        _news           = results[1] as List<NewsHeadline>;
        _loadingMarkets = false;
      });
    } catch (_) {
      setState(() => _loadingMarkets = false);
    }
  }

  Future<void> _loadAlpaca() async {
    setState(() => _loadingAlpaca = true);
    if (_alpacaSvc.isConfigured) {
      final results = await Future.wait([
        _alpacaSvc.getAccount(),
        _alpacaSvc.getPositions(),
      ]);
      setState(() {
        _account    = results[0] as AlpacaAccount?;
        _positions  = results[1] as List<AlpacaPosition>;
        _loadingAlpaca = false;
      });
      // Enable auto-trade if user left it enabled
      if (_autoTradeEnabled) {
        _enableAutoTrade();
      }
    } else {
      setState(() => _loadingAlpaca = false);
    }
  }

  /// AI scans live market → returns opportunity cards shown in Dashboard
  Future<void> _scanOpportunities() async {
    if (_scanningOpps) return;
    setState(() { _scanningOpps = true; _opportunities = []; });
    try {
      final prompt = _geminiSvc.buildOpportunityScanPrompt(
          assets: _assets, positions: _positions, cash: _account?.cash ?? 0);
      final raw  = await _geminiSvc.quickAsk(prompt, maxTokens: 1200);
      final opps = _geminiSvc.parseOpportunitiesFromRaw(raw);
      if (mounted) setState(() => _opportunities = opps);
    } catch (_) {} finally {
      if (mounted) setState(() => _scanningOpps = false);
    }
  }

  /// Execute buy from Dashboard opportunity card directly via Alpaca
  Future<void> _executeDashboardTrade(OpportunityCard opp) async {
    if (!_alpacaSvc.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).connectAlpacaFirst),
          ));
      return;
    }
    final symbol = AlpacaSymbols.getSymbolForAsset(opp.assetId);
    if (symbol == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)
                  .notOnAlpacaYet(opp.assetName),
            ),
          ));
      return;
    }
    final result = await _alpacaSvc.buyMarket(
        symbol: symbol, notional: opp.suggestedUsd);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: result.success
          ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
      content: Text(result.success
          ? '✅ Bought \$${opp.suggestedUsd.toStringAsFixed(0)} of ${opp.assetName}'
          : '❌ ${result.error}'),
      duration: const Duration(seconds: 5),
    ));
    if (result.success) {
      setState(() => _opportunities.remove(opp));
      await _silentAlpacaRefresh();
    }
  }

  Future<void> _initAgent(UserModel user, List<BudgetModel> budgets) async {
    if (_sessionStarted) return;
    _sessionStarted = true;

    // Build portfolio summary from Alpaca positions for AI context
    final portfolioText = _positions.isEmpty
        ? 'No positions'
        : _positions.map((p) =>
            '${p.displayName}: ${p.qty.toStringAsFixed(4)} units, '
            'value \$${p.marketValue.toStringAsFixed(2)}, '
            'P&L ${p.isProfit ? '+' : ''}\$${p.unrealizedPl.toStringAsFixed(2)}')
            .join(', ');

    _geminiSvc.startNewSession(
      user: user, budgets: budgets,
      liveAssets: _assets, portfolio: [],
      fundBalance: _account?.cash ?? 0,
      newsHeadlines: _news,
    );
    setState(() {});
  }

  Future<void> _sendChat(String text) async {
    if (text.trim().isEmpty) return;
    _chatController.clear();
    setState(() => _agentThinking = true);

    final reply = await _geminiSvc.sendMessage(text);
    setState(() => _agentThinking = false);

    if (reply.action != null && reply.action!.type != 'none') {
      await _confirmAndTrade(reply.action!);
    }
    _scrollToBottom();
  }

  Future<void> _confirmAndTrade(AgentAction action) async {
    final asset = _assets.firstWhere(
        (a) => a.id == action.assetId,
        orElse: () => _assets.first);
    final alpacaSymbol = AlpacaSymbols.getSymbol(action.assetId);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(children: [
          Icon(
            action.type == 'buy' ? Icons.shopping_cart_outlined : Icons.sell_outlined,
            size: 26, color: AppTheme.primary,
          ),
          const SizedBox(width: 8),
          Text(action.type == 'buy' ? 'Confirm Buy' : 'Confirm Sell',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(action.type == 'buy'
                  ? '🛒 Buy \$${action.usdAmount.toStringAsFixed(2)} of ${asset.name}'
                  : '💰 Sell ${(action.sellFraction * 100).toStringAsFixed(0)}% of ${asset.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold,
                      color: AppTheme.primary, fontSize: 15)),
              const SizedBox(height: 4),
              Text('${asset.displayPrice} current price',
                  style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
              if (alpacaSymbol != null)
                Text('Alpaca symbol: $alpacaSymbol',
                    style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12)),
            child: Text('🤖 ${action.reasoning}',
                style: const TextStyle(fontSize: 13, color: AppTheme.onSurface, height: 1.4)),
          ),
          const SizedBox(height: 10),
          Text(
            _alpacaSvc.isConfigured
                ? '⚠️ This will place a REAL order on Alpaca.'
                : '📄 Paper trade — no real money moves.',
            style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant,
                fontStyle: FontStyle.italic),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () => Navigator.pop(context, true),
            child: Text(action.type == 'buy' ? 'Execute Buy ✓' : 'Execute Sell ✓'),
          ),
        ],
      ),
    );

    if (confirmed != true || alpacaSymbol == null) return;

    AlpacaOrderResult result;
    if (action.type == 'buy') {
      result = await _alpacaSvc.buyMarket(
          symbol: alpacaSymbol, notional: action.usdAmount);
    } else {
      // Use closePosition (DELETE) for full closes, sellFraction for partials
      if (action.sellFraction >= 0.99) {
        result = await _alpacaSvc.closePosition(alpacaSymbol);
      } else {
        final pos = _positions.firstWhere(
            (p) => p.symbol == alpacaSymbol,
            orElse: () => AlpacaPosition(
              symbol: alpacaSymbol, qty: 0, avgEntryPrice: 0,
              currentPrice: 0, marketValue: 0, unrealizedPl: 0, unrealizedPlpc: 0,
            ));
        result = await _alpacaSvc.sellFraction(
            symbol: alpacaSymbol, fraction: action.sellFraction, currentQty: pos.qty);
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: result.success ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
      content: Text(
        result.success
            ? '✅ ${action.type == 'buy' ? 'Bought' : 'Sold'} — order submitted to Alpaca'
            : '❌ ${result.error}',
        style: const TextStyle(color: Colors.white),
      ),
      duration: const Duration(seconds: 5),
    ));

    if (result.success) {
      // Immediate refresh, then again after 3s for Alpaca to settle
      await _silentAlpacaRefresh();
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) await _silentAlpacaRefresh();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _userSvc.getUserStream(_uid),
      builder: (ctx, userSnap) {
        final user = userSnap.data;
        return StreamBuilder<List<BudgetModel>>(
          stream: _budgetSvc.getCategoryBudgetsStream(_uid, _monthId),
          builder: (ctx, budgetSnap) {
            final budgets = budgetSnap.data ?? [];

            if (user != null && !_sessionStarted && _assets.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) =>
                  _initAgent(user, budgets));
            }

            return Scaffold(
              backgroundColor: AppTheme.neutral,
              appBar: _buildAppBar(),
              body: Column(children: [
                _buildTabBar(),
                Expanded(child: TabBarView(
                  controller: _tabs,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Tab 0 — Dashboard with opportunity scanner
                    _loadingAlpaca
                        ? const Center(child: CircularProgressIndicator())
                        : _alpacaSvc.isConfigured
                            ? InvestDashboard(
                                account: _account,
                                positions: _positions,
                                liveAssets: _assets,
                                agentLog: _agentLog,
                                opportunities: _opportunities,
                                scanningOpps: _scanningOpps,
                                autoTradeEnabled: _autoTradeEnabled,
                                onToggleAutoTrade: _toggleAutoTrade,
                                onScanOpportunities: _scanOpportunities,
                                onInvestOpportunity: (opp) => _executeDashboardTrade(opp),
                              )
                            : _buildConnectPrompt(),

                    // Tab 1 — Markets (prices only)
                    _buildMarketsTab(),

                    // Tab 2 — AI Advisor
                    _buildChatTab(user),

                    // Tab 3 — Live Positions
                    _buildPositionsTab(),
                  ],
                )),
              ]),
            );
          },
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.neutral,
      elevation: 0,
      titleSpacing: 20,
      title: Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.show_chart_rounded, size: 18, color: AppTheme.primary),
        ),
        const SizedBox(width: 10),
        Text(AppLocalizations.of(context).aiInvest,
            style: TextStyle(fontFamily: 'Manrope', fontSize: 22,
                fontWeight: FontWeight.w800, color: AppTheme.primary)),
        const SizedBox(width: 8),
        if (_alpacaSvc.isConfigured)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(AppLocalizations.of(context).live, style: TextStyle(color: Color(0xFF2E7D32),
                fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ),
      ]),
      actions: [
        IconButton(
          tooltip: AppLocalizations.of(context).connectAlpaca,
          icon: Icon(
            _alpacaSvc.isConfigured
                ? Icons.link_rounded
                : Icons.link_off_rounded,
            color: _alpacaSvc.isConfigured ? AppTheme.primary : AppTheme.outlineVariant,
          ),
          onPressed: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AlpacaSettingsScreen()));
            _loadAlpaca();
          },
        ),
        IconButton(
          tooltip: AppLocalizations.of(context).refresh,
          icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary),
          onPressed: _loadAll,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabs,
        indicator: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.onSurfaceVariant,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tabs:[
          Tab(icon: Icon(Icons.dashboard_rounded, size: 16), text: AppLocalizations.of(context).dashboard),
          Tab(icon: Icon(Icons.bar_chart_rounded,  size: 16), text: AppLocalizations.of(context).markets),
          Tab(icon: Icon(Icons.smart_toy_rounded,  size: 16), text: AppLocalizations.of(context).aiAdvisor),
          Tab(icon: Icon(Icons.pie_chart_rounded,  size: 16), text: AppLocalizations.of(context).positions),
        ],
      ),
    );
  }

  // ── CONNECT PROMPT ────────────────────────────────────────────────────────

  Widget _buildConnectPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Center(child: Text('🔗', style: TextStyle(fontSize: 42))),
          ),
          const SizedBox(height: 24),
          Text(AppLocalizations.of(context).connectAlpacaAccount,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface)),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).alpacaIntro,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.onSurfaceVariant, height: 1.6, fontSize: 14),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AlpacaSettingsScreen()));
              _loadAlpaca();
            },
            icon: const Icon(Icons.link_rounded),
             label: Text(AppLocalizations.of(context).connectAlpaca, style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _tabs.animateTo(2),
            child: Text(AppLocalizations.of(context).chatWithAi,
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
    );
  }

  // ── MARKETS TAB (prices only) ─────────────────────────────────────────────

  Widget _buildMarketsTab() {
    if (_loadingMarkets) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // Live indicator + last updated
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),

            Text(
              AppLocalizations.of(context).livePrices,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.onSurface,
              ),
            ),

            const Spacer(),

            if (_lastPriceUpdate != null)
              Text(
                '${AppLocalizations.of(context).updated} '
                    '${_lastPriceUpdate!.hour.toString().padLeft(2, '0')}:'
                    '${_lastPriceUpdate!.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _sectionLabel(AppLocalizations.of(context).metals),
        const SizedBox(height: 8),
        ..._assets.where((a) => a.category == 'metal').map((a) =>
            Padding(padding: const EdgeInsets.only(bottom: 10),
                child: AssetPriceCard(asset: a))),
        const SizedBox(height: 20),
        _sectionLabel(AppLocalizations.of(context).crypto),
        const SizedBox(height: 8),
        ..._assets.where((a) => a.category == 'crypto').map((a) =>
            Padding(padding: const EdgeInsets.only(bottom: 10),
                child: AssetPriceCard(asset: a))),
        const SizedBox(height: 20),
        _sectionLabel(AppLocalizations.of(context).usStocks),
        const SizedBox(height: 8),
        ..._assets.where((a) => a.category == 'stock').map((a) =>
            Padding(padding: const EdgeInsets.only(bottom: 10),
                child: AssetPriceCard(asset: a))),
      ],
    );
  }

  Widget _newsCard(NewsHeadline h) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.2)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(
          h.sentiment == NewsSentiment.bullish
              ? Icons.trending_up
              : h.sentiment == NewsSentiment.bearish
                  ? Icons.trending_down
                  : Icons.trending_flat,
          size: 18,
          color: h.sentiment == NewsSentiment.bullish
              ? const Color(0xFF2E7D32)
              : h.sentiment == NewsSentiment.bearish
                  ? const Color(0xFFB71C1C)
                  : AppTheme.onSurfaceVariant,
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(h.title, style: const TextStyle(fontSize: 13,
              fontWeight: FontWeight.w500, color: AppTheme.onSurface)),
          const SizedBox(height: 2),
          Text(h.source, style: const TextStyle(fontSize: 11,
              color: AppTheme.onSurfaceVariant)),
        ])),
      ]),
    ),
  );

  Widget _infoBox(String text) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12)),
    child: Text(text, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13)),
  );

  // ── AI CHAT TAB ───────────────────────────────────────────────────────────

  Widget _buildChatTab(UserModel? user) {
    final msgs = _geminiSvc.messages;
    return Column(children: [
      SizedBox(
        height: 52,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _chip(AppLocalizations.of(context).showOpportunities, () =>
                _sendChat('Show me the best investment opportunities right now. Give me 3-5 specific picks with the opportunities JSON block.')),
            const SizedBox(width: 8),
            _chip(AppLocalizations.of(context).investBestPick, () =>
                _sendChat('Analyze the market and invest 200 dollars in the single best opportunity you see right now. Execute the trade immediately.')),
            const SizedBox(width: 8),
            _chip(AppLocalizations.of(context).fullAutoScan, () =>
                _sendChat('Run a full market scan. Check all news, find high confidence opportunities, and execute the best trade now.')),
            const SizedBox(width: 8),
            _chip(AppLocalizations.of(context).portfolioReview, () =>
                _sendChat('Review my portfolio. What is making money and what should I sell? Give me a clear action plan.')),
            const SizedBox(width: 8),
            _chip(AppLocalizations.of(context).lockInGains, () =>
                _sendChat('Which of my positions are most profitable right now? Sell 50 percent of my best performing position to lock in gains.')),
          ],
        ),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: msgs.isEmpty
            ? Text(
          AppLocalizations.of(context).loadingAgent,
          style: const TextStyle(color: AppTheme.onSurfaceVariant),
        )
            : ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: msgs.length + (_agentThinking ? 1 : 0),
          itemBuilder: (_, i) {
            if (_agentThinking && i == msgs.length) return _thinkingBubble();
            final msg = msgs[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ChatBubble(role: msg.role, text: msg.text),
                  if (msg.opportunities != null)
                    ...?msg.opportunities?.map((o) => _opportunityCard(o)),
                  if (msg.action != null && msg.action!.type != 'none')
                    _tradeActionBar(msg.action!),
                ],
              ),
            );
          },
        ),
      ),
      Container(
        padding: EdgeInsets.fromLTRB(
          16,
          10,
          16,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          border: Border(top: BorderSide(
              color: AppTheme.outlineVariant.withOpacity(0.2))),
        ),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _chatController,
              onSubmitted: _sendChat,
              maxLines: null,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).chatHint,
                hintStyle: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13),
                filled: true, fillColor: AppTheme.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(26), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _sendChat(_chatController.text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: _agentThinking ? AppTheme.outlineVariant : AppTheme.primary,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _chip(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.1),
            blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Text(label, style: const TextStyle(fontSize: 12,
          fontWeight: FontWeight.w600, color: AppTheme.onPrimaryContainer)),
    ),
  );

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
          color: AppTheme.onSurface));

  Widget _thinkingBubble() =>  Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(width: 16, height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
       const SizedBox(width: 10),
        Text(AppLocalizations.of(context).aiAnalyzing, style: const TextStyle(
            color: AppTheme.onSurfaceVariant, fontStyle: FontStyle.italic, fontSize: 13)),
      ]),
    ),
  );

  Widget _opportunityCard(OpportunityCard opp) {
    final isBuy = opp.signal == 'BUY';
    final color   = isBuy ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C);
    final bgColor = isBuy
        ? const Color(0xFF1B5E20).withOpacity(0.08)
        : const Color(0xFFB71C1C).withOpacity(0.08);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
              child: Text(opp.signal, style: const TextStyle(
                  color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Text(opp.assetName, style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.onSurface)),
          ]),
          const SizedBox(height: 4),
          Text(opp.reason, style: const TextStyle(
              fontSize: 12, color: AppTheme.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text('\$${opp.suggestedUsd.toStringAsFixed(0)} suggested • ${opp.timeHorizon}',
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ])),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => _sendChat(
              'Execute: ${opp.signal} ${opp.suggestedUsd.toStringAsFixed(0)} dollars of ${opp.assetName} now. Reason: ${opp.reason}'),
          style: ElevatedButton.styleFrom(
            backgroundColor: color, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: Text(AppLocalizations.of(context).invest, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ]),
    );
  }

  Widget _tradeActionBar(AgentAction action) {
    final isBuy = action.type == 'buy';
    final color = isBuy ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F);
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(children: [
        Icon(isBuy ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(
          isBuy
              ? 'Trade: BUY \$${action.usdAmount.toStringAsFixed(0)} of ${action.assetName}'
              : 'Trade: SELL ${(action.sellFraction * 100).toStringAsFixed(0)}% of ${action.assetName}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
        )),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _confirmAndTrade(action),
          style: ElevatedButton.styleFrom(
            backgroundColor: color, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: Text(AppLocalizations.of(context).execute, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ]),
    );
  }

  // ── POSITIONS TAB — Real-time Alpaca P&L ─────────────────────────────────

  Widget _buildPositionsTab() {
    if (_loadingAlpaca) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_alpacaSvc.isConfigured) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.pie_chart_outline_rounded, size: 64, color: AppTheme.outlineVariant),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context).noAlpacaConnected,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context).connectAlpacaPositions,
              style: TextStyle(color: AppTheme.onSurfaceVariant)),
        ]),
      ));
    }

    final totalPnl   = _positions.fold(0.0, (s, p) => s + p.unrealizedPl);
    final totalValue = _positions.fold(0.0, (s, p) => s + p.marketValue);
    final isUp       = totalPnl >= 0;

    return RefreshIndicator(
      onRefresh: _silentAlpacaRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // Account summary banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isUp
                    ? [const Color(0xFF0A2416), const Color(0xFF0D3520)]
                    : [const Color(0xFF1C0A0A), const Color(0xFF2C1010)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 8, height: 8,
                    decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50), shape: BoxShape.circle)),
                const SizedBox(width: 6),
              Text(AppLocalizations.of(context).livePortfolio, style: TextStyle(
                    fontSize: 10, color: Colors.white60,
                    fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const Spacer(),
                Text(AppLocalizations.of(context).autoRefresh30s, style: TextStyle(
                    fontSize: 10, color: Colors.white.withOpacity(0.4))),
              ]),
              const SizedBox(height: 12),
              Text('\$${totalValue.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 4),
              Row(children: [
                Icon(isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    color: isUp ? const Color(0xFF4CAF50) : const Color(0xFFEF5350), size: 18),
                const SizedBox(width: 4),
                Text('${isUp ? "+" : ""}\$${totalPnl.toStringAsFixed(2)} unrealized P&L',
                    style: TextStyle(
                        color: isUp ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
                        fontWeight: FontWeight.bold, fontSize: 14)),
              ]),
              if (_account != null) ...[
                const SizedBox(height: 8),
                Text('Cash: \$${_account!.cash.toStringAsFixed(2)}  •  '
                    'Buying power: \$${_account!.buyingPower.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ]),
          ),
          const SizedBox(height: 16),

          if (_positions.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16)),
              child:  Column(children: [
                Icon(Icons.inbox_rounded, size: 48, color: AppTheme.outlineVariant),
              const  SizedBox(height: 12),
                Text(AppLocalizations.of(context).noOpenPositions, style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
               const SizedBox(height: 4),
                Text(AppLocalizations.of(context).dashboardOpportunities,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13)),
              ]),
            )
          else ...[
            Text(AppLocalizations.of(context).openPositions, style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
            const SizedBox(height: 10),
            ..._positions.map((pos) => _positionCard(pos)),
          ],
        ],
      ),
    );
  }

  Widget _positionCard(AlpacaPosition pos) {
    final isProfit = pos.isProfit;
    final pnlColor = isProfit ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F);
    final pnlBg    = isProfit
        ? const Color(0xFF1B5E20).withOpacity(0.08)
        : const Color(0xFFB71C1C).withOpacity(0.08);
    final pnlPct   = pos.unrealizedPlpc * 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pnlColor.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(pos.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(pos.displayName, style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.onSurface)),
            Text('${pos.qty.toStringAsFixed(4)} units',
                style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
          ])),
          // Live P&L badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: pnlBg, borderRadius: BorderRadius.circular(10)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${isProfit ? "+" : ""}\$${pos.unrealizedPl.toStringAsFixed(2)}',
                  style: TextStyle(color: pnlColor,
                      fontWeight: FontWeight.bold, fontSize: 13)),
              Text('${isProfit ? "+" : ""}${pnlPct.toStringAsFixed(2)}%',
                  style: TextStyle(color: pnlColor, fontSize: 11)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
          _statCol(AppLocalizations.of(context).entryPrice, '\$${pos.avgEntryPrice.toStringAsFixed(2)}'),
            _divider(),
    _statCol(AppLocalizations.of(context).currentPrice, '\$${pos.currentPrice.toStringAsFixed(2)}'),
            _divider(),
    _statCol(AppLocalizations.of(context).marketValue, '\$${pos.marketValue.toStringAsFixed(2)}'),
          ]),
        ),
        const SizedBox(height: 10),
        // Sell button
        SizedBox(width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _sellPosition(pos),
            icon: const Icon(Icons.sell_rounded, size: 14),
            label: Text(AppLocalizations.of(context).sellPosition),
            style: OutlinedButton.styleFrom(
              foregroundColor: pnlColor,
              side: BorderSide(color: pnlColor.withOpacity(0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _statCol(String label, String value) => Expanded(
    child: Column(children: [
      Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontSize: 12,
          fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
    ]),
  );

  Widget _divider() => Container(width: 1, height: 32,
      color: AppTheme.outlineVariant.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 4));

  bool _sellingPosition = false;

  Future<void> _sellPosition(AlpacaPosition pos) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.sell_rounded, color: Color(0xFFD32F2F)),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context).closePosition, style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFB71C1C).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(pos.displayName, style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text('Value: \$${pos.marketValue.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 13)),
              Text('P&L: ${pos.isProfit ? "+" : ""}\$${pos.unrealizedPl.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: pos.isProfit ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
                    fontWeight: FontWeight.bold,
                  )),
            ]),
          ),
          const SizedBox(height: 10),
              Text(AppLocalizations.of(context).alpacaDescription,
              style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context).cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Close Position', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _sellingPosition = true);
    // Use closePosition (DELETE) — most reliable
    final result = await _alpacaSvc.closePosition(pos.symbol);
    if (!mounted) return;
    setState(() => _sellingPosition = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: result.success
          ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
      content: Text(result.success
          ? '✅ Closed ${pos.displayName} — order submitted'
          : '❌ ${result.error}'),
      duration: const Duration(seconds: 5),
    ));
    if (result.success) {
      // Immediate refresh + retry after 3s (Alpaca needs time to process)
      await _silentAlpacaRefresh();
      await Future.delayed(const Duration(seconds: 3));
      await _silentAlpacaRefresh();
    }
  }
}
