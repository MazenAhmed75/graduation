import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/budget_model.dart';
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
        content:
        Text('Are you sure you want to delete "${budget.title}"?'),
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
            child:
            const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIALOG: Add a new budget
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
                hintText: 'e.g. Groceries',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (\$)',
                hintText: 'e.g. 500',
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
                  ? 'New Budget'
                  : titleController.text.trim();

              if (amount > 0) {
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

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: user?.photoUrl != null &&
                        user!.photoUrl.isNotEmpty
                        ? Image.network(user.photoUrl, fit: BoxFit.cover)
                        : const Icon(Icons.person),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // ======================================================
      // FLOATING ACTION BUTTON (FIXED - ONLY ONE)
      // ======================================================
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 60,
        ),
        child: FloatingActionButton(
          onPressed: _addBudgetDialog,
          backgroundColor: AppTheme.primary,
          foregroundColor: const Color(0xFFEBFFE0),
          child: const Icon(Icons.add),
        ),
      ),

      // ======================================================
      // STREAM BUILDER (FIREBASE REAL-TIME)
      // ======================================================
      body: StreamBuilder<List<BudgetModel>>(
        stream: _budgetService.getBudgetsStream(userId),
        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Failed to load budgets',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final budgets = snapshot.data!;

          if (budgets.isEmpty) {
            return const Center(child: Text('No budgets yet'));
          }

          return ListView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 80,
            ),
            children: budgets.map((budget) {
              return BudgetCard(
                title: budget.title,
                subtitle: budget.subtitle,
                amount: CurrencyFormatter.format(budget.allocated),
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
                onDeposit: () => _showAddMoneyDialog(budget),
                onWithdraw: () => _showSubtractMoneyDialog(budget),
                onEdit: () => _showEditBudgetDialog(budget),
                onDelete: () => _deleteBudget(budget),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}