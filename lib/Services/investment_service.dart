import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/investment_model.dart';
import '../models/market_asset_model.dart';

/// Manages the user's paper-trading portfolio in Firestore.
///
/// Firestore structure:
///   users/{uid}/portfolio/{assetId}   → InvestmentModel (one doc per asset)
///   users/{uid}/trades/{tradeId}      → TradeModel (one doc per executed trade)
///   users/{uid}/investmentFund        → { balance: double }   (virtual cash)
class InvestmentService {
  final _db = FirebaseFirestore.instance;

  // ── Collection references ─────────────────────────────────────────────────
  CollectionReference _portfolioRef(String uid) =>
      _db.collection('users').doc(uid).collection('portfolio');

  CollectionReference _tradesRef(String uid) =>
      _db.collection('users').doc(uid).collection('trades');

  DocumentReference _fundRef(String uid) =>
      _db.collection('users').doc(uid);

  // ── Investment Fund (virtual cash the AI manages) ─────────────────────────

  /// Stream of the user's available investment cash balance
  Stream<double> getFundBalanceStream(String uid) {
    return _fundRef(uid).snapshots().map((doc) {
      if (!doc.exists) return 0.0;
      final data = doc.data() as Map<String, dynamic>;
      return (data['investmentFund'] ?? 0.0).toDouble();
    });
  }

  /// User deposits more cash into the investment fund
  Future<void> depositToFund(String uid, double amount) async {
    await _fundRef(uid).set(
      {'investmentFund': FieldValue.increment(amount)},
      SetOptions(merge: true),
    );
  }

  /// Deduct cash when buying (called internally)
  Future<void> _deductFromFund(String uid, double amount) async {
    await _fundRef(uid).set(
      {'investmentFund': FieldValue.increment(-amount)},
      SetOptions(merge: true),
    );
  }

  /// Add cash when selling (called internally)
  Future<void> _addToFund(String uid, double amount) async {
    await _fundRef(uid).set(
      {'investmentFund': FieldValue.increment(amount)},
      SetOptions(merge: true),
    );
  }

  // ── Portfolio Streams ─────────────────────────────────────────────────────

  Stream<List<InvestmentModel>> getPortfolioStream(String uid) {
    return _portfolioRef(uid).snapshots().map((snap) => snap.docs
        .map((d) => InvestmentModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList());
  }

  Stream<List<TradeModel>> getTradesStream(String uid) {
    return _tradesRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TradeModel.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList());
  }

  // ── BUY ──────────────────────────────────────────────────────────────────

  /// AI agent calls this to execute a paper buy order.
  /// Returns an error string on failure, or null on success.
  Future<String?> executeBuy({
    required String uid,
    required MarketAssetModel asset,
    required double usdAmount,   // how many USD to spend
    required String aiReasoning,
  }) async {
    // 1. Check fund balance
    final fundDoc = await _fundRef(uid).get();
    final fundData = fundDoc.data() as Map<String, dynamic>?;
    final balance  = (fundData?['investmentFund'] ?? 0.0).toDouble();

    if (balance < usdAmount) {
      return 'Insufficient funds. Fund balance: \$${balance.toStringAsFixed(2)}, '
             'required: \$${usdAmount.toStringAsFixed(2)}';
    }

    final quantity = usdAmount / asset.price;
    final batch    = _db.batch();

    // 2. Upsert portfolio position (merge with existing holding)
    final posRef = _portfolioRef(uid).doc(asset.id);
    final posSnap = await posRef.get();

    if (posSnap.exists) {
      // Average down / up the cost basis
      final existing  = InvestmentModel.fromMap(posSnap.id, posSnap.data() as Map<String, dynamic>);
      final newQty    = existing.quantity + quantity;
      final newAvgPx  = ((existing.quantity * existing.buyPrice) + usdAmount) / newQty;
      batch.update(posRef, {'quantity': newQty, 'buyPrice': newAvgPx, 'currentPrice': asset.price});
    } else {
      final model = InvestmentModel(
        assetName: asset.name,
        id: asset.id, userId: uid,
        assetId: asset.id, assetSymbol: asset.symbol,
        quantity: quantity, buyPrice: asset.price,
        currentPrice: asset.price, createdAt: DateTime.now(),
      );
      batch.set(posRef, model.toMap());
    }

    // 3. Log the trade
    final tradeRef = _tradesRef(uid).doc();
    final trade = TradeModel(
      id: tradeRef.id, userId: uid,
      assetId: asset.id, assetSymbol: asset.symbol,
      assetName: asset.name,
      action: 'buy', quantity: quantity,
      price: asset.price, totalUsd: usdAmount,
      aiReasoning: aiReasoning, createdAt: DateTime.now(),
    );
    batch.set(tradeRef, trade.toMap());

    await batch.commit();

    // 4. Deduct from fund
    await _deductFromFund(uid, usdAmount);
    return null; // success
  }

  // ── SELL ─────────────────────────────────────────────────────────────────

  /// AI agent calls this to execute a paper sell order.
  Future<String?> executeSell({
    required String uid,
    required MarketAssetModel asset,
    required double sellFraction, // 0.0–1.0 of the position
    required String aiReasoning,
  }) async {
    final posRef  = _portfolioRef(uid).doc(asset.id);
    final posSnap = await posRef.get();

    if (!posSnap.exists) {
      return 'No position found for ${asset.name}';
    }

    final position = InvestmentModel.fromMap(posSnap.id, posSnap.data() as Map<String, dynamic>);
    final sellQty  = position.quantity * sellFraction.clamp(0.0, 1.0);
    final proceeds = sellQty * asset.price;
    final batch    = _db.batch();

    // Update or remove the position
    final remaining = position.quantity - sellQty;
    if (remaining < 0.000001) {
      batch.delete(posRef);
    } else {
      batch.update(posRef, {'quantity': remaining, 'currentPrice': asset.price});
    }

    // Log the trade
    final tradeRef = _tradesRef(uid).doc();
    final trade = TradeModel(
      id: tradeRef.id, userId: uid,
      assetId: asset.id, assetSymbol: asset.symbol,
      assetName: asset.name,
      action: 'sell', quantity: sellQty,
      price: asset.price, totalUsd: proceeds,
      aiReasoning: aiReasoning, createdAt: DateTime.now(),
    );
    batch.set(tradeRef, trade.toMap());

    await batch.commit();
    await _addToFund(uid, proceeds);
    return null;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Update current prices in portfolio (for P&L display)
  Future<void> refreshPortfolioPrices(
      String uid, List<MarketAssetModel> liveAssets) async {
    final batch = _db.batch();
    for (final asset in liveAssets) {
      final ref = _portfolioRef(uid).doc(asset.id);
      final snap = await ref.get();
      if (snap.exists) {
        batch.update(ref, {'currentPrice': asset.price});
      }
    }
    await batch.commit();
  }

  /// Summarize portfolio for Gemini prompt
  String buildPortfolioSummary(List<InvestmentModel> positions, double fundBalance) {
    if (positions.isEmpty) {
      return 'Portfolio: empty\nAvailable cash: \$${fundBalance.toStringAsFixed(2)}';
    }
    final lines = positions.map((p) =>
        '- ${p.assetName} (${p.assetSymbol}): '
        '${p.quantity.toStringAsFixed(6)} units @ \$${p.buyPrice.toStringAsFixed(2)} avg. '
        'Value: \$${p.currentValue.toStringAsFixed(2)} '
        'P&L: ${p.isProfit ? '+' : ''}\$${p.pnl.toStringAsFixed(2)} '
        '(${p.pnlPercent.toStringAsFixed(1)}%)').join('\n');
    return 'Portfolio:\n$lines\nAvailable cash: \$${fundBalance.toStringAsFixed(2)}';
  }
}
