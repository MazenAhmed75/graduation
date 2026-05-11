import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

/// AlpacaService — handles real trading via Alpaca Markets API.
/// Paper trading base:  https://paper-api.alpaca.markets
/// Live trading base:   https://api.alpaca.markets
///
/// Supports: US Stocks, Gold ETF (GLD), Silver ETF (SLV), BTC, ETH
class AlpacaService {
  static final AlpacaService _instance = AlpacaService._internal();
  factory AlpacaService() => _instance;
  AlpacaService._internal();

  String _apiKey    = '';
  String _apiSecret = '';
  bool   _isPaper   = true; // always start in paper mode for safety

  String get _baseUrl => _isPaper
      ? 'https://paper-api.alpaca.markets'
      : 'https://api.alpaca.markets';

  bool get isConfigured => _apiKey.isNotEmpty && _apiSecret.isNotEmpty;

  void configure({
    required String apiKey,
    required String apiSecret,
    bool paperMode = true,
  }) {
    _apiKey    = apiKey;
    _apiSecret = apiSecret;
    _isPaper   = paperMode;
  }

  Map<String, String> get _headers => {
    'APCA-API-KEY-ID':     _apiKey,
    'APCA-API-SECRET-KEY': _apiSecret,
    'Content-Type':        'application/json',
    'Accept':              'application/json',
  };

  // ── ACCOUNT ───────────────────────────────────────────────────────────────

  Future<AlpacaAccount?> getAccount() async {
    try {
      final resp = await http
          .get(Uri.parse('$_baseUrl/v2/account'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        return AlpacaAccount.fromJson(jsonDecode(resp.body));
      }
    } catch (_) {}
    return null;
  }

  // ── POSITIONS ─────────────────────────────────────────────────────────────

  Future<List<AlpacaPosition>> getPositions() async {
    try {
      final resp = await http
          .get(Uri.parse('$_baseUrl/v2/positions'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final List data = jsonDecode(resp.body);
        return data.map((j) => AlpacaPosition.fromJson(j)).toList();
      }
    } catch (_) {}
    return [];
  }

  // ── ORDERS ────────────────────────────────────────────────────────────────

  /// Buy a symbol with a dollar amount (fractional shares supported)
  Future<AlpacaOrderResult> buyMarket({
    required String symbol,
    required double notional, // USD amount to spend
  }) async {
    if (!isConfigured) {
      return AlpacaOrderResult(success: false, error: 'Alpaca API not configured. Add your API keys in Settings.');
    }

    final isCrypto = symbol.contains('/');
    // IMPORTANT: notional MUST be a JSON number (double), NOT a string.
    // Alpaca silently treats string values as 0.
    final body = jsonEncode({
      'symbol':        symbol.toUpperCase(),
      'notional':      double.parse(notional.toStringAsFixed(2)), // JSON number
      'side':          'buy',
      'type':          'market',
      'time_in_force': isCrypto ? 'gtc' : 'day',
    });

    try {
      final resp = await http
          .post(Uri.parse('$_baseUrl/v2/orders'),
              headers: _headers, body: body)
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return AlpacaOrderResult(
          success: true,
          orderId: data['id'],
          symbol: data['symbol'],
          status: data['status'],
        );
      }
      return AlpacaOrderResult(
        success: false,
        error: data['message'] ?? 'Order failed',
      );
    } catch (e) {
      return AlpacaOrderResult(success: false, error: e.toString());
    }
  }

  /// Close an ENTIRE position via DELETE — most reliable method
  Future<AlpacaOrderResult> closePosition(String symbol) async {
    if (!isConfigured) {
      return AlpacaOrderResult(success: false, error: 'Alpaca not configured.');
    }
    // Alpaca uses '%2F' encoding for crypto pairs like BTC/USD
    final encoded = Uri.encodeComponent(symbol.toUpperCase());
    try {
      final resp = await http
          .delete(Uri.parse('$_baseUrl/v2/positions/$encoded'), headers: _headers)
          .timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200 || resp.statusCode == 207) {
        final data = jsonDecode(resp.body);
        return AlpacaOrderResult(
          success: true,
          orderId: data['id'] ?? data['order_id'],
          symbol:  symbol,
          status:  data['status'] ?? 'accepted',
        );
      }
      final err = jsonDecode(resp.body);
      return AlpacaOrderResult(
          success: false, error: err['message'] ?? 'Close failed (${resp.statusCode})');
    } catch (e) {
      return AlpacaOrderResult(success: false, error: e.toString());
    }
  }

  /// Sell a partial fraction (0.0–1.0) of a position via order
  Future<AlpacaOrderResult> sellFraction({
    required String symbol,
    required double fraction,
    required double currentQty,
  }) async {
    if (!isConfigured) {
      return AlpacaOrderResult(success: false, error: 'Alpaca not configured.');
    }
    // Full close → use DELETE which is more reliable
    if (fraction >= 0.99) return closePosition(symbol);

    final qty      = currentQty * fraction.clamp(0.01, 0.99);
    final isCrypto = symbol.contains('/');
    // qty must also be a JSON number, not a string
    final qtyNum   = double.parse(qty.toStringAsFixed(isCrypto ? 8 : 6));
    final body = jsonEncode({
      'symbol':        symbol.toUpperCase(),
      'qty':           qtyNum,  // JSON number
      'side':          'sell',
      'type':          'market',
      'time_in_force': isCrypto ? 'gtc' : 'day',
    });
    try {
      final resp = await http
          .post(Uri.parse('$_baseUrl/v2/orders'),
              headers: _headers, body: body)
          .timeout(const Duration(seconds: 15));
      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return AlpacaOrderResult(
            success: true, orderId: data['id'],
            symbol: data['symbol'], status: data['status']);
      }
      return AlpacaOrderResult(
          success: false, error: data['message'] ?? 'Sell failed (${resp.statusCode})');
    } catch (e) {
      return AlpacaOrderResult(success: false, error: e.toString());
    }
  }

  /// Get all open orders
  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final resp = await http
          .get(Uri.parse('$_baseUrl/v2/orders?status=all&limit=20'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(resp.body));
      }
    } catch (_) {}
    return [];
  }

  // ── MARKET DATA ────────────────────────────────────────────────────────────

  /// Fetch latest bar (OHLCV) for a stock/ETF symbol
  Future<AlpacaBar?> getLatestBar(String symbol) async {
    try {
      final uri = Uri.parse(
          'https://data.alpaca.markets/v2/stocks/$symbol/bars/latest');
      final resp = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        return AlpacaBar.fromJson(data['bar'] ?? {});
      }
    } catch (_) {}
    return null;
  }

  /// Fetch historical bars for chart display
  Future<List<AlpacaBar>> getHistoricalBars({
    required String symbol,
    String timeframe = '1Day',
    int limit = 30,
  }) async {
    try {
      final uri = Uri.parse(
          'https://data.alpaca.markets/v2/stocks/$symbol/bars'
          '?timeframe=$timeframe&limit=$limit&sort=asc');
      final resp = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final bars = data['bars'] as List? ?? [];
        return bars.map((b) => AlpacaBar.fromJson(b)).toList();
      }
    } catch (_) {}
    return [];
  }
}

// ── Data Models ───────────────────────────────────────────────────────────────

class AlpacaAccount {
  final double buyingPower;
  final double cash;
  final double portfolioValue;
  final double equity;
  final bool   tradingBlocked;
  final String status;

  AlpacaAccount({
    required this.buyingPower, required this.cash,
    required this.portfolioValue, required this.equity,
    required this.tradingBlocked, required this.status,
  });

  factory AlpacaAccount.fromJson(Map<String, dynamic> j) => AlpacaAccount(
    buyingPower:    double.tryParse(j['buying_power'] ?? '0') ?? 0,
    cash:           double.tryParse(j['cash'] ?? '0') ?? 0,
    portfolioValue: double.tryParse(j['portfolio_value'] ?? '0') ?? 0,
    equity:         double.tryParse(j['equity'] ?? '0') ?? 0,
    tradingBlocked: j['trading_blocked'] ?? false,
    status:         j['status'] ?? '',
  );
}

class AlpacaPosition {
  final String symbol;
  final double qty;
  final double avgEntryPrice;
  final double currentPrice;
  final double marketValue;
  final double unrealizedPl;
  final double unrealizedPlpc;

  AlpacaPosition({
    required this.symbol, required this.qty,
    required this.avgEntryPrice, required this.currentPrice,
    required this.marketValue, required this.unrealizedPl,
    required this.unrealizedPlpc,
  });

  factory AlpacaPosition.fromJson(Map<String, dynamic> j) => AlpacaPosition(
    symbol:         j['symbol'] ?? '',
    qty:            double.tryParse(j['qty'] ?? '0') ?? 0,
    avgEntryPrice:  double.tryParse(j['avg_entry_price'] ?? '0') ?? 0,
    currentPrice:   double.tryParse(j['current_price'] ?? '0') ?? 0,
    marketValue:    double.tryParse(j['market_value'] ?? '0') ?? 0,
    unrealizedPl:   double.tryParse(j['unrealized_pl'] ?? '0') ?? 0,
    unrealizedPlpc: double.tryParse(j['unrealized_plpc'] ?? '0') ?? 0,
  );

  String get emoji {
    switch (symbol) {
      case 'GLD': return '🥇';
      case 'SLV': return '🥈';
      case 'BTC/USD': return '₿';
      case 'ETH/USD': return '⧫';
      default: return '📈';
    }
  }

  String get displayName {
    switch (symbol) {
      case 'GLD': return 'Gold ETF';
      case 'SLV': return 'Silver ETF';
      case 'BTC/USD': return 'Bitcoin';
      case 'ETH/USD': return 'Ethereum';
      default: return symbol;
    }
  }

  bool get isProfit => unrealizedPl >= 0;
}

class AlpacaBar {
  final DateTime time;
  final double   open;
  final double   high;
  final double   low;
  final double   close;
  final double   volume;

  AlpacaBar({
    required this.time, required this.open, required this.high,
    required this.low, required this.close, required this.volume,
  });

  factory AlpacaBar.fromJson(Map<String, dynamic> j) => AlpacaBar(
    time:   DateTime.tryParse(j['t'] ?? '') ?? DateTime.now(),
    open:   (j['o'] ?? 0).toDouble(),
    high:   (j['h'] ?? 0).toDouble(),
    low:    (j['l'] ?? 0).toDouble(),
    close:  (j['c'] ?? 0).toDouble(),
    volume: (j['v'] ?? 0).toDouble(),
  );
}

class AlpacaOrderResult {
  final bool    success;
  final String? orderId;
  final String? symbol;
  final String? status;
  final String? error;

  AlpacaOrderResult({
    required this.success,
    this.orderId, this.symbol, this.status, this.error,
  });
}

/// Supported trading symbols — maps our asset IDs to Alpaca symbols
class AlpacaSymbols {
  static const Map<String, String> assetIdToSymbol = {
    // Metals (via ETFs)
    'gold':         'GLD',
    'silver':       'SLV',
    // Crypto
    'bitcoin':      'BTC/USD',
    'ethereum':     'ETH/USD',
    'binancecoin':  'BNB/USD',
    'solana':       'SOL/USD',
    'ripple':       'XRP/USD',
    // US Stocks
    'AAPL':  'AAPL',
    'TSLA':  'TSLA',
    'NVDA':  'NVDA',
    'MSFT':  'MSFT',
    'AMZN':  'AMZN',
    'GOOGL': 'GOOGL',
    'META':  'META',
    'SPY':   'SPY',
  };

  static String? getSymbol(String assetId) => assetIdToSymbol[assetId];
  static String? getSymbolForAsset(String assetId) =>
      assetIdToSymbol[assetId] ?? assetIdToSymbol[assetId.toLowerCase()];
}
