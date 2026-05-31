import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/market_asset_model.dart';
import 'market_service.dart';
import 'news_service.dart';
import 'alpaca_service.dart';

// ─── Models ─────────────────────────────────────────────────────────────────

enum AgentCyclePhase { idle, gathering, analyzing, deciding, executing }

class PositionDecision {
  final String   symbol;
  final String   displayName;
  final String   action;          // 'hold' | 'sell' | 'sell_partial'
  final double   sellFraction;    // 0.0 if hold
  final String   reasoning;
  final String   riskLevel;       // 'LOW' | 'MEDIUM' | 'HIGH'
  final bool     autoExecuted;

  const PositionDecision({
    required this.symbol,
    required this.displayName,
    required this.action,
    this.sellFraction = 0,
    required this.reasoning,
    required this.riskLevel,
    this.autoExecuted = false,
  });
}

class BuyOpportunity {
  final String assetId;
  final String assetName;
  final double suggestedUsd;
  final String reasoning;
  final String timeHorizon;
  final String confidence;        // 'HIGH' | 'MEDIUM'

  const BuyOpportunity({
    required this.assetId,
    required this.assetName,
    required this.suggestedUsd,
    required this.reasoning,
    required this.timeHorizon,
    required this.confidence,
  });
}

class AgentCycleReport {
  final DateTime  runAt;
  final String    marketSentiment;
  final String    riskAssessment;
  final List<PositionDecision> positionDecisions;
  final List<BuyOpportunity>  buyOpportunities;
  final int       sellsExecuted;

  const AgentCycleReport({
    required this.runAt,
    required this.marketSentiment,
    required this.riskAssessment,
    required this.positionDecisions,
    required this.buyOpportunities,
    required this.sellsExecuted,
  });
}

// ─── Service ─────────────────────────────────────────────────────────────────

class AutonomousAgentService {
  static final AutonomousAgentService _i = AutonomousAgentService._();
  factory AutonomousAgentService() => _i;
  AutonomousAgentService._();

  static const _timeout = Duration(seconds: 45);

  Timer?              _timer;
  bool                _enabled      = false;
  bool                _cycleRunning = false;
  AgentCyclePhase     _phase        = AgentCyclePhase.idle;
  AgentCycleReport?   lastReport;
  DateTime?           lastRunAt;
  Duration            interval      = const Duration(hours: 1);

  // Callbacks wired by InvestScreen
  void Function(String key, {Map<String, String>? args, bool isError, bool isTrade})? onLog;
  Future<void> Function(String symbol)?   onAutoSell;    // auto-executed sell
  void Function(List<BuyOpportunity>)?    onBuyOpps;     // show to user for approval

  bool get isEnabled      => _enabled;
  bool get isCycleRunning => _cycleRunning;
  AgentCyclePhase get phase => _phase;

  // ── Enable / Disable ──────────────────────────────────────────────────────

  void enable({
    Duration? cycleInterval,
    void Function(String, {Map<String, String>? args, bool isError, bool isTrade})? onLog,
    Future<void> Function(String)? onAutoSell,
    void Function(List<BuyOpportunity>)? onBuyOpps,
  }) {
    if (_enabled) return;
    _enabled = true;
    interval = cycleInterval ?? const Duration(hours: 1);
    this.onLog      = onLog;
    this.onAutoSell = onAutoSell;
    this.onBuyOpps  = onBuyOpps;

    _log('auto_trade_enabled', args: {'interval': _fmtDuration(interval)});
    _runCycle();  // run immediately
    _timer = Timer.periodic(interval, (_) {
      if (!_cycleRunning) _runCycle();
    });
  }

  void disable() {
    _timer?.cancel();
    _timer   = null;
    _enabled = false;
    _cycleRunning = false;
    _phase = AgentCyclePhase.idle;
    _log('auto_trade_disabled');
  }

  void updateCallbacks({
    void Function(String, {Map<String, String>? args, bool isError, bool isTrade})? onLog,
    Future<void> Function(String)? onAutoSell,
    void Function(List<BuyOpportunity>)? onBuyOpps,
  }) {
    if (onLog      != null) this.onLog      = onLog;
    if (onAutoSell != null) this.onAutoSell = onAutoSell;
    if (onBuyOpps  != null) this.onBuyOpps  = onBuyOpps;
  }

  // ── Main hourly cycle ─────────────────────────────────────────────────────

  Future<void> _runCycle() async {
    if (_cycleRunning) return;
    _cycleRunning = true;
    lastRunAt = DateTime.now();

    try {
      // ── Phase 1: Gather data ─────────────────────────────────────────────
      _phase = AgentCyclePhase.gathering;
      _log('cycle_started_gathering');

      final assets    = await MarketService().fetchAllPrices();
      final news      = await NewsService().fetchFinancialNews();
      final account   = await AlpacaService().getAccount();
      final positions = await AlpacaService().getPositions();
      final cash      = account?.cash ?? 0;

      if (assets.isEmpty) {
        _log('no_market_data', isError: true);
        return;
      }

      _log('data_ready', args: {
        'assets': assets.length.toString(),
        'news': news.length.toString(),
        'positions': positions.length.toString(),
        'cash': cash.toStringAsFixed(0),
      });

      // Build context strings
      final priceCtx = assets
          .map((a) => '${a.name}(${a.symbol}): ${a.displayPrice} '
              '${a.isUp ? "+" : ""}${a.displayChange}')
          .join(', ');

      final newsCtx = news.isEmpty
          ? 'No news available — use technical data only.'
          : news.take(12).map((h) {
              final tone = h.sentiment == NewsSentiment.bullish ? '[BULL]'
                  : h.sentiment == NewsSentiment.bearish ? '[BEAR]' : '[NEUT]';
              return '$tone ${h.title}';
            }).join('\n');

      final portfolioCtx = positions.isEmpty
          ? 'No open positions.'
          : positions.map((p) =>
              '${p.symbol}: \$${p.marketValue.toStringAsFixed(2)} value, '
              '${p.isProfit ? "+" : ""}\$${p.unrealizedPl.toStringAsFixed(2)} P&L '
              '(${(p.unrealizedPlpc * 100).toStringAsFixed(1)}%)').join('\n');

      // ── Phase 2: Market sentiment analysis ──────────────────────────────
      _phase = AgentCyclePhase.analyzing;
      _log('step_analyzing_sentiment');

      final sentiment = await _ask('''
You are a senior market analyst at a wealth management firm.
Analyze the following data and produce a brief market outlook.

LIVE PRICES:
$priceCtx

NEWS HEADLINES:
$newsCtx

CURRENT PORTFOLIO:
$portfolioCtx
CASH: \$${cash.toStringAsFixed(0)}

Provide a structured analysis covering:
1. Overall market sentiment (BULLISH/BEARISH/MIXED) with confidence (HIGH/MEDIUM/LOW)
2. Key macro risks in the next 24-48 hours
3. Asset-specific notes: which look strong, which look weak
4. Portfolio risk level (LOW/MEDIUM/HIGH) given current holdings

Max 250 words. Be precise and data-driven.
''');

      if (sentiment == null) {
        _log('analysis_failed', isError: true);
        return;
      }
      _log('sentiment_preview', args: {
        'preview': sentiment.substring(0, sentiment.length.clamp(0, 120)),
      });

      // ── Phase 3: Position-by-position decisions ──────────────────────────
      _phase = AgentCyclePhase.deciding;
      _log('step_evaluating_positions');

      final List<PositionDecision> posDecisions = [];
      int sellsExecuted = 0;

      if (positions.isNotEmpty) {
        final posJson = await _ask('''
You are the portfolio manager at a hedge fund. Make HOLD or SELL decisions for each position.
Your job is ONLY to protect capital and lock in gains when appropriate.

MARKET ANALYSIS:
$sentiment

POSITIONS TO EVALUATE:
$portfolioCtx

LIVE PRICES:
$priceCtx

For each position, decide: HOLD, SELL (full close), or SELL_PARTIAL (take 50% profits).
Rules:
- SELL if: news is strongly bearish for this asset, OR unrealized loss exceeds 8%
- SELL_PARTIAL if: unrealized profit exceeds 15% and news suggests reversal risk
- HOLD otherwise — do not sell just because of minor fluctuations

Output ONLY valid JSON array (no other text):
[
  {
    "symbol": "BTC/USD",
    "action": "hold",
    "sellFraction": 0,
    "reasoning": "Bitcoin momentum still positive despite minor pullback",
    "riskLevel": "MEDIUM"
  }
]
''');

        if (posJson != null) {
          try {
            final match = RegExp(r'\[[\s\S]*\]').firstMatch(posJson);
            if (match != null) {
              final list = jsonDecode(match.group(0)!) as List;
              for (final item in list) {
                final d = item as Map<String, dynamic>;
                final sym    = d['symbol'] as String? ?? '';
                final action = (d['action'] as String? ?? 'hold').toLowerCase();
                final frac   = (d['sellFraction'] as num? ?? 0).toDouble();
                final reason = d['reasoning'] as String? ?? '';
                final risk   = d['riskLevel']  as String? ?? 'MEDIUM';

                // Find display name
                final pos = positions.firstWhere(
                    (p) => p.symbol.toLowerCase() == sym.toLowerCase(),
                    orElse: () => positions.first);

                final decision = PositionDecision(
                  symbol:      pos.symbol,
                  displayName: pos.displayName,
                  action:      action,
                  sellFraction: frac,
                  reasoning:   reason,
                  riskLevel:   risk,
                  autoExecuted: action != 'hold',
                );
                posDecisions.add(decision);

                if (action == 'hold') {
                  _log('position_hold', args: {'name': pos.displayName, 'reason': reason});
                } else if (action == 'sell' || action == 'sell_partial') {
                  _log('position_action', isTrade: true, args: {
                    'action': action.toUpperCase(),
                    'name': pos.displayName,
                    'reason': reason,
                  });
                  // AUTO-EXECUTE the sell
                  if (onAutoSell != null) {
                    await onAutoSell!(pos.symbol);
                    sellsExecuted++;
                    _log('position_closed', isTrade: true, args: {'name': pos.displayName});
                  }
                }
              }
            }
          } catch (e) {
            _log('parse_positions_error', isError: true, args: {'error': e.toString()});
          }
        }
      } else {
        _log('no_open_positions');
      }

      // ── Phase 4: Find NEW buy opportunities (user must approve) ──────────
      _log('step_scanning_buy_opps');

      final oppsJson = await _ask('''
You are an investment opportunity analyst at a private wealth firm.
Based on current market conditions, identify 2-3 high-conviction BUY opportunities.

MARKET ANALYSIS:
$sentiment

LIVE PRICES:
$priceCtx

AVAILABLE CASH: \$${cash.toStringAsFixed(0)}
EXISTING POSITIONS: $portfolioCtx

Rules:
- ONLY recommend assets with clear bullish signals in the news or price trend
- Max 20% of available cash per trade = \$${(cash * 0.20).clamp(50, 1000).toStringAsFixed(0)}
- Do NOT recommend assets already heavily held
- HIGH confidence = multiple bullish signals; MEDIUM = 1 clear signal

Output ONLY a valid JSON array:
[
  {
    "assetId": "bitcoin",
    "assetName": "Bitcoin",
    "suggestedUsd": 200,
    "reasoning": "Strong momentum + positive news",
    "timeHorizon": "3-7 days",
    "confidence": "HIGH"
  }
]
If no clear opportunities, output: []
''');

      final List<BuyOpportunity> buyOpps = [];
      if (oppsJson != null) {
        try {
          final match = RegExp(r'\[[\s\S]*\]').firstMatch(oppsJson);
          if (match != null) {
            final list = jsonDecode(match.group(0)!) as List;
            for (final item in list) {
              final d = item as Map<String, dynamic>;
              buyOpps.add(BuyOpportunity(
                assetId:      d['assetId']     ?? '',
                assetName:    d['assetName']   ?? '',
                suggestedUsd: (d['suggestedUsd'] as num? ?? 100).toDouble(),
                reasoning:    d['reasoning']   ?? '',
                timeHorizon:  d['timeHorizon'] ?? '1 week',
                confidence:   d['confidence']  ?? 'MEDIUM',
              ));
            }
          }
        }  catch (e) {
      _log('parse_buy_opps_error', isError: true, args: {'error': e.toString()});
    }
  }

    if (buyOpps.isNotEmpty) {
    _log('buy_opportunities_found', isTrade: true, args: {'count': buyOpps.length.toString()});
    onBuyOpps?.call(buyOpps);
    } else {
    _log('no_buy_opportunities');
    }
      // Save report
      lastReport = AgentCycleReport(
        runAt:            DateTime.now(),
        marketSentiment:  sentiment,
        riskAssessment:   sentiment,
        positionDecisions: posDecisions,
        buyOpportunities: buyOpps,
        sellsExecuted:    sellsExecuted,
      );

    _phase = AgentCyclePhase.idle;
    final nextRun = DateTime.now().add(interval);
    final timeStr = '${nextRun.hour.toString().padLeft(2,"0")}:${nextRun.minute.toString().padLeft(2,"0")}';

    if (sellsExecuted > 0) {
    _log('cycle_complete_with_sells', args: {'count': sellsExecuted.toString(), 'nextRun': timeStr});
    } else {
    _log('cycle_complete_no_sells', args: {'nextRun': timeStr});
    }
  } catch (e) {
  _log('cycle_error', isError: true, args: {'error': e.toString()});
  }  finally {
      _cycleRunning = false;
      _phase = AgentCyclePhase.idle;
    }
  }

  // ── Manual trigger ────────────────────────────────────────────────────────

  Future<void> runNow() async {
    if (!_cycleRunning) await _runCycle();
  }

  // ── AI call ───────────────────────────────────────────────────────────────

  Future<String?> _ask(String prompt) async {
    try {
      final resp = await http.post(
        Uri.parse('${AppConstants.aiBaseUrl}/chat/completions'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer ${AppConstants.aiApiKey}',
          'HTTP-Referer':  'https://ai-invest-app.local',
          'X-Title':       'AI Investment Agent',
        },
        body: jsonEncode({
          'model': AppConstants.aiModel,
          'messages': [
            {'role': 'system', 'content':
                'You are a precise, senior financial analyst. '
                'When asked for JSON, output ONLY valid JSON. No markdown, no explanations.'},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.25,
          'max_tokens':  800,
        }),
      ).timeout(_timeout);

      if (resp.statusCode != 200) return null;
      final data = jsonDecode(resp.body);
      return data['choices']?[0]?['message']?['content'] as String?;
    } catch (_) {
      return null;
    }
  }

  void _log(String key, {Map<String, String>? args, bool isError = false, bool isTrade = false}) =>
  onLog?.call(key, args: args, isError: isError, isTrade: isTrade);

  String _fmtDuration(Duration d) {
    if (d.inHours >= 1) return '${d.inHours}h';
    return '${d.inMinutes}m';
  }
}
