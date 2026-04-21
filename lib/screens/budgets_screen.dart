import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/budget_model.dart';  // ← CHANGED: Use BudgetModel instead of BudgetItemModel
import '../utils/currency_formatter.dart';
import '../widgets/budget_card.dart';
import '../services/budget_service.dart';  // ← NEW: Import the service
import '../services/auth_service.dart';    // ← NEW: Import auth service

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  // ============================================================
  // STEP 1: Create service instances (replaces hardcoded list)
  // ============================================================
  final BudgetService _budgetService = BudgetService();
  final AuthService _authService = AuthService();

  // ============================================================
  // REMOVED: No more hardcoded budgets list or initState
  // ============================================================

  // ============================================================
  // DIALOG: Add Money (Deposit) - NOW CALLS FIREBASE
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
                // ← CHANGED: Call Firebase service instead of setState
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
  // DIALOG: Subtract Money (Withdraw) - NOW CALLS FIREBASE
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
                // ← CHANGED: Call Firebase service instead of setState
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
  // DIALOG: Edit Budget Amount - NOW CALLS FIREBASE
  // ============================================================
  void _showEditBudgetDialog(BudgetModel budget) {
    final controller = TextEditingController(
      text: budget.allocated.toStringAsFixed(2),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Total Budget'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Allocated Amount (\$)',
            hintText: 'Enter new total budget',
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
                // ← CHANGED: Call Firebase service instead of setState
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
  // DIALOG: Delete Budget - NOW CALLS FIREBASE
  // ============================================================
  void _deleteBudget(BudgetModel budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text(
          'Are you sure you want to delete the "${budget.title}" budget?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // ← CHANGED: Call Firebase service instead of setState
              await _budgetService.deleteBudget(
                userId: _authService.currentUser!.uid,
                budgetId: budget.id,
              );
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIALOG: Add New Budget - NOW CALLS FIREBASE
  // ============================================================
  void _addBudgetDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Budget Name',
                hintText: 'e.g. Dining Out',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Allocated Amount (\$)',
                hintText: 'Enter total budget',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              final title = titleController.text.trim().isEmpty
                  ? 'New Budget'
                  : titleController.text.trim();

              if (amount > 0) {
                // ← CHANGED: Call Firebase service instead of setState
                await _budgetService.addBudget(
                  userId: _authService.currentUser!.uid,
                  title: title,
                  subtitle: 'Custom Budget',
                  allocated: amount,
                  iconName: 'category',
                  colorScheme: 'green',
                );
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPER: Map color scheme string to actual Color objects
  // BudgetModel stores "green", "blue", etc. as strings
  // BudgetCard needs actual Color objects
  // ============================================================
  Map<String, Color> _getColorsForScheme(String colorScheme) {
    switch (colorScheme) {
      case 'green':
        return {
          'iconBg': AppTheme.primaryContainer,
          'iconColor': AppTheme.onPrimaryContainer,
          'progressColor': AppTheme.primary,
          'spentColor': AppTheme.primary,
        };
      case 'blue':
        return {
          'iconBg': AppTheme.secondaryContainer,
          'iconColor': AppTheme.onSecondaryContainer,
          'progressColor': AppTheme.secondary,
          'spentColor': AppTheme.secondary,
        };
      case 'yellow':
        return {
          'iconBg': AppTheme.tertiaryContainer,
          'iconColor': AppTheme.onTertiaryContainer,
          'progressColor': AppTheme.tertiary,
          'spentColor': AppTheme.tertiary,
        };
      default:
        return {
          'iconBg': AppTheme.surfaceContainer,
          'iconColor': AppTheme.onSurface,
          'progressColor': AppTheme.primary,
          'spentColor': AppTheme.primary,
        };
    }
  }

  // ============================================================
  // HELPER: Map icon name string to IconData
  // BudgetModel stores "shopping_cart" as a string
  // BudgetCard needs actual IconData objects
  // ============================================================
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'home':
        return Icons.home;
      case 'theater_comedy':
        return Icons.theater_comedy;
      case 'flight_takeoff':
        return Icons.flight_takeoff;
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      default:
        return Icons.category;
    }
  }

  // ============================================================
  // BUILD METHOD - THIS IS WHERE StreamBuilder GOES
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF2),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 70,
        titleSpacing: 24,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.menu, color: AppTheme.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surfaceContainerLow,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Budgets',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryContainer, width: 2),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCu_Bmj45LQpHl3UftPpWx7HabSOB9vpBs0cWqgS7LRu2ILxRcWQNB6HmxGiBO4dQxqa4vmPknAVQGA5C3-U8WQIDFL69Bzp5eYuKnBMdupVQBF4zTkZT9y_-54gs9xJmKLVBhLo6pBWpkRzbixUBcHqDPHmlPLHlV9z7eW2FUHZPGZDE2A_Krm72Ew1G0wEig6AICCIkIBAUlLkoFLwfxIlvUxYNQ09UA0V-E63vaNno2f4dlR3MABHbl4Y9JxqAoODb9nc9O10zgD',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBudgetDialog,
        backgroundColor: AppTheme.primary,
        foregroundColor: const Color(0xFFEBFFE0),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32),
      ),

      // ========================================================
      // STEP 2: Replace body with StreamBuilder
      // This listens to Firestore and rebuilds automatically
      // ========================================================
      body: StreamBuilder<List<BudgetModel>>(
        stream: _budgetService.getBudgetsStream(_authService.currentUser!.uid),
        builder: (context, snapshot) {
          // Show loading spinner while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error if something went wrong
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // Show empty state if no budgets yet
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet, size: 80, color: AppTheme.outlineVariant),
                  SizedBox(height: 16),
                  Text(
                    'No budgets yet!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Tap the + button to create your first budget'),
                ],
              ),
            );
          }

          // ← THIS IS THE KEY PART: budgets comes from Firebase now
          List<BudgetModel> budgets = snapshot.data!;

          // Calculate totals from real data
          double totalAllocated = budgets.fold(0, (sum, b) => sum + b.allocated);
          double totalSpent = budgets.fold(0, (sum, b) => sum + b.spent);
          double totalRemaining = totalAllocated - totalSpent;
          double utilRatio = totalAllocated > 0 ? (totalSpent / totalAllocated).clamp(0.0, 1.0) : 0.0;
          int utilPercent = (utilRatio * 100).round();

          // ========================================================
          // REST OF THE UI - SAME AS BEFORE
          // ========================================================
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            child: Column(
              children: [
                // Summary Section
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Opacity(
                          opacity: 0.1,
                          child: const Icon(
                            Icons.account_balance_wallet,
                            size: 120,
                            color: AppTheme.onSurface,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL MONTHLY BUDGET',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurfaceVariant,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            CurrencyFormatter.format(totalAllocated),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.onSurface,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(totalRemaining)
                                        .replaceAll('.00', ''),
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  const Text(
                                    'REMAINING',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.onSurfaceVariant,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(totalSpent)
                                        .replaceAll('.00', ''),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const Text(
                                    'SPENT SO FAR',
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
                          Container(
                            height: 16,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDEE5D7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: utilRatio,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('0%', style: _progressLabelStyle),
                              Text('$utilPercent% UTILIZED', style: _progressLabelStyle),
                              Text('100%', style: _progressLabelStyle),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Budget Cards - Map from BudgetModel to BudgetCard
                ...budgets.map((budget) {
                  // Get colors for this budget's color scheme
                  final colors = _getColorsForScheme(budget.colorScheme);

                  // Calculate display values
                  double fillRatio = budget.spentRatio;
                  double left = budget.remaining;
                  String leftText = left > 0
                      ? '\$${left.toStringAsFixed(2)} left'
                      : 'Fully Paid/Spent';

                  // Generate insight based on spending
                  String insight;
                  IconData insightIcon;
                  Color insightColor;

                  if (budget.isOverBudget) {
                    insight = "⚠️ You've exceeded this budget. Consider adjusting your spending.";
                    insightIcon = Icons.warning;
                    insightColor = AppTheme.errorContainer;
                  } else if (budget.isNearLimit) {
                    insight = "⚠️ You're using ${(budget.spentRatio * 100).toStringAsFixed(0)}% of this budget. Be mindful of remaining expenses.";
                    insightIcon = Icons.info;
                    insightColor = AppTheme.tertiary;
                  } else {
                    insight = "✓ You're doing great! ${(budget.spentRatio * 100).toStringAsFixed(0)}% used so far.";
                    insightIcon = Icons.auto_awesome;
                    insightColor = AppTheme.primary;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: BudgetCard(
                      title: budget.title,
                      subtitle: budget.subtitle,
                      amount: CurrencyFormatter.format(budget.allocated),
                      spentText: '\$${budget.spent.toStringAsFixed(2)} spent',
                      leftText: leftText,
                      fillRatio: fillRatio,
                      insight: insight,
                      insightIcon: insightIcon,
                      insightColor: insightColor,
                      progressColor: colors['progressColor']!,
                      iconData: _getIconData(budget.iconName),
                      iconBg: colors['iconBg']!,
                      iconColor: colors['iconColor']!,
                      spentColor: colors['spentColor']!,
                      onDeposit: () => _showAddMoneyDialog(budget),
                      onWithdraw: () => _showSubtractMoneyDialog(budget),
                      onEdit: () => _showEditBudgetDialog(budget),
                      onDelete: () => _deleteBudget(budget),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  TextStyle get _progressLabelStyle => const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: AppTheme.outline,
    letterSpacing: 1.5,
  );
}