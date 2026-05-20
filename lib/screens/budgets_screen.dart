import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/budget_model.dart';
import '../models/monthly_budget_model.dart';
import '../models/user_model.dart';
import '../utils/currency_formatter.dart';
import '../widgets/budget_card.dart';
import '../services/budget_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/recurring_service.dart';
import '../screens/recurring_screen.dart';
import '../screens/transactions_screen.dart';
import '../models/budget_template_model.dart';
import '../services/template_service.dart';
import 'package:mindful_curator/l10n/app_localizations.dart';
import '../utils/budget_insight_helper.dart';
import '../utils/budget_categories.dart';
import '../utils/category_localization.dart';




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
  final UserService _userService = UserService();
  final RecurringService _recurringService = RecurringService();
  final TemplateService _templateService = TemplateService();

  @override
  void initState() {
    super.initState();
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      _recurringService.processDueTransactions(userId);
    }
  }

  // ─── Helpers: current month as "YYYY-MM" and display name ─────────────────

  String get _currentMonthId {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  String _currentMonthName(BuildContext context) {
    final now = DateTime.now();

    return MaterialLocalizations.of(context)
        .formatMonthYear(now);
  }

  // ─── Dialogs: Monthly Budget ───────────────────────────────────────────────

  /// Called when no monthly budget exists yet, or user wants to edit it.
  void _showSetMonthlyBudgetDialog({MonthlyBudgetModel? existing}) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(
      text: existing != null ? existing.totalAmount.toStringAsFixed(2) : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          existing == null
              ? l10n.setMonthlyBudget(
            _currentMonthName(context),
          )
              : l10n.editMonthlyBudget,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.monthlyBudgetDescription,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration:  InputDecoration(
                labelText: l10n.totalMonthlyBudget,
                hintText: '3000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel)
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
            child: Text(l10n.save),
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
    final l10n = AppLocalizations.of(context)!;

    // Calculate how much money is left unassigned
    final totalAllocated = existing.fold(0.0, (sum, b) => sum + b.allocated);
    final remaining = monthly.totalAmount - totalAllocated;

    // GUARD 1: If everything is already allocated, show a warning
    if (remaining <= 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.fullyAllocated),
          content: Text(
            l10n.fullyAllocatedDescription(monthly.totalAmount.toStringAsFixed(2)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.ok),
            ),
          ],
        ),
      );
      return;
    }

    final customTitleController = TextEditingController();
    final amountController = TextEditingController();

    // Set the initial default selected item to the first category key
    String selectedCategoryKey = budgetCategories.first.key;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.addCategoryBudget),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Banner showing remaining budget
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: AppTheme.onPrimaryContainer),
                      const SizedBox(width: 8),
                      Text(
                        l10n.availableToAssign(remaining.toStringAsFixed(2)),
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

                // Category Dropdown Label
                Text(l10n.categories, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: selectedCategoryKey,
                  isExpanded: true,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      )
                  ),
                  // Loop through your list of categories from budget_categories.dart
                  items: budgetCategories.map((category) {

                    // 🔥 FIX: Check if it's 'custom' to display your localized "Custom" label.
                    // Otherwise, pass all 3 parameters safely into your utility class!
                    final String displayName = category.key == 'custom'
                        ? l10n.category_custom
                        : CategoryLocalization.getCategoryName(context, category.key, '');

                    return DropdownMenuItem(
                      value: category.key,
                      child: Text(displayName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedCategoryKey = val; // Triggers UI re-draw for conditional text field
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Conditional Text Field: Only visible if 'custom' is selected
                if (selectedCategoryKey == 'custom') ...[
                  TextField(
                    controller: customTitleController,
                    decoration: InputDecoration(
                      labelText: l10n.categoryName,
                      hintText: l10n.groceriesHint,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Amount Allocation Input Field
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.amount,
                    hintText: l10n.maxAmount(remaining.toStringAsFixed(2)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text) ?? 0.0;

                if (amount <= 0) return;

                // GUARD 2: Prevent assigning more money than available
                if (amount > remaining) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.amountExceedsRemaining(remaining.toStringAsFixed(2))),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                // Determine the custom title value
                final isCustom = selectedCategoryKey == 'custom';
                final finalCustomTitle = isCustom
                    ? (customTitleController.text.trim().isEmpty ? l10n.newCategory : customTitleController.text.trim())
                    : '';

                // Find matching design configs from your budgetCategories list
                final selectedConfig = budgetCategories.firstWhere((c) => c.key == selectedCategoryKey);

                // Write the complete, standardized model to Firebase
                await _budgetService.addBudget(
                  userId: _authService.currentUser!.uid,
                  monthlyBudgetId: _currentMonthId,
                  categoryKey: selectedCategoryKey,
                  customTitle: finalCustomTitle,
                  subtitle: l10n.category,
                  allocated: amount,
                  iconName: selectedConfig.iconName,
                  colorScheme: selectedConfig.colorScheme,
                );

                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: const Color(0xFFEBFFE0),
              ),
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }
  // ─── Dialogs: Deposit / Withdraw / Edit / Delete ───────────────────────────

  // ============================================================
  // DIALOG: Deposit money into a budget
  // ============================================================
  void _showAddMoneyDialog(BudgetModel budget) {
    final l10n = AppLocalizations.of(context)!;

    // ✅ Capture BEFORE dialog opens — stays valid after pop
    final screenContext = context;

    final controller = TextEditingController();
    final noteController = TextEditingController();

    bool isRecurring = false;
    String frequency = 'monthly';

    showDialog(
      context: context,

      // renamed to dialogContext to avoid confusion
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(l10n.addMoneyDeposit),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.amount,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: l10n.noteOptional,
                  hintText: l10n.salaryHint,
                ),
              ),

              const SizedBox(height: 16),

              // ── Recurring toggle ──────────────────────────
              Row(
                textDirection: Directionality.of(context),
                children: [
                  Checkbox(
                    value: isRecurring,
                    activeColor: AppTheme.primary,
                    onChanged: (v) {
                      setDialogState(() {
                        isRecurring = v ?? false;
                      });
                    },
                  ),

                  Text(l10n.makeRecurring),
                ],
              ),

              if (isRecurring)
                DropdownButton<String>(
                  alignment: AlignmentDirectional.centerStart,
                  value: frequency,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: 'monthly',
                      child: Text(l10n.everyMonth),
                    ),
                    DropdownMenuItem(
                      value: 'weekly',
                      child: Text(l10n.everyWeek),
                    ),
                  ],
                  onChanged: (v) {
                    setDialogState(() {
                      frequency = v ?? 'monthly';
                    });
                  },
                ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),

            TextButton(
              onPressed: () async {
                final amount =
                    double.tryParse(controller.text) ?? 0.0;

                if (amount <= 0) return;

                // ✅ snapshot values before pop
                final capturedIsRecurring = isRecurring;
                final capturedFrequency = frequency;
                final capturedNote = noteController.text;

                // ✅ close dialog immediately
                Navigator.pop(dialogContext);

                try {
                  final userId = _authService.currentUser!.uid;

                  await _budgetService.deposit(
                    userId: userId,
                    budget: budget,
                    amount: amount,
                  );

                  // Save as recurring
                  if (capturedIsRecurring) {
                    await _recurringService.addRecurringTransaction(
                      userId: userId,
                      budget: budget,
                      amount: amount,
                      type: 'deposit',
                      frequency: capturedFrequency,
                      note: capturedNote,
                    );
                  }
                } catch (e) {
                  // visible in console
                  debugPrint(
                    '❌ Deposit/recurring save failed: $e',
                  );

                  if (mounted) {
                    // ✅ use screenContext
                    ScaffoldMessenger.of(screenContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.failedToSave(e.toString()),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(l10n.addMoneyDeposit),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DIALOG: Withdraw / Spend from a budget
  // ============================================================
  void _showSubtractMoneyDialog(BudgetModel budget) {
    final l10n = AppLocalizations.of(context)!;

    // ✅ Capture BEFORE dialog opens — stays valid after pop
    final screenContext = context;

    final controller = TextEditingController();
    final noteController = TextEditingController();

    bool isRecurring = false;
    String frequency = 'monthly';

    showDialog(
      context: context,

      // renamed to dialogContext to avoid confusion
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(l10n.subtractMoneySpend),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.amount,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: l10n.noteOptional,
                  hintText: l10n.netflixHint,
                ),
              ),

              const SizedBox(height: 16),

              // ── Recurring toggle ──────────────────────────
              Row(
                textDirection: Directionality.of(context),
                children: [
                  Checkbox(
                    value: isRecurring,
                    activeColor: AppTheme.primary,
                    onChanged: (v) {
                      setDialogState(() {
                        isRecurring = v ?? false;
                      });
                    },
                  ),

                  Text(l10n.makeRecurring),
                ],
              ),

              if (isRecurring)
                DropdownButton<String>(
                  value: frequency,
                  isExpanded: true,
                  alignment: AlignmentDirectional.centerStart,
                  items: [
                    DropdownMenuItem(
                      value: 'monthly',
                      child: Text(l10n.everyMonth),
                    ),
                    DropdownMenuItem(
                      value: 'weekly',
                      child: Text(l10n.everyWeek),
                    ),
                  ],
                  onChanged: (v) {
                    setDialogState(() {
                      frequency = v ?? 'monthly';
                    });
                  },
                ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),

            TextButton(
              onPressed: () async {
                final amount =
                    double.tryParse(controller.text) ?? 0.0;

                if (amount <= 0) return;

                // ✅ snapshot values before pop
                final capturedIsRecurring = isRecurring;
                final capturedFrequency = frequency;
                final capturedNote = noteController.text;

                // ✅ close dialog immediately
                Navigator.pop(dialogContext);

                try {
                  final userId = _authService.currentUser!.uid;

                  await _budgetService.withdraw(
                    userId: userId,
                    budget: budget,
                    amount: amount,
                    note: capturedNote,
                  );

                  // ── Save recurring transaction ──
                  if (capturedIsRecurring) {
                    await _recurringService.addRecurringTransaction(
                      userId: userId,
                      budget: budget,
                      amount: amount,
                      type: 'withdraw',
                      frequency: capturedFrequency,
                      note: capturedNote,
                    );
                  }
                } catch (e) {
                  // visible in console
                  debugPrint(
                    '❌ Withdraw/recurring save failed: $e',
                  );

                  if (mounted) {
                    // ✅ use screenContext
                    ScaffoldMessenger.of(screenContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.failedToSave(e.toString()),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(l10n.subtractMoneySpend),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DIALOG: Edit the allocated amount
  // ============================================================
  void _showEditBudgetDialog(BudgetModel budget) {
    final l10n = AppLocalizations.of(context)!;
    final controller =
    TextEditingController(text: budget.allocated.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editBudgetAmount),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration:  InputDecoration(
            labelText: l10n.allocatedAmount,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
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
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIALOG: Delete a budget with confirmation
  // ============================================================
  void _deleteBudget(BudgetModel budget) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteBudget),
        content: Text(
          l10n.deleteBudgetQuestion(
            CategoryLocalization.getCategoryName(context, budget.categoryKey, budget.customTitle),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              await _budgetService.deleteBudget(
                userId: _authService.currentUser!.uid,
                budgetId: budget.id,
              );
              if (mounted) Navigator.pop(context);
            },
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // DIALOG: SAVE a template
  // ============================================================
  void _saveAsTemplateDialog({
    required MonthlyBudgetModel monthly,
    required List<BudgetModel> categories,
  }) {
    final l10n = AppLocalizations.of(context)!;
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addCategoryFirst)),
      );
      return;
    }

    final nameController = TextEditingController(
      text: l10n.defaultTemplateName(_currentMonthName(context)),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.saveAsTemplate),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.templateDescription(categories.length.toString()),
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration:  InputDecoration(
                labelText: l10n.templateName,
                hintText: l10n.monthlyBudgetTemplate,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              await _templateService.saveTemplate(
                userId: _authService.currentUser!.uid,
                name: name,
                totalAmount: monthly.totalAmount,
                categories: categories,
              );
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.templateSaved(name)),
                    backgroundColor: AppTheme.primary,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: const Color(0xFFEBFFE0),
            ),
            child: Text(l10n.saveTemplate),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIALOG: USE a template
  // ============================================================
  void _useTemplateDialog() {
    final l10n = AppLocalizations.of(context)!;
    final userId = _authService.currentUser!.uid;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                l10n.useTemplate,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.pickTemplate,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<BudgetTemplateModel>>(
                stream: _templateService.getTemplatesStream(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final templates = snapshot.data ?? [];

                  if (templates.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.bookmark_border_rounded,
                                size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              l10n.noTemplatesYet,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.noTemplatesHint,
                              style: TextStyle(color: Colors.grey[400], fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 320),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: templates.length,
                      separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final t = templates[index];
                        return ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.bookmark_rounded,
                                color: AppTheme.primary),
                          ),
                          title: Text(
                            t.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          subtitle: Text(
                            l10n.templateSummary(
                              t.categoryCount.toString(),
                              t.totalAmount.toStringAsFixed(0),
                            ),
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Delete button
                              IconButton(
                                icon: Icon(Icons.delete_outline,
                                    color: Colors.grey[400], size: 20),
                                onPressed: () async {
                                  await _templateService.deleteTemplate(
                                    userId: userId,
                                    templateId: t.id,
                                  );
                                },
                              ),
                              // Apply button
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  // First set the monthly budget total
                                  await _budgetService.setMonthlyBudget(
                                    userId: userId,
                                    monthId: _currentMonthId,
                                    totalAmount: t.totalAmount,
                                  );
                                  // Then create all categories
                                  await _templateService.applyTemplate(
                                    userId: userId,
                                    monthId: _currentMonthId,
                                    template: t,
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.templateApplied(t.name)),
                                        backgroundColor: AppTheme.primary,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: const Color(0xFFEBFFE0),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                                child: Text(l10n.use),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Widgets ───────────────────────────────────────────────────────────────

  /// The card at the top of the list showing the monthly budget summary.
  Widget _buildMonthlyBudgetCard({
    required MonthlyBudgetModel monthly,
    required List<BudgetModel> categories,
  }) {
    final l10n = AppLocalizations.of(context)!;
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
                _currentMonthName(context),
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
    child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    const Icon(Icons.edit, color: Colors.white, size: 13),
    const SizedBox(width: 4),
    Text(
    l10n.edit,
    style: const TextStyle(
    color: Colors.white,
    fontSize: 12,
    ),
    ),
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
           Text(
            l10n.totalMonthlyBudgetLabel,
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
                label: l10n.allocatedToCategories,
                value: CurrencyFormatter.format(totalAllocated),
                color: Colors.white,
              ),
              _budgetStat(
                label: isFullyAllocated ? l10n.fullyAllocatedCheck : l10n.unallocated,
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
    final l10n = AppLocalizations.of(context)!;
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
              l10n.setMonthlyBudget(
                _currentMonthName(context),
              ),
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.budgetSetupDescription,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _showSetMonthlyBudgetDialog,
              icon: const Icon(Icons.add),
              label: Text(l10n.setMonthlyBudget(
                _currentMonthName(context),
              )),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: const Color(0xFFEBFFE0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            // USE a Template Button
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _useTemplateDialog,
              icon: const Icon(Icons.bookmark_rounded),
              label:  Text(l10n.useSavedTemplate),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
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
    final l10n = AppLocalizations.of(context)!;
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text(l10n.notLoggedIn),
        ),
      );
    }
    final String userId = currentUser.uid;

    return Scaffold(
      backgroundColor: AppTheme.neutral,

      // ======================================================
      // APP BAR with real profile picture from Firestore
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
            Text(l10n.budgets),

            Row(
              children: [

                // ── Transaction Screen Button ──
                IconButton(
                  icon: const Icon(Icons.receipt_long_rounded),
                  tooltip: l10n.transactionHistory,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                  ),
                ),

                // ── Recurring Screen Button ──
                IconButton(
                  icon: const Icon(Icons.repeat_rounded),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RecurringScreen(),
                    ),
                  ),
                ),

                // ── Profile Image ──
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
                            ? Image.network(
                          user.photoUrl,
                          fit: BoxFit.cover,
                        )
                            : const Icon(Icons.person),
                      ),
                    );
                  },
                ),
              ],
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
                        Text(l10n.failedToLoadCategories,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
              final _now = DateTime.now();
              final _lastDay = DateTime(_now.year, _now.month + 1, 0);
              final _daysLeft = _lastDay.day - _now.day;

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
                              l10n.categories,
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
                            const Spacer(),

                            // ── Use Template Button ──
                            GestureDetector(
                              onTap: _useTemplateDialog,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bookmarks_rounded,
                                    size: 15,
                                    color: AppTheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.useAsTemplate,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 14),

                       // ── Save Template Button ──
                            GestureDetector(
                              onTap: () => _saveAsTemplateDialog(
                                monthly: monthly,
                                categories: categories,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bookmark_add_outlined,
                                    size: 15,
                                    color: AppTheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.saveAsTemplate,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ],
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
              l10n.noCategoriesYet,
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.divideBudgetHint,
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
                        title: CategoryLocalization.getCategoryName(context, budget.categoryKey, budget.customTitle),
                        subtitle: l10n.category,
                        amount: CurrencyFormatter.format(
                            budget.allocated),
                        spentText: l10n.spentAmount(
                          budget.spent.toStringAsFixed(2),
                        ),

                        leftText: l10n.leftAmount(
                          budget.remaining.toStringAsFixed(2),
                        ),
                        fillRatio: budget.spentRatio,
                        iconData: Icons.category,
                        progressColor: AppTheme.primary,
                        iconBg: AppTheme.primaryContainer,
                        iconColor: AppTheme.onPrimaryContainer,
                        spentColor: AppTheme.primary,
                        insight: BudgetInsightHelper
                            .getInsight(context , budget, daysLeftInMonth: _daysLeft)
                            .text,

                        insightIcon: BudgetInsightHelper
                            .getInsight(context , budget, daysLeftInMonth: _daysLeft)
                            .icon,

                        insightColor: BudgetInsightHelper
                            .getInsight(context , budget, daysLeftInMonth: _daysLeft)
                            .color,
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
                  // FLOATING ACTION BUTTON
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