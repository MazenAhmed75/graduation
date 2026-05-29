import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/transaction_model.dart';
import '../services/budget_service.dart';
import '../services/auth_service.dart';
import 'package:mindful_curator/l10n/app_localizations.dart';
import '../utils/category_localization.dart';
import '../utils/budget_categories.dart';
import 'package:intl/intl.dart';
import '../utils/currency_formatter.dart'

// ============================================================
// TransactionsScreen
//
// A full-screen transaction history with:
//   - Real-time search by note or category name
//   - Filter by type (all / income / expense)
//   - Filter by category
//   - Sort by newest or largest amount
// ============================================================

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final BudgetService _budgetService = BudgetService();
  final AuthService _authService = AuthService();

  // ── Search & filter state ────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _typeFilter = 'all';      // 'all' | 'withdraw' | 'deposit'
  String _categoryFilter = 'all';  // 'all' | any budgetTitle
  String _sortBy = 'newest';       // 'newest' | 'largest'

  //  Constant reload fix
  late Stream<List<TransactionModel>> _transactionsStream;

// initialize the stream connection exactly once
  @override
  void initState() {
    super.initState();
    final userId = _authService.currentUser?.uid ?? '';
    _transactionsStream = _budgetService.getAllTransactionsStream(userId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Apply search + filters + sort to the full list ───────────
  List<TransactionModel> _applyFilters(List<TransactionModel> all) {
    var result = all.where((t) {
      // Get the correct string to display/filter by /// Dynamic translation fix
      final displayTitle = (t.categoryKey == 'custom' && budgetCategories.any((c) => c.key == t.customTitle))
          ? CategoryLocalization.getCategoryName(context, t.customTitle, '')
          : CategoryLocalization.getCategoryName(context, t.categoryKey, t.customTitle);

      // Search: matches note or category name
      final query = _searchQuery.toLowerCase();
      final matchesSearch = query.isEmpty ||
          t.note.toLowerCase().contains(query) ||
          displayTitle.toLowerCase().contains(query);

      // Type filter
      final matchesType =
          _typeFilter == 'all' || t.type == _typeFilter;

      // Category filter
      final matchesCategory =
          _categoryFilter == 'all' || displayTitle == _categoryFilter;

      return matchesSearch && matchesType && matchesCategory;
    }).toList();

    // Sort
    if (_sortBy == 'newest') {
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      result.sort((a, b) => b.amount.compareTo(a.amount));
    }

    return result;
  }

  // ── Extract unique category names for the filter chip list ───
  List<String> _getCategories(List<TransactionModel> all) {
    //Dynamic translation fix
    final cats = all.map(
          (t) => (t.categoryKey == 'custom' && budgetCategories.any((c) => c.key == t.customTitle))
          ? CategoryLocalization.getCategoryName(context, t.customTitle, '')
          : CategoryLocalization.getCategoryName(context, t.categoryKey, t.customTitle),
    ).toSet().toList();
    cats.sort();
    return cats;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final userId = _authService.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppTheme.neutral,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF2),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 70,
        titleSpacing: 24,
        title: Text(l10n.transactions,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<List<TransactionModel>>(
        stream: _transactionsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // checks if there is error and pass it to the error handling method
          if (snapshot.hasError) {
            return _buildBackendErrorState(snapshot.error.toString());
          }

          final all = snapshot.data ?? [];
          final filtered = _applyFilters(all);
          final categories = _getCategories(all);

          return Column(
            children: [
              // ── Search bar + sort ──────────────────────────────
              _buildSearchBar(),
              // ── Type filter chips ──────────────────────────────
              _buildTypeFilters(),
              // ── Category filter chips (only if >1 category) ───
              if (categories.length > 1)
                _buildCategoryFilters(categories),
              // ── Summary row ────────────────────────────────────
              _buildSummaryRow(filtered),
              // ── Transaction list ───────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  padding: EdgeInsets.only(
                    top: 8,
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).padding.bottom + 32,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    // ── Date separator ─────────────────────
                    final t = filtered[index];
                    final showDate = index == 0 ||
                        !_isSameDay(filtered[index - 1].createdAt, t.createdAt);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDate) _buildDateLabel(t.createdAt),
                        _TransactionTile(transaction: t),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Search bar ───────────────────────────────────────────────
  Widget _buildSearchBar() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E342B).withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  hintStyle: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.close_rounded, color: Colors.grey[400], size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // ── Sort button ───────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _sortBy = _sortBy == 'newest' ? 'largest' : 'newest'),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E342B).withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _sortBy == 'newest'
                        ? Icons.access_time_rounded
                        : Icons.arrow_downward_rounded,
                    size: 18,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _sortBy == 'newest' ? l10n.newest : l10n.largest,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Type filter chips: All / Expenses / Income ───────────────
  Widget _buildTypeFilters() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          _TypeChip(
            label: l10n.all,
            selected: _typeFilter == 'all',
            onTap: () => setState(() => _typeFilter = 'all'),
          ),
          const SizedBox(width: 8),
          _TypeChip(
            label: l10n.expenses,
            selected: _typeFilter == 'withdraw',
            color: const Color(0xFFE24B4A),
            onTap: () => setState(() => _typeFilter = 'withdraw'),
          ),
          const SizedBox(width: 8),
          _TypeChip(
            label: l10n.income,
            selected: _typeFilter == 'deposit',
            color: AppTheme.primary,
            onTap: () => setState(() => _typeFilter = 'deposit'),
          ),
        ],
      ),
    );
  }

  // ── Category filter chips ─────────────────────────────────────
  Widget _buildCategoryFilters(List<String> categories) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        children: [
          _TypeChip(
            label: l10n.allCategories,
            selected: _categoryFilter == 'all',
            onTap: () => setState(() => _categoryFilter = 'all'),
          ),
          ...categories.map((cat) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _TypeChip(
              label: cat,
              selected: _categoryFilter == cat,
              onTap: () => setState(() => _categoryFilter = cat),
            ),
          )),
        ],
      ),
    );
  }

  // ── Summary row: total results + net amount ──────────────────
  Widget _buildSummaryRow(List<TransactionModel> filtered) {
    final l10n = AppLocalizations.of(context)!;
    final totalIn = filtered.where((t) => t.type == 'deposit').fold(0.0, (s, t) => s + t.amount);
    final totalOut = filtered.where((t) => t.type == 'withdraw').fold(0.0, (s, t) => s + t.amount);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(
            //  NEW LOCALIZED LINE:
            l10n.transactionsCount(NumberFormat.decimalPattern(Localizations.localeOf(context).languageCode).format(filtered.length)),
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
            //  NEW LOCALIZED BLOCK:
            final locale = Localizations.localeOf(context).languageCode;

    if (totalIn > 0)
    Text(
    '+ ${CurrencyFormatter.format(totalIn, locale)}',
    style: const TextStyle(
    fontFamily: 'Manrope',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppTheme.primary,
    ),
    ),
    if (totalIn > 0 && totalOut > 0)
    Text('  ', style: TextStyle(color: Colors.grey[300])),
    if (totalOut > 0)
    Text(
    '- ${CurrencyFormatter.format(totalOut, locale)}',
    style: const TextStyle(
    fontFamily: 'Manrope',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFFE24B4A),
    ),
    ),
        ],
      ),
    );
  }

  // ── Date separator label ─────────────────────────────────────
  Widget _buildDateLabel(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    String label;

    if (_isSameDay(date, now)) {
      label = l10n.today;
    } else if (_isSameDay(date, yesterday)) {
      label = l10n.yesterday;
    } else {
      label = MaterialLocalizations.of(context).formatMediumDate(date);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────
  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    final hasFilters = _searchQuery.isNotEmpty || _typeFilter != 'all' || _categoryFilter != 'all';

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
              child: Icon(
                hasFilters ? Icons.search_off_rounded : Icons.receipt_long_rounded,
                size: 40,
                color: AppTheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasFilters ? l10n.noResults : l10n.noTransactions,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters ? l10n.noResultsHint : l10n.noTransactionsHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () => setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _typeFilter = 'all';
                  _categoryFilter = 'all';
                }),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.clearFilters),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}


// back end error handling in ui
Widget _buildBackendErrorState(String errorDetails) {
  final l10n = AppLocalizations.of(context)!;
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFFE24B4A)),
          const SizedBox(height: 16),
          Text(
            l10n.backendErrorTitle,
            style: const TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.backendErrorSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Manrope', fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    ),
  );
}

// ============================================================
// _TypeChip — reusable filter chip
// ============================================================
class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Removed unused l10n definition here
    final activeColor = color ?? AppTheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? activeColor : Colors.grey.withOpacity(0.2),
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: activeColor.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// _TransactionTile — a single transaction row
// ============================================================
class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    // Added missing localizations lookup
    final l10n = AppLocalizations.of(context)!;

    //  NEW LOCALIZED CHUNK:
    final locale = Localizations.localeOf(context).languageCode;
    final isWithdraw = transaction.type == 'withdraw';
    final color = isWithdraw ? const Color(0xFFE24B4A) : AppTheme.primary;
    final bgColor = isWithdraw
        ? const Color(0xFFE24B4A).withOpacity(0.08)
        : AppTheme.primaryContainer;

// Formats currency dynamically via your helper
    final amountLabel = isWithdraw
        ? '- ${CurrencyFormatter.format(transaction.amount, locale)}'
        : '+ ${CurrencyFormatter.format(transaction.amount, locale)}';

// Automatically handles localized hours, padded minutes, and AM/PM strings out-of-the-box!
    final timeLabel = DateFormat.jm(locale).format(transaction.createdAt);

    // Auto tag for recurring
    final isAuto = transaction.note.startsWith(l10n.auto);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E342B).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // ── Icon ──────────────────────────────────────────────
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              isWithdraw
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          // ── Note + category ───────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        // Dynamic translation fix
                        transaction.note.isNotEmpty
                            ? transaction.note.replaceFirst('[Auto] ', '')
                            : ((transaction.categoryKey == 'custom' && budgetCategories.any((c) => c.key == transaction.customTitle))
                            ? CategoryLocalization.getCategoryName(context, transaction.customTitle, '')
                            : CategoryLocalization.getCategoryName(context, transaction.categoryKey, transaction.customTitle)),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isAuto) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),

                        child: Text(
                          l10n.auto,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    // Dynamic translation fix
                    Text(
                      (transaction.categoryKey == 'custom' && budgetCategories.any((c) => c.key == transaction.customTitle))
                          ? CategoryLocalization.getCategoryName(context, transaction.customTitle, '')
                          : CategoryLocalization.getCategoryName(context, transaction.categoryKey, transaction.customTitle),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                    Text(
                      '  ·  $timeLabel',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
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
        ],
      ),
    );
  }
}