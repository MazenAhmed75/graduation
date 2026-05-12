import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/market_asset_model.dart';
import '../utils/constants.dart';

/// Fetches live prices from free public APIs.
/// ─ Metals  → api.metals.live  (no key required)
/// ─ Crypto  → api.coingecko.com (no key required)
/// ─ Stocks  → finnhub.io (free API key, 60 req/min)
class MarketService {
  static final MarketService _instance = MarketService._internal();
  factory MarketService() => _instance;
  MarketService._internal();

  List<MarketAssetModel>? _cachedAssets;
  DateTime? _lastFetch;
  static const _cacheDuration = Duration(minutes: 2);

  Future<List<MarketAssetModel>> fetchAllPrices() async {
    if (_cachedAssets != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheDuration) {
      return _cachedAssets!;
    }

    final results = await Future.wait([
      _fetchMetals(),
      _fetchCrypto(),
      _fetchStocks(),
    ]);

    _cachedAssets = [...results[0], ...results[1], ...results[2]];
    _lastFetch = DateTime.now();
    return _cachedAssets!;
  }

  Future<MarketAssetModel?> fetchAssetById(String id) async {
    final all = await fetchAllPrices();
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── METALS ───────────────────────────────────────────────────────────────
  Future<List<MarketAssetModel>> _fetchMetals() async {
    try {
      final resp = await http
          .get(Uri.parse(AppConstants.metalsBase))
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode != 200) return _metalsFallback();

      final List<dynamic> data = jsonDecode(resp.body);
      final Map<String, double> prices = {};
      for (final item in data) {
        if (item is Map) {
          item.forEach((k, v) =>
              prices[k.toString().toLowerCase()] = (v as num).toDouble());
        }
      }

      return [
        MarketAssetModel(
          id: 'gold', symbol: 'XAU', name: 'Gold',
          category: 'metal',
          price: prices['gold'] ?? 3320,
          change24h: 0,
          fetchedAt: DateTime.now(),
        ),
        MarketAssetModel(
          id: 'silver', symbol: 'XAG', name: 'Silver',
          category: 'metal',
          price: prices['silver'] ?? 33,
          change24h: 0,
          fetchedAt: DateTime.now(),
        ),
      ];
    } catch (_) {
      return _metalsFallback();
    }
  }

  List<MarketAssetModel> _metalsFallback() => [
    MarketAssetModel(id: 'gold',   symbol: 'XAU', name: 'Gold',   category: 'metal', price: 3320, fetchedAt: DateTime.now()),
    MarketAssetModel(id: 'silver', symbol: 'XAG', name: 'Silver', category: 'metal', price: 33,   fetchedAt: DateTime.now()),
  ];

  // ─── CRYPTO (CoinGecko) ───────────────────────────────────────────────────
  Future<List<MarketAssetModel>> _fetchCrypto() async {
    try {
      final ids  = AppConstants.cryptoIds.join(',');
      final uri  = Uri.parse(
          '${AppConstants.coinGeckoBase}/simple/price'
          '?ids=$ids&vs_currencies=usd&include_24hr_change=true');

      final resp = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode != 200) return _cryptoFallback();

      final Map<String, dynamic> data = jsonDecode(resp.body);

      final catalogue = {
        'bitcoin':     ('BTC',  'Bitcoin',  'crypto'),
        'ethereum':    ('ETH',  'Ethereum', 'crypto'),
        'binancecoin': ('BNB',  'BNB',      'crypto'),
        'solana':      ('SOL',  'Solana',   'crypto'),
        'ripple':      ('XRP',  'XRP',      'crypto'),
      };

      return AppConstants.cryptoIds
          .where((id) => data.containsKey(id) && catalogue.containsKey(id))
          .map((id) {
        final (symbol, name, cat) = catalogue[id]!;
        return MarketAssetModel(
          id: id, symbol: symbol, name: name, category: cat,
          price:     (data[id]['usd'] ?? 0).toDouble(),
          change24h: (data[id]['usd_24h_change'] ?? 0).toDouble(),
          fetchedAt: DateTime.now(),
        );
      }).toList();
    } catch (_) {
      return _cryptoFallback();
    }
  }

  List<MarketAssetModel> _cryptoFallback() => [
    MarketAssetModel(id: 'bitcoin',     symbol: 'BTC', name: 'Bitcoin',  category: 'crypto', price: 97000, fetchedAt: DateTime.now()),
    MarketAssetModel(id: 'ethereum',    symbol: 'ETH', name: 'Ethereum', category: 'crypto', price: 3800,  fetchedAt: DateTime.now()),
    MarketAssetModel(id: 'binancecoin', symbol: 'BNB', name: 'BNB',      category: 'crypto', price: 600,   fetchedAt: DateTime.now()),
    MarketAssetModel(id: 'solana',      symbol: 'SOL', name: 'Solana',   category: 'crypto', price: 145,   fetchedAt: DateTime.now()),
    MarketAssetModel(id: 'ripple',      symbol: 'XRP', name: 'XRP',      category: 'crypto', price: 0.52,  fetchedAt: DateTime.now()),
  ];

  // ─── STOCKS (Finnhub batch quotes) ───────────────────────────────────────
  Future<List<MarketAssetModel>> _fetchStocks() async {
    final names = {
      'AAPL':  'Apple Inc.',
      'TSLA':  'Tesla',
      'NVDA':  'NVIDIA',
      'MSFT':  'Microsoft',
      'AMZN':  'Amazon',
      'GOOGL': 'Alphabet (Google)',
      'META':  'Meta Platforms',
      'SPY':   'S&P 500 ETF',
    };

    final List<MarketAssetModel> stocks = [];

    // Fetch in parallel (Finnhub free: 60 req/min)
    await Future.wait(AppConstants.stockTickers.map((ticker) async {
      try {
        final uri = Uri.parse(
          '${AppConstants.finnhubBase}/quote'
          '?symbol=$ticker&token=${AppConstants.finnhubApiKey}',
        );
        final resp = await http
            .get(uri, headers: {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 8));
        if (resp.statusCode == 200) {
          final d = jsonDecode(resp.body) as Map<String, dynamic>;
          final c  = (d['c']  ?? 0).toDouble(); // current price
          final pc = (d['pc'] ?? 0).toDouble(); // previous close
          final change = pc > 0 ? ((c - pc) / pc * 100) : 0.0;
          if (c > 0) {
            stocks.add(MarketAssetModel(
              id: ticker, symbol: ticker,
              name: names[ticker] ?? ticker,
              category: 'stock',
              price: c,
              change24h: change,
              fetchedAt: DateTime.now(),
            ));
          }
        }
      } catch (_) {}
    }));

    if (stocks.isEmpty) return _stocksFallback();

    // Preserve order
    stocks.sort((a, b) =>
        AppConstants.stockTickers.indexOf(a.id)
            .compareTo(AppConstants.stockTickers.indexOf(b.id)));
    return stocks;
  }

  List<MarketAssetModel> _stocksFallback() => [
    MarketAssetModel(id: 'AAPL',  symbol: 'AAPL',  name: 'Apple Inc.',        category: 'stock', price: 213,  fetchedAt: DateTime.now()),
    MarketAssetModel(id: 'TSLA',  symbol: 'TSLA',  name: 'Tesla',             category: 'stock', price: 175,  fetchedAt: DateTime.now()),
    MarketAssetModel(id: 'NVDA',  symbol: 'NVDA',  name: 'NVIDIA',            category: 'stock', price: 875,  fetchedAt: DateTime.now()),
    MarketAssetModel(id: 'MSFT',  symbol: 'MSFT',  name: 'Microsoft',         category: 'stock', price: 420,  fetchedAt: DateTime.now()),
    MarketAssetModel(id: 'AMZN',  symbol: 'AMZN',  name: 'Amazon',            category: 'stock', price: 190,  fetchedAt: DateTime.now()),
    MarketAssetModel(id: 'GOOGL', symbol: 'GOOGL', name: 'Alphabet (Google)', category: 'stock', price: 170,  fetchedAt: DateTime.now()),
    MarketAssetModel(id: 'META',  symbol: 'META',  name: 'Meta Platforms',    category: 'stock', price: 510,  fetchedAt: DateTime.now()),
    MarketAssetModel(id: 'SPY',   symbol: 'SPY',   name: 'S&P 500 ETF',       category: 'stock', price: 535,  fetchedAt: DateTime.now()),
  ];

  String buildPriceSnapshot(List<MarketAssetModel> assets) {
    return assets.map((a) =>
        '${a.name} (${a.symbol}): ${a.displayPrice}'
        ' ${a.isUp ? '+' : ''}${a.displayChange}').join('\n');
  }
}
