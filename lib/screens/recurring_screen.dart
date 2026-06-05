import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/recurring_transaction_model.dart';
import '../services/recurring_service.dart';
import '../services/auth_service.dart';
import 'package:mindful_curator/l10n/app_localizations.dart';
import '../utils/category_localization.dart';
import '../utils/budget_categories.dart';
import 'package:intl/intl.dart';
import '../utils/currency_formatter.dart';

// ============================================================
// RecurringScreen
//
// A standalone screen that lists all the user's recurring
// transactions. Users can pause, resume, or delete them.
// ============================================================
class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = AuthService();
    final service = RecurringService();
    final userId = auth.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppTheme.neutral,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF2),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 70,
        titleSpacing: 24,
        title: Text(
          l10n.recurring,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<List<RecurringTransactionModel>>(
        stream: service.getRecurringStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          // ── Empty state ─────────────────────────────────────
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.repeat_rounded,
                        size: 40,
                        color: AppTheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.noRecurringTitle,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.noRecurringSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ── List of recurring items ──────────────────────────
          return ListView.builder(
            padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 32,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _RecurringCard(
                item: item,
                onToggle: (newValue) async {
                  await service.toggleActive(
                    userId: userId,
                    recurringId: item.id,
                    isActive: newValue,
                  );
                },
                onDelete: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.deleteBudget), // Replaced with existing key or placeholder
                      content: Text(item.note),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await service.deleteRecurring(
                      userId: userId,
                      recurringId: item.id,
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// _RecurringCard
// A single recurring transaction card with toggle + delete
// ============================================================
class _RecurringCard extends StatelessWidget {
  final RecurringTransactionModel item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _RecurringCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final isWithdraw = item.type == 'withdraw';
    final color = isWithdraw ? const Color(0xFFE24B4A) : AppTheme.primary;
    final bgColor = isWithdraw
        ? const Color(0xFFE24B4A).withOpacity(0.08)
        : AppTheme.primaryContainer;

    // 1. Get the current locale
    final locale = Localizations.localeOf(context).languageCode;

    // 2. Format the amount safely using your custom formatter
    final formattedAmount = CurrencyFormatter.format(item.amount, locale);
    final amountLabel = isWithdraw ? '- $formattedAmount' : '+ $formattedAmount';

    // Use DateFormat for native localized months (Arabic/English)
    final monthLabel = DateFormat('MMM', locale).format(item.nextDueDate);
    final due = '$monthLabel ${item.nextDueDate.day.toString().toLocalizedDigits(locale)}';

    // Dynamic translation fix (Scans for keywords like "travel" inside fallback text)
    String displayNote = item.note;
    final cleanKey = item.note.replaceAll(RegExp(r'\(recurring\)|recurring', caseSensitive: false), '').trim();

    String? matchedCategoryKey;
    for (final c in budgetCategories) {
      if (cleanKey.toLowerCase().contains(c.key.toLowerCase()) ||
          item.budgetTitle.toLowerCase().contains(c.key.toLowerCase())) {
        matchedCategoryKey = c.key.toLowerCase();
        break;
      }
    }

    if (matchedCategoryKey != null) {
      final localizedCategory = CategoryLocalization.getCategoryName(context, matchedCategoryKey, item.note);
      displayNote = '$localizedCategory (${l10n.recurring})';
    }


    String displayFrequency = item.frequencyLabel;
    final freqLower = item.frequencyLabel.toLowerCase();

    if (freqLower.contains('month')) {
      displayFrequency = l10n.everyMonth;
    } else if (freqLower.contains('week')) {
      displayFrequency = l10n.everyWeek;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: item.isActive ? Colors.white : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isActive ? Colors.transparent : Colors.grey.withOpacity(0.2),
        ),
        boxShadow: item.isActive
            ? [
          BoxShadow(
            color: const Color(0xFF2E342B).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ]
            : [],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // ── Icon ──────────────────────────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isWithdraw ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),

          // ── Details ───────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayNote, // 👈 Now uses the dynamic localized string!
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: item.isActive ? AppTheme.onSurface : Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration:  BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      // Dynamic translation fix (Case-insensitive check)
                      child: Text(
                        budgetCategories.any((c) => c.key.toLowerCase() == item.budgetTitle.toLowerCase())
                            ? CategoryLocalization.getCategoryName(context, item.budgetTitle.toLowerCase(), item.budgetTitle)
                            : item.budgetTitle,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
                          color: AppTheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.repeat_rounded, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 3),
                    Text(
                      displayFrequency, // dynamically pulls from ARB files
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                // Next due date
                if (item.isActive) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.nextDue(due),
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Amount ────────────────────────────────────────────
          Text(
            amountLabel,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 12),

          // ── Actions: toggle + delete ──────────────────────────
          Column(
            children: [
              Switch(
                value: item.isActive,
                onChanged: onToggle,
                activeColor: AppTheme.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              GestureDetector(
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey[400]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}