/// Represents a live-priced asset (crypto, metal, stock)
class MarketAssetModel {
  final String id; // e.g. "bitcoin", "AAPL", "gold"
  final String symbol; // e.g. "BTC", "AAPL", "XAU"
  final String name; // e.g. "Bitcoin", "Apple Inc.", "Gold"
  final String category; // "crypto" | "metal" | "stock"
  final String emoji; // e.g. "₿", "🥇", "📈"
  final double price; // current USD price
  final double change24h; // % change in last 24h
  final DateTime fetchedAt;

  const MarketAssetModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.category,
    required this.emoji,
    required this.price,
    this.change24h = 0.0,
    required this.fetchedAt,
  });

  bool get isUp => change24h >= 0;

  /// Price per unit nicely formatted
  String get displayPrice {
    if (price >= 1000) {
      return '\$${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
    }
    if (price < 1) return '\$${price.toStringAsFixed(4)}';
    return '\$${price.toStringAsFixed(2)}';
  }

  String get displayChange =>
      '${isUp ? '+' : ''}${change24h.toStringAsFixed(2)}%';

  MarketAssetModel copyWith({
    double? price,
    double? change24h,
    DateTime? fetchedAt,
  }) {
    return MarketAssetModel(
      id: id,
      symbol: symbol,
      name: name,
      category: category,
      emoji: emoji,
      price: price ?? this.price,
      change24h: change24h ?? this.change24h,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}

/// Static catalogue of all assets we track
class AssetCatalogue {
  static final _epoch = DateTime.fromMillisecondsSinceEpoch(0);

  static final List<MarketAssetModel> all = [
    // Metals
    MarketAssetModel(
      id: 'gold',
      symbol: 'XAU',
      name: 'Gold',
      category: 'metal',
      emoji: '🥇',
      price: 0,
      fetchedAt: _epoch,
    ),
    MarketAssetModel(
      id: 'silver',
      symbol: 'XAG',
      name: 'Silver',
      category: 'metal',
      emoji: '🥈',
      price: 0,
      fetchedAt: _epoch,
    ),
    // Crypto
    MarketAssetModel(
      id: 'bitcoin',
      symbol: 'BTC',
      name: 'Bitcoin',
      category: 'crypto',
      emoji: '₿',
      price: 0,
      fetchedAt: _epoch,
    ),
    MarketAssetModel(
      id: 'ethereum',
      symbol: 'ETH',
      name: 'Ethereum',
      category: 'crypto',
      emoji: 'Ξ',
      price: 0,
      fetchedAt: _epoch,
    ),
    MarketAssetModel(
      id: 'binancecoin',
      symbol: 'BNB',
      name: 'BNB',
      category: 'crypto',
      emoji: '🟡',
      price: 0,
      fetchedAt: _epoch,
    ),
    MarketAssetModel(
      id: 'solana',
      symbol: 'SOL',
      name: 'Solana',
      category: 'crypto',
      emoji: '◎',
      price: 0,
      fetchedAt: _epoch,
    ),
    MarketAssetModel(
      id: 'ripple',
      symbol: 'XRP',
      name: 'XRP',
      category: 'crypto',
      emoji: '💧',
      price: 0,
      fetchedAt: _epoch,
    ),
    // Stocks
    MarketAssetModel(
      id: 'AAPL',
      symbol: 'AAPL',
      name: 'Apple Inc.',
      category: 'stock',
      emoji: '🍎',
      price: 0,
      fetchedAt: _epoch,
    ),
    MarketAssetModel(
      id: 'TSLA',
      symbol: 'TSLA',
      name: 'Tesla',
      category: 'stock',
      emoji: '🚗',
      price: 0,
      fetchedAt: _epoch,
    ),
    MarketAssetModel(
      id: 'NVDA',
      symbol: 'NVDA',
      name: 'NVIDIA',
      category: 'stock',
      emoji: '🎮',
      price: 0,
      fetchedAt: _epoch,
    ),
    MarketAssetModel(
      id: 'MSFT',
      symbol: 'MSFT',
      name: 'Microsoft',
      category: 'stock',
      emoji: '🪟',
      price: 0,
      fetchedAt: _epoch,
    ),
    MarketAssetModel(
      id: 'AMZN',
      symbol: 'AMZN',
      name: 'Amazon',
      category: 'stock',
      emoji: '📦',
      price: 0,
      fetchedAt: _epoch,
    ),
    MarketAssetModel(
      id: 'GOOGL',
      symbol: 'GOOGL',
      name: 'Alphabet (Google)',
      category: 'stock',
      emoji: '🔍',
      price: 0,
      fetchedAt: _epoch,
    ),
    MarketAssetModel(
      id: 'META',
      symbol: 'META',
      name: 'Meta Platforms',
      category: 'stock',
      emoji: '👍',
      price: 0,
      fetchedAt: _epoch,
    ),
    MarketAssetModel(
      id: 'SPY',
      symbol: 'SPY',
      name: 'S&P 500 ETF',
      category: 'stock',
      emoji: '📈',
      price: 0,
      fetchedAt: _epoch,
    ),
  ];
}
