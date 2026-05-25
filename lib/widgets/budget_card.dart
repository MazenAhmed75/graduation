// ignore_for_file: unnecessary_non_null_assertion, deprecated_member_use

import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:mindful_curator/l10n/app_localizations.dart';

class BudgetCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final String spentText;
  final String leftText;
  final double fillRatio;
  final String insight;
  final IconData insightIcon;
  final Color insightColor;
  final Color progressColor;
  final IconData iconData;
  final Color iconBg;
  final Color iconColor;
  final Color spentColor;
  // 1. Add leftTextColor parameter + make onDeposit nullable
  final VoidCallback? onDeposit;      // 👈 was VoidCallback (non-nullable)
  final Color? leftTextColor;         // 👈 add this new parameter
  final VoidCallback onWithdraw;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BudgetCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.spentText,
    required this.leftText,
    required this.fillRatio,
    required this.insight,
    required this.insightIcon,
    required this.insightColor,
    required this.progressColor,
    required this.iconData,
    required this.iconBg,
    required this.iconColor,
    required this.spentColor,
    this.onDeposit,
    this.leftTextColor,
    required this.onWithdraw,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E342B).withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: iconColor),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.allocated.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.outline,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fillRatio,
              child: Container(
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                spentText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: spentColor,
                ),
              ),
              Text(
                leftText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: leftTextColor ?? AppTheme.onSurfaceVariant, //  use leftTextColor
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  Icons.add,
                  AppLocalizations.of(context)!.deposit,
                  AppTheme.primary,
                  AppTheme.surfaceContainer,
                  onDeposit,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  Icons.remove,
                  AppLocalizations.of(context)!.withdraw,
                  AppTheme.onSurfaceVariant,
                  AppTheme.surfaceContainer,
                  onWithdraw,
                ),
              ),
              const SizedBox(width: 8),
              _buildIconButton(Icons.edit, AppTheme.onSurfaceVariant, AppTheme.surfaceContainer, onEdit),
              const SizedBox(width: 8),
              _buildIconButton(Icons.delete, AppTheme.outline, AppTheme.surfaceContainer, onDelete),
            ],
          ),
          const SizedBox(height: 12),
          // Insight
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(insightIcon, color: insightColor, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    insight,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, Color bg, VoidCallback? onTap,) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isDisabled ? Colors.grey[300] : color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: isDisabled ? Colors.grey[300] : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 38,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
