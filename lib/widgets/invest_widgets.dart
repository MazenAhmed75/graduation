// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/investment_model.dart';
import '../../models/market_asset_model.dart';

// ─── Asset icon helper (replaces emojis with proper icons) ──────────────────

IconData _assetIcon(String category, String symbol) {
  if (category == 'metal')  return Icons.diamond_outlined;
  if (category == 'stock')  return Icons.show_chart;
  // crypto
  return Icons.currency_bitcoin;
}

Color _assetColor(String category) {
  switch (category) {
    case 'metal':  return const Color(0xFFB8860B);   // dark gold
    case 'stock':  return const Color(0xFF1565C0);   // deep blue
    case 'crypto': return const Color(0xFF6A1B9A);   // purple
    default:       return AppTheme.primary;
  }
}

// ─── Portfolio Summary Card ──────────────────────────────────────────────────

class PortfolioSummaryCard extends StatelessWidget {
  final List<InvestmentModel> portfolio;
  final double fundBalance;

  const PortfolioSummaryCard({
    super.key,
    required this.portfolio,
    required this.fundBalance,
  });

  @override
  Widget build(BuildContext context) {
    final totalValue = portfolio.fold(0.0, (s, p) => s + p.currentValue);
    final totalPnl   = portfolio.fold(0.0, (s, p) => s + p.pnl);
    final isProfit   = totalPnl >= 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDim],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PORTFOLIO VALUE',
              style: TextStyle(color: Colors.white70, fontSize: 12,
                  fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Text('\$${totalValue.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 36,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Row(children: [
            Icon(isProfit ? Icons.trending_up : Icons.trending_down,
                color: isProfit ? Colors.greenAccent : Colors.redAccent, size: 16),
            const SizedBox(width: 4),
            Text('${isProfit ? '+' : ''}\$${totalPnl.toStringAsFixed(2)} total P&L',
                style: TextStyle(
                    color: isProfit ? Colors.greenAccent : Colors.redAccent,
                    fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text('Cash: \$${fundBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Asset Price Card ────────────────────────────────────────────────────────

class AssetPriceCard extends StatelessWidget {
  final MarketAssetModel asset;
  final VoidCallback? onTap;

  const AssetPriceCard({super.key, required this.asset, this.onTap});

  @override
  Widget build(BuildContext context) {
    final iconColor = _assetColor(asset.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.18)),
        ),
        child: Row(
          children: [
            // Icon badge
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_assetIcon(asset.category, asset.symbol),
                  color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(asset.name,
                      style: const TextStyle(fontWeight: FontWeight.w600,
                          color: AppTheme.onSurface, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(asset.symbol,
                      style: const TextStyle(fontSize: 12,
                          color: AppTheme.onSurfaceVariant)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(asset.displayPrice,
                    style: const TextStyle(fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface, fontSize: 15)),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (asset.isUp
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFB71C1C))
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      asset.isUp ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 10,
                      color: asset.isUp
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFB71C1C),
                    ),
                    const SizedBox(width: 2),
                    Text(asset.displayChange,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: asset.isUp
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFB71C1C))),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Position Card ───────────────────────────────────────────────────────────

class PositionCard extends StatelessWidget {
  final InvestmentModel position;

  const PositionCard({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    final iconColor = _assetColor(position.assetCategory);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.2)),
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(_assetIcon(position.assetCategory, position.assetSymbol),
              color: iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(position.assetName,
              style: const TextStyle(fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface)),
          Text('${position.quantity.toStringAsFixed(4)} ${position.assetSymbol}',
              style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('\$${position.currentValue.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface)),
          Text('${position.isProfit ? '+' : ''}\$${position.pnl.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: position.isProfit
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFB71C1C))),
        ]),
      ]),
    );
  }
}

// ─── Chat Bubble ─────────────────────────────────────────────────────────────

class ChatBubble extends StatelessWidget {
  final String role;
  final String text;

  const ChatBubble({super.key, required this.role, required this.text});

  bool get isUser => role == 'user';

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primary : AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: isUser
              ? null
              : Border.all(color: AppTheme.outlineVariant.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05),
                blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Text(text,
            style: TextStyle(
                color: isUser ? Colors.white : AppTheme.onSurface,
                height: 1.5, fontSize: 14)),
      ),
    );
  }
}
