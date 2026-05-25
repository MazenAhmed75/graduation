// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/market_asset_model.dart';
import '../models/investment_model.dart';
import '../models/budget_model.dart';
import '../models/user_model.dart';
import 'news_service.dart';
import 'alpaca_service.dart';

class ChatMessage {
  final String role;
  final String text;
  final DateTime at;
  final AgentAction? action;
  final List<OpportunityCard>? opportunities;

  const ChatMessage({
    required this.role, required this.text,
    required this.at, this.action, this.opportunities,
  });
}

class AgentAction {
  final String type;       // 'buy' | 'sell' | 'none'
  final String assetId;
  final String assetName;
  final double usdAmount;
  final double sellFraction;
  final String reasoning;

  const AgentAction({
    required this.type, this.assetId = '', this.assetName = '',
    this.usdAmount = 0, this.sellFraction = 0,
    required this.reasoning,
  });
}

class OpportunityCard {
  final String assetId;
  final String assetName;
  final String signal;      // 'BUY' | 'SELL' | 'WATCH'
  final String reason;
  final double suggestedUsd;
  final String timeHorizon;

  const OpportunityCard({
    required this.assetId, required this.assetName, required this.signal,
    required this.reason, required this.suggestedUsd, required this.timeHorizon,
  });
}

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  final List<ChatMessage> messages = [];
  final List<Map<String, dynamic>> _history = [];
  String? _systemPrompt;

  static const _timeout = Duration(seconds: 45);

  // ── Session ───────────────────────────────────────────────────────────────

  void startNewSession({
    required UserModel user,
    required List<BudgetModel> budgets,
    required List<MarketAssetModel> liveAssets,
    required List<InvestmentModel> portfolio,
    required double fundBalance,
    List<NewsHeadline> newsHeadlines = const [],
    String riskTolerance = 'moderate',
  }) {
    messages.clear();
    _history.clear();

    _systemPrompt = _buildSystemPrompt(
      user: user, budgets: budgets, liveAssets: liveAssets,
      portfolio: portfolio, fundBalance: fundBalance,
      newsHeadlines: newsHeadlines, riskTolerance: riskTolerance,
    );

    messages.add(ChatMessage(
      role: 'model',
      text: 'Hey ${user.name.split(' ')[0]} 👋 I\'m your AI trading agent.\n\n'
          '💰 **Available to invest: \$${fundBalance.toStringAsFixed(2)}**\n\n'
          'I can:\n'
          '• **Execute trades** — just say *"invest \$500 in NVDA"* or *"sell half my Bitcoin"*\n'
          '• **Find opportunities** — say *"what should I buy?"* or *"show me opportunities"*\n'
          '• **Analyze anything** — *"how is gold doing?"* or *"should I buy Tesla?"*\n\n'
          'What do you want to do?',
      at: DateTime.now(),
    ));
  }

  // ── Send message ─────────────────────────────────────────────────────────

  Future<ChatMessage> sendMessage(String userText) async {
    if (_systemPrompt == null) {
      return ChatMessage(
        role: 'model',
        text: 'Please open the Invest tab first to initialize your advisor.',
        at: DateTime.now(),
      );
    }

    messages.add(ChatMessage(role: 'user', text: userText, at: DateTime.now()));
    _history.add({'role': 'user', 'content': userText});

    try {
      final responseText = await _chat(_systemPrompt!, _history);
      _history.add({'role': 'assistant', 'content': responseText});

      final action        = _parseAction(responseText);
      final opportunities = _parseOpportunities(responseText);
      final display       = _stripJson(responseText);

      final botMsg = ChatMessage(
        role: 'model', text: display, at: DateTime.now(),
        action: action, opportunities: opportunities,
      );
      messages.add(botMsg);
      return botMsg;
    } catch (e) {
      if (_history.isNotEmpty && _history.last['role'] == 'user') {
        _history.removeLast();
      }
      final errMsg = ChatMessage(
        role: 'model',
        text: 'Error: ${e.toString().split('\n').first}',
        at: DateTime.now(),
      );
      messages.add(errMsg);
      return errMsg;
    }
  }

  // ── HTTP (OpenAI-compatible) ──────────────────────────────────────────────

  Future<String> _chat(String system, List<Map<String, dynamic>> history,
      {double temperature = 0.75, int maxTokens = 1500}) async {
    final url = Uri.parse('${AppConstants.aiBaseUrl}/chat/completions');
    final resp = await http.post(url,
      headers: {
        'Content-Type':  'application/json',
        'Authorization': 'Bearer ${AppConstants.aiApiKey}',
        'HTTP-Referer':  'https://ai-invest-app.local',
        'X-Title':       'AI Investment Agent',
      },
      body: jsonEncode({
        'model':       AppConstants.aiModel,
        'messages':    [{'role': 'system', 'content': system}, ...history],
        'temperature': temperature,
        'max_tokens':  maxTokens,
      }),
    ).timeout(_timeout);

    if (resp.statusCode != 200) {
      final err = jsonDecode(resp.body);
      throw Exception(err['error']?['message'] ?? 'HTTP ${resp.statusCode}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return data['choices']?[0]?['message']?['content'] as String? ?? '';
  }

  Future<String> quickAsk(String prompt,
      {double temperature = 0.4, int maxTokens = 600}) async {
    try {
      return await _chat(
        'You are a concise, expert financial analyst. Be direct.',
        [{'role': 'user', 'content': prompt}],
        temperature: temperature, maxTokens: maxTokens,
      );
    } catch (_) { return ''; }
  }

  /// Builds a prompt that asks the AI to return ONLY the ```opportunities block
  String buildOpportunityScanPrompt({
    required List<MarketAssetModel> assets,
    required List<AlpacaPosition>  positions,
    required double cash,
  }) {
    final prices = assets.map((a) =>
        '${a.name}(${a.symbol}): ${a.displayPrice} ${a.isUp ? "+" : ""}${a.displayChange}').join(', ');
    final held = positions.isEmpty ? 'none'
        : positions.map((p) => '${p.symbol} P&L ${p.isProfit ? "+" : ""}\$${p.unrealizedPl.toStringAsFixed(0)}').join(', ');
    return '''
You are an aggressive AI trading agent. Analyze these live prices and find the 4 BEST opportunities right now.

LIVE PRICES: $prices
CURRENT HOLDINGS: $held
CASH AVAILABLE: \$${cash.toStringAsFixed(0)}

Respond ONLY with this exact JSON block (no other text):
```opportunities
[
  {"assetId":"bitcoin","assetName":"Bitcoin","signal":"BUY","reason":"<1 sentence reason based on price trend>","suggestedUsd":${(cash * 0.15).clamp(50, 500).toStringAsFixed(0)},"timeHorizon":"1-2 weeks"},
  {"assetId":"gold","assetName":"Gold","signal":"BUY","reason":"...","suggestedUsd":150,"timeHorizon":"1 month"}
]
```
Use real assetIds from: ${assets.map((a) => '"${a.id}"').join(', ')}.
Only include high-confidence opportunities. Signal must be BUY or SELL.
''';
  }

  /// Parses the ```opportunities block from raw AI text
  List<OpportunityCard> parseOpportunitiesFromRaw(String raw) =>
      _parseOpportunities(raw) ?? [];


  // ── System Prompt ─────────────────────────────────────────────────────────

  String _buildSystemPrompt({
    required UserModel user,
    required List<BudgetModel> budgets,
    required List<MarketAssetModel> liveAssets,
    required List<InvestmentModel> portfolio,
    required double fundBalance,
    required List<NewsHeadline> newsHeadlines,
    required String riskTolerance,
  }) {
    final priceLines = liveAssets.map((a) =>
        '  ${a.name} (${a.symbol}): ${a.displayPrice} ${a.isUp ? "+" : ""}${a.displayChange}').join('\n');

    final portfolioLines = portfolio.isEmpty
        ? '  No positions yet.'
        : portfolio.map((p) =>
            '  ${p.assetName}: ${p.quantity.toStringAsFixed(4)} units @ \$${p.buyPrice.toStringAsFixed(2)} avg, '
            'value \$${p.currentValue.toStringAsFixed(2)}, P&L ${p.isProfit ? "+" : ""}\$${p.pnl.toStringAsFixed(2)}').join('\n');

    final supportedAssets = liveAssets.map((a) => '${a.name} → assetId: "${a.id}"').join(', ');

    return '''
You are an aggressive, decisive AI investment agent. You EXECUTE trades. You do NOT just recommend.

## YOUR MISSION
Make the user money. Analyze the market, find opportunities, and ACT on them. When you see a good trade, do it.

## USER
- Name: ${user.name}
- Investment fund: \$${fundBalance.toStringAsFixed(2)} available to invest RIGHT NOW
- Risk profile: $riskTolerance

## LIVE PORTFOLIO
$portfolioLines

## LIVE MARKET PRICES (as of ${DateTime.now().toLocal()})
$priceLines

## MARKET NEWS
${NewsService().buildNewsContext(newsHeadlines)}

## SUPPORTED ASSETS (use exact assetId in JSON)
$supportedAssets

## HOW TO EXECUTE A TRADE
ALWAYS append a JSON block when making any trade. Never ask for confirmation — just do it.

BUY example:
```json
{"action":"buy","assetId":"bitcoin","assetName":"Bitcoin","usdAmount":200,"reasoning":"Bullish momentum + positive news"}
```

SELL example:
```json
{"action":"sell","assetId":"bitcoin","assetName":"Bitcoin","sellFraction":0.5,"reasoning":"Taking 50% profit"}
```

OPPORTUNITIES (when user asks "what should I buy" or "show opportunities"):
```opportunities
[
  {"assetId":"nvidia","assetName":"NVIDIA","signal":"BUY","reason":"AI chip demand record high","suggestedUsd":300,"timeHorizon":"1-2 weeks"},
  {"assetId":"bitcoin","assetName":"Bitcoin","signal":"BUY","reason":"Breaking resistance at 90k","suggestedUsd":150,"timeHorizon":"1 month"}
]
```

## CRITICAL RULES
1. When user says "invest X in Y" or "buy X" → EXECUTE IT IMMEDIATELY with the JSON block. No hesitation.
2. When user says "sell X" or "take profits" → EXECUTE THE SELL.
3. When user asks "show opportunities" or "what to buy" → output the opportunities JSON block with 3-5 picks.
4. **IGNORE monthly savings goals** — they are irrelevant to investment decisions. The user controls their own money.
5. Max 25% of fund per single asset for risk management.
6. Be DIRECT. No disclaimers, no "I recommend holding". If the market looks good, BUY.
7. Keep analysis under 3 sentences. Get to the point. Then execute.
8. If user asks general questions, answer conversationally without JSON blocks.
''';
  }

  // ── Parsers ───────────────────────────────────────────────────────────────

  AgentAction? _parseAction(String text) {
    try {
      final m = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
      if (m == null) return null;
      final j = jsonDecode(m.group(1)!) as Map<String, dynamic>;
      final t = j['action'] as String? ?? 'none';
      if (t == 'buy') return AgentAction(
        type: 'buy', assetId: j['assetId'] ?? '',
        assetName: j['assetName'] ?? j['assetId'] ?? '',
        usdAmount: (j['usdAmount'] ?? 0).toDouble(),
        reasoning: j['reasoning'] ?? '',
      );
      if (t == 'sell') return AgentAction(
        type: 'sell', assetId: j['assetId'] ?? '',
        assetName: j['assetName'] ?? j['assetId'] ?? '',
        sellFraction: (j['sellFraction'] ?? 0.5).toDouble(),
        reasoning: j['reasoning'] ?? '',
      );
    } catch (_) {}
    return null;
  }

  List<OpportunityCard>? _parseOpportunities(String text) {
    try {
      final m = RegExp(r'```opportunities\s*([\s\S]*?)\s*```').firstMatch(text);
      if (m == null) return null;
      final list = jsonDecode(m.group(1)!) as List<dynamic>;
      return list.map((o) => OpportunityCard(
        assetId:      o['assetId'] ?? '',
        assetName:    o['assetName'] ?? '',
        signal:       o['signal'] ?? 'WATCH',
        reason:       o['reason'] ?? '',
        suggestedUsd: (o['suggestedUsd'] ?? 0).toDouble(),
        timeHorizon:  o['timeHorizon'] ?? '',
      )).toList();
    } catch (_) {}
    return null;
  }

  String _stripJson(String text) => text
      .replaceAll(RegExp(r'```json[\s\S]*?```'), '')
      .replaceAll(RegExp(r'```opportunities[\s\S]*?```'), '')
      .trim();
}
