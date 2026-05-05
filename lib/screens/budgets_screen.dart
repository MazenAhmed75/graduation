import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/budget_model.dart';
import '../models/monthly_budget_model.dart';
import '../models/user_model.dart'; // ← NEW: User model for profile image
import '../utils/currency_formatter.dart';
import '../widgets/budget_card.dart';
import '../services/budget_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart'; // ← NEW: User service

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  // ============================================================
  // STEP 1: Create service instances
  // ============================================================
  final BudgetService _budgetService = BudgetService();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService(); // ← NEW

  // ─── Helpers: current month as "YYYY-MM" and display name ─────────────────

  String get _currentMonthId {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  String get _currentMonthName {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[now.month - 1]} ${now.year}';
  }

  // ─── Dialogs: Monthly Budget ───────────────────────────────────────────────

  /// Called when no monthly budget exists yet, or user wants to edit it.
  void _showSetMonthlyBudgetDialog({MonthlyBudgetModel? existing}) {
    final controller = TextEditingController(
      text: existing != null ? existing.totalAmount.toStringAsFixed(2) : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null
            ? 'Set $_currentMonthName Budget'
            : 'Edit Monthly Budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the total amount of money you have available this month.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Total Monthly Budget (\$)',
                hintText: 'e.g. 3000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text) ?? 0.0;
              if (amount > 0) {
                await _budgetService.setMonthlyBudget(
                  userId: _authService.currentUser!.uid,
                  monthId: _currentMonthId,
                  totalAmount: amount,
                );
              }
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: const Color(0xFFEBFFE0),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ─── Dialogs: Category Budgets ─────────────────────────────────────────────

  void _addCategoryDialog({
    required MonthlyBudgetModel monthly,
    required List<BudgetModel> existing,
  }) {
    // How much of the monthly budget is still unassigned to categories
    final totalAllocated =
    existing.fold(0.0, (sum, b) => sum + b.allocated);
    final remaining = monthly.totalAmount - totalAllocated;

    if (remaining <= 0) {
      // All money is already allocated — show a friendly message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Fully Allocated'),
          content: Text(
            'You have allocated all \$${monthly.totalAmount.toStringAsFixed(2)} '
                'of your $_currentMonthName budget. '
                'Edit or delete a category to free up money before adding a new one.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category Budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show how much is still available to assign
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: AppTheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    'Available to assign: \$${remaining.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppTheme.onPrimaryContainer,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g. Groceries',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount (\$)',
                hintText: 'Max: \$${remaining.toStringAsFixed(2)}',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              final title = titleController.text.trim().isEmpty
                  ? 'New Category'
                  : titleController.text.trim();

              if (amount <= 0) return;

              // Guard: don't let the user allocate more than what's left
              if (amount > remaining) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Amount exceeds remaining budget '
                          '(\$${remaining.toStringAsFixed(2)} left)',
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              await _budgetService.addBudget(
                userId: _authService.currentUser!.uid,
                monthlyBudgetId: _currentMonthId,
                title: title,
                subtitle: 'Category',
                allocated: amount,
                iconName: 'category',
                colorScheme: 'green',
              );
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: const Color(0xFFEBFFE0),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // ─── Dialogs: Deposit / Withdraw / Edit / Delete ───────────────────────────
  // These are identical to your original code.

  // ============================================================
  // DIALOG: Deposit money into a budget
  // ============================================================
  void _showAddMoneyDialog(BudgetModel budget) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Money (Deposit)'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount (\$)',
            hintText: 'Enter amount to deposit',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text) ?? 0.0;
              if (amount > 0) {
                await _budgetService.deposit(
                  userId: _authService.currentUser!.uid,
                  budget: budget,
                  amount: amount,
                );
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Deposit'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIALOG: Withdraw / Spend from a budget
  // ============================================================
  void _showSubtractMoneyDialog(BudgetModel budget) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subtract Money (Withdraw/Spend)'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount (\$)',
            hintText: 'Enter amount to withdraw',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text) ?? 0.0;
              if (amount > 0) {
                await _budgetService.withdraw(
                  userId: _authService.currentUser!.uid,
                  budget: budget,
                  amount: amount,
                );
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIALOG: Edit the allocated amount
  // ============================================================
  void _showEditBudgetDialog(BudgetModel budget) {
    final controller =
    TextEditingController(text: budget.allocated.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Budget Amount'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Allocated Amount (\$)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text) ?? 0.0;
              if (amount > 0) {
                await _budgetService.editAllocated(
                  userId: _authService.currentUser!.uid,
                  budgetId: budget.id,
                  newAllocated: amount,
                );
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIALOG: Delete a budget with confirmation
  // ============================================================
  void _deleteBudget(BudgetModel budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Are you sure you want to delete "${budget.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _budgetService.deleteBudget(
                userId: _authService.currentUser!.uid,
                budgetId: budget.id,
              );
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ─── Widgets ───────────────────────────────────────────────────────────────

  /// The card at the top of the list showing the monthly budget summary.
  Widget _buildMonthlyBudgetCard({
    required MonthlyBudgetModel monthly,
    required List<BudgetModel> categories,
  }) {
    final totalAllocated =
    categories.fold(0.0, (sum, b) => sum + b.allocated);
    final unallocated = monthly.totalAmount - totalAllocated;
    final allocationRatio =
    (totalAllocated / monthly.totalAmount).clamp(0.0, 1.0);
    final isFullyAllocated = unallocated <= 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: month name + edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currentMonthName,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () =>
                    _showSetMonthlyBudgetDialog(existing: monthly),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, color: Colors.white, size: 13),
                      SizedBox(width: 4),
                      Text('Edit',
                          style: TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Total amount
          Text(
            CurrencyFormatter.format(monthly.totalAmount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Total Monthly Budget',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),
          // Allocation progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: allocationRatio,
              minHeight: 6,
              backgroundColor: Colors.white24,
              valueColor:
              const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          // Allocated vs Unallocated row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _budgetStat(
                label: 'Allocated to categories',
                value: CurrencyFormatter.format(totalAllocated),
                color: Colors.white,
              ),
              _budgetStat(
                label: isFullyAllocated ? 'Fully allocated ✓' : 'Unallocated',
                value: isFullyAllocated
                    ? ''
                    : CurrencyFormatter.format(unallocated),
                color: isFullyAllocated
                    ? const Color(0xFFEBFFE0)
                    : Colors.white70,
                alignRight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _budgetStat({
    required String label,
    required String value,
    required Color color,
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment:
      alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w400)),
        if (value.isNotEmpty)
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
      ],
    );
  }

  /// Full-screen empty state shown when no monthly budget exists yet.
  Widget _buildNoMonthlyBudget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.calendar_month,
                  size: 36, color: AppTheme.onPrimaryContainer),
            ),
            const SizedBox(height: 20),
            Text(
              'No budget for $_currentMonthName',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start by setting the total amount of money you have available this month. Then break it down into categories.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _showSetMonthlyBudgetDialog,
              icon: const Icon(Icons.add),
              label: Text('Set $_currentMonthName Budget'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: const Color(0xFFEBFFE0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }
    final String userId = currentUser.uid;

    return Scaffold(
      backgroundColor: AppTheme.neutral,

      // ======================================================
      // APP BAR with real profile picture from Firestore
      // (NOW WITH REAL USER IMAGE FROM FIREBASE)
      // ======================================================
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF2),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 70,
        titleSpacing: 24,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Budgets'),

            // ← NEW: Live user profile image
            StreamBuilder<UserModel?>(
              stream: _userService.getUserStream(userId),
              builder: (context, snapshot) {
                final user = snapshot.data;
                return Container(
                  width: 40,
                  height: 40,
                  decoration:
                  const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child: user?.photoUrl != null &&
                        user!.photoUrl.isNotEmpty
                        ? Image.network(user.photoUrl,
                        fit: BoxFit.cover)
                        : const Icon(Icons.person),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // ─── BODY: outer stream = monthly budget ───────────────────────────────
      // ======================================================
      // STREAM BUILDER (FIREBASE REAL-TIME)
      // ======================================================
      body: StreamBuilder<MonthlyBudgetModel?>(
        stream:
        _budgetService.getMonthlyBudgetStream(userId, _currentMonthId),
        builder: (context, monthlySnapshot) {
          // Loading
          if (monthlySnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final monthly = monthlySnapshot.data;

          // No monthly budget yet → show setup screen (no FAB needed)
          if (monthly == null) {
            return _buildNoMonthlyBudget();
          }

          // Monthly budget exists → stream categories
          return StreamBuilder<List<BudgetModel>>(
            stream: _budgetService.getCategoryBudgetsStream(
                userId, _currentMonthId),
            builder: (context, categoriesSnapshot) {
              if (categoriesSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        const Text('Failed to load categories',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          categoriesSnapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (categoriesSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final categories = categoriesSnapshot.data ?? [];

              return Stack(
                children: [
                  ListView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 100,
                    ),
                    children: [
                      // ── Monthly budget summary card ──
                      _buildMonthlyBudgetCard(
                        monthly: monthly,
                        categories: categories,
                      ),

                      // ── Categories section header ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                        child: Row(
                          children: [
                            Text(
                              'Categories',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${categories.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Empty categories state ──
                      if (categories.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                          child: Column(
                            children: [
                              Icon(Icons.pie_chart_outline,
                                  size: 48,
                                  color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text(
                                'No categories yet',
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap + to divide your budget into categories.',
                                style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                      // ── Category budget cards ──
                      ...categories.map((budget) => BudgetCard(
                        title: budget.title,
                        subtitle: budget.subtitle,
                        amount: CurrencyFormatter.format(
                            budget.allocated),
                        spentText:
                        '\$${budget.spent.toStringAsFixed(2)} spent',
                        leftText:
                        '\$${budget.remaining.toStringAsFixed(2)} left',
                        fillRatio: budget.spentRatio,
                        iconData: Icons.category,
                        progressColor: AppTheme.primary,
                        iconBg: AppTheme.primaryContainer,
                        iconColor: AppTheme.onPrimaryContainer,
                        spentColor: AppTheme.primary,
                        insight: '',
                        insightIcon: Icons.info,
                        insightColor: AppTheme.primary,
                        onDeposit: () =>
                            _showAddMoneyDialog(budget),
                        onWithdraw: () =>
                            _showSubtractMoneyDialog(budget),
                        onEdit: () =>
                            _showEditBudgetDialog(budget),
                        onDelete: () => _deleteBudget(budget),
                      )),
                    ],
                  ),

                  // ── FAB (positioned inside Stack so it floats over list) ──
                  // ======================================================
                  // FLOATING ACTION BUTTON (FIXED - ONLY ONE)
                  // ======================================================
                  Positioned(
                    right: 16,
                    bottom:
                    MediaQuery.of(context).padding.bottom + 76,
                    child: FloatingActionButton(
                      onPressed: () => _addCategoryDialog(
                        monthly: monthly,
                        existing: categories,
                      ),
                      backgroundColor: AppTheme.primary,
                      foregroundColor: const Color(0xFFEBFFE0),
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}