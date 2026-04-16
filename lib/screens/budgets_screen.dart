import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/budget_item_model.dart';
import '../utils/currency_formatter.dart';
import '../widgets/budget_card.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  List<BudgetItemModel> budgets = [];

  @override
  void initState() {
    super.initState();
    budgets = [
      BudgetItemModel(
        id: '1',
        title: 'Groceries',
        subtitle: '8 items this week',
        allocated: 450.0,
        spent: 324.0,
        insight: "Insight: Try meal prepping this Sunday to save ~15% on daily lunch costs.",
        insightIcon: Icons.auto_awesome,
        insightColor: AppTheme.primary,
        progressColor: AppTheme.primary,
        iconData: Icons.shopping_cart,
        iconBg: AppTheme.secondaryContainer,
        iconColor: AppTheme.onSecondaryContainer,
      ),
      BudgetItemModel(
        id: '2',
        title: 'Rent',
        subtitle: 'Monthly Payment',
        allocated: 2100.0,
        spent: 2100.0,
        insight: "Insight: Rent is consistent. Consider setting up an auto-transfer to your savings account today.",
        insightIcon: Icons.lightbulb,
        insightColor: AppTheme.tertiary,
        progressColor: AppTheme.tertiary,
        iconData: Icons.home,
        iconBg: AppTheme.tertiaryContainer,
        iconColor: AppTheme.onTertiaryContainer,
        spentColor: AppTheme.tertiary,
      ),
      BudgetItemModel(
        id: '3',
        title: 'Entertainment',
        subtitle: 'Subscriptions & Outings',
        allocated: 300.0,
        spent: 135.0,
        insight: "Insight: You're 20% under budget, consider moving the surplus to your emergency fund.",
        insightIcon: Icons.auto_awesome,
        insightColor: AppTheme.secondary,
        progressColor: AppTheme.secondary,
        iconData: Icons.theater_comedy,
        iconBg: AppTheme.secondaryFixed,
        iconColor: AppTheme.onSecondaryFixed,
        spentColor: AppTheme.secondary,
      ),
      BudgetItemModel(
        id: '4',
        title: 'Travel',
        subtitle: 'Summer Trip Fund',
        allocated: 1400.0,
        spent: 420.0,
        insight: "Insight: Flight prices to Europe are dipping. Booking now could save you \$240 on your fund.",
        insightIcon: Icons.tips_and_updates,
        insightColor: AppTheme.primaryDim,
        progressColor: AppTheme.primaryDim,
        iconData: Icons.flight_takeoff,
        iconBg: AppTheme.primaryContainer,
        iconColor: AppTheme.onPrimaryContainer,
        spentColor: AppTheme.primaryDim,
      ),
    ];
  }

  void _showAddMoneyDialog(BudgetItemModel budget) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Money (Deposit)'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount (\$)', hintText: 'Enter amount to deposit'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0.0;
              if (amount > 0) {
                setState(() {
                  budget.spent = (budget.spent - amount) < 0 ? 0.0 : (budget.spent - amount);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Deposit'),
          ),
        ],
      ),
    );
  }

  void _showSubtractMoneyDialog(BudgetItemModel budget) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subtract Money (Withdraw/Spend)'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount (\$)', hintText: 'Enter amount to withdraw'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0.0;
              if (amount > 0) {
                setState(() {
                  budget.spent += amount;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  void _showEditBudgetDialog(BudgetItemModel budget) {
    final controller = TextEditingController(text: budget.allocated.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Total Budget'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Allocated Amount (\$)', hintText: 'Enter new total budget'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0.0;
              if (amount > 0) {
                setState(() {
                  budget.allocated = amount;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteBudget(BudgetItemModel budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Are you sure you want to delete the "${budget.title}" budget?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                budgets.remove(budget);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

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
              decoration: const InputDecoration(labelText: 'Budget Name', hintText: 'e.g. Dining Out'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Allocated Amount (\$)', hintText: 'Enter total budget'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              final title = titleController.text.trim().isEmpty ? 'New Budget' : titleController.text.trim();
              if (amount > 0) {
                setState(() {
                  budgets.add(BudgetItemModel(
                    id: DateTime.now().toString(),
                    title: title,
                    subtitle: 'Custom Budget',
                    allocated: amount,
                    spent: 0,
                    insight: "Insight: Let's stick to this new budget!",
                    insightIcon: Icons.star,
                    insightColor: AppTheme.primary,
                    progressColor: AppTheme.primary,
                    iconData: Icons.category,
                    iconBg: AppTheme.neutral,
                    iconColor: AppTheme.onSurface,
                  ));
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalAllocated = budgets.fold(0, (sum, item) => sum + item.allocated);
    double totalSpent = budgets.fold(0, (sum, item) => sum + item.spent);
    double totalRemaining = (totalAllocated - totalSpent);
    double utilRatio = totalAllocated > 0 ? (totalSpent / totalAllocated) : 0.0;
    if (utilRatio > 1.0) utilRatio = 1.0;
    int utilPercent = (utilRatio * 100).round();

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
      body: SingleChildScrollView(
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
                      child: const Icon(Icons.account_balance_wallet, size: 120, color: AppTheme.onSurface),
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
                                CurrencyFormatter.format(totalRemaining).replaceAll('.00', ''),
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
                                CurrencyFormatter.format(totalSpent).replaceAll('.00', ''),
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

            // Budget Items
            ...budgets.map((budget) {
              double fillRatio = budget.allocated > 0 ? (budget.spent / budget.allocated) : 0.0;
              if (fillRatio > 1.0) fillRatio = 1.0;
              double left = (budget.allocated - budget.spent);
              String leftText = left > 0 ? '\$${left.toStringAsFixed(2)} left' : 'Fully Paid/Spent';

              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: BudgetCard(
                  title: budget.title,
                  subtitle: budget.subtitle,
                  amount: CurrencyFormatter.format(budget.allocated),
                  spentText: '\$${budget.spent.toStringAsFixed(2)} spent',
                  leftText: leftText,
                  fillRatio: fillRatio,
                  insight: budget.insight,
                  insightIcon: budget.insightIcon,
                  insightColor: budget.insightColor,
                  progressColor: budget.progressColor,
                  iconData: budget.iconData,
                  iconBg: budget.iconBg,
                  iconColor: budget.iconColor,
                  spentColor: budget.spentColor,
                  onDeposit: () => _showAddMoneyDialog(budget),
                  onWithdraw: () => _showSubtractMoneyDialog(budget),
                  onEdit: () => _showEditBudgetDialog(budget),
                  onDelete: () => _deleteBudget(budget),
                ),
              );
            }),
          ],
        ),
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
