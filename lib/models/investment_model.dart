/// Represents one open position in the user's portfolio
class InvestmentModel {
  final String id;
  final String userId;
  final String assetId;       // "bitcoin", "gold", "AAPL", etc.
  final String assetSymbol;   // "BTC", "XAU", "AAPL"
  final String assetName;     // "Bitcoin", "Gold", "Apple Inc."
  final String assetCategory; // "crypto" | "metal" | "stock"
  final double quantity;      // How much the user holds
  final double buyPrice;      // Price at which they bought
  final double currentPrice;  // Updated on each fetch
  final DateTime createdAt;

  const InvestmentModel({
    required this.id,
    required this.userId,
    required this.assetId,
    required this.assetSymbol,
    required this.assetName,
    this.assetCategory = 'stock',
    required this.quantity,
    required this.buyPrice,
    this.currentPrice = 0,
    required this.createdAt,
  });

  double get costBasis    => quantity * buyPrice;
  double get currentValue => quantity * currentPrice;
  double get pnl          => currentValue - costBasis;
  double get pnlPercent   => costBasis > 0 ? (pnl / costBasis) * 100 : 0;
  bool   get isProfit     => pnl >= 0;

  Map<String, dynamic> toMap() => {
    'userId':        userId,
    'assetId':       assetId,
    'assetSymbol':   assetSymbol,
    'assetName':     assetName,
    'assetCategory': assetCategory,
    'quantity':      quantity,
    'buyPrice':      buyPrice,
    'currentPrice':  currentPrice,
    'createdAt':     createdAt.toIso8601String(),
  };

  factory InvestmentModel.fromMap(String id, Map<String, dynamic> map) {
    return InvestmentModel(
      id:            id,
      userId:        map['userId'] ?? '',
      assetId:       map['assetId'] ?? '',
      assetSymbol:   map['assetSymbol'] ?? '',
      assetName:     map['assetName'] ?? '',
      assetCategory: map['assetCategory'] ?? 'stock',
      quantity:      (map['quantity'] ?? 0).toDouble(),
      buyPrice:      (map['buyPrice'] ?? 0).toDouble(),
      currentPrice:  (map['currentPrice'] ?? 0).toDouble(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  InvestmentModel copyWith({double? currentPrice, double? quantity}) {
    return InvestmentModel(
      id: id, userId: userId, assetId: assetId,
      assetSymbol: assetSymbol, assetName: assetName,
      assetCategory: assetCategory,
      quantity: quantity ?? this.quantity,
      buyPrice: buyPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      createdAt: createdAt,
    );
  }
}

/// Represents one executed trade (buy or sell)
class TradeModel {
  final String id;
  final String userId;
  final String assetId;
  final String assetSymbol;
  final String assetName;
  final String assetCategory;
  final String action;       // "buy" | "sell"
  final double quantity;
  final double price;        // Execution price
  final double totalUsd;     // quantity * price
  final String aiReasoning;
  final DateTime createdAt;

  const TradeModel({
    required this.id,
    required this.userId,
    required this.assetId,
    required this.assetSymbol,
    required this.assetName,
    this.assetCategory = 'stock',
    required this.action,
    required this.quantity,
    required this.price,
    required this.totalUsd,
    this.aiReasoning = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'userId':        userId,
    'assetId':       assetId,
    'assetSymbol':   assetSymbol,
    'assetName':     assetName,
    'assetCategory': assetCategory,
    'action':        action,
    'quantity':      quantity,
    'price':         price,
    'totalUsd':      totalUsd,
    'aiReasoning':   aiReasoning,
    'createdAt':     createdAt.toIso8601String(),
  };

  factory TradeModel.fromMap(String id, Map<String, dynamic> map) {
    return TradeModel(
      id:            id,
      userId:        map['userId'] ?? '',
      assetId:       map['assetId'] ?? '',
      assetSymbol:   map['assetSymbol'] ?? '',
      assetName:     map['assetName'] ?? '',
      assetCategory: map['assetCategory'] ?? 'stock',
      action:        map['action'] ?? 'buy',
      quantity:      (map['quantity'] ?? 0).toDouble(),
      price:         (map['price'] ?? 0).toDouble(),
      totalUsd:      (map['totalUsd'] ?? 0).toDouble(),
      aiReasoning:   map['aiReasoning'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}
