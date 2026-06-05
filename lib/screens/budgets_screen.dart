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
import 'package:connectivity_plus/connectivity_plus.dart'; // offline support
import 'dart:async'; // offline support
import 'package:intl/intl.dart'; // Required for NumberFormat




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

  // ── Offline state ──────────────────────────────────────────
  bool _isOffline = false;
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySub;

  @override
  void initState() {
    super.initState();
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      _recurringService.processDueTransactions(userId);
    }
    // ── Listen for connectivity changes ────────────────────────
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final isOffline = results.every((r) => r == ConnectivityResult.none);
      if (mounted) setState(() => _isOffline = isOffline);
    });
  }

  @override
  void dispose() {
    _connectivitySub.cancel();
    super.dispose();
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
    final locale = Localizations.localeOf(context).languageCode; // to know the language
    final formatNum = NumberFormat('#####0.00', locale);
    final controller = TextEditingController(
      text: existing != null ? formatNum.format(existing.totalAmount) : '',
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
              inputFormatters: [ArabicNumberInputFormatter(locale)], // number formater
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
              final amount = CurrencyFormatter.parse(controller.text);
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
    final locale = Localizations.localeOf(context).languageCode; //  this line to know the language
    final formatNum = NumberFormat('#####0.00', locale); // this helps to format decimals

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
            l10n.fullyAllocatedDescription(formatNum.format(monthly.totalAmount)), // arabic number formatter
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
                        l10n.availableToAssign(formatNum.format(remaining)), // arabic numbers
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

                    //  FIX: Check if it's 'custom' to display your localized "Custom" label.
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
                  inputFormatters: [ArabicNumberInputFormatter(locale)], // arabic number formatter
                  decoration: InputDecoration(
                    labelText: l10n.amount,
                    hintText: l10n.maxAmount(formatNum.format(remaining)), // arabic numbers
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
                final amount = CurrencyFormatter.parse(amountController.text);

                if (amount <= 0) return;

                // GUARD 2: Prevent assigning more money than available
                if (amount > remaining) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        locale == 'ar'
                            ? 'لا يمكن تخصيص أكثر من الميزانية المتبقية: ${NumberFormat.decimalPattern(locale).format(remaining).toLocalizedDigits(locale)}'
                            : 'Cannot allocate more than remaining budget: ${NumberFormat.decimalPattern(locale).format(remaining).toLocalizedDigits(locale)}',
                      ),
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
    final locale = Localizations.localeOf(context).languageCode;

    // Capture BEFORE dialog opens — stays valid after pop
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
          content: SingleChildScrollView(

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [ArabicNumberInputFormatter(locale)],
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
        ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),

            TextButton(
              onPressed: () async {
                final amount = CurrencyFormatter.parse(controller.text);

                if (amount <= 0) return;

                //  snapshot values before pop
                final capturedIsRecurring = isRecurring;
                final capturedFrequency = frequency;
                final capturedNote = noteController.text;

                //  close dialog immediately
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
                    //  use screenContext
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
    final locale = Localizations.localeOf(context).languageCode;

    //  Capture BEFORE dialog opens — stays valid after pop
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

          content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [ArabicNumberInputFormatter(locale)],
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
        ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),

            TextButton(
              onPressed: () async {
                final amount = CurrencyFormatter.parse(controller.text);

                if (amount <= 0) return;

                //  snapshot values before pop
                final capturedIsRecurring = isRecurring;
                final capturedFrequency = frequency;
                final capturedNote = noteController.text;

                //  close dialog immediately
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
                    //  use screenContext
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
  void _showEditBudgetDialog(BudgetModel budget, MonthlyBudgetModel? monthly, List<BudgetModel> existing) {
    if (monthly == null) return; // Safeguard
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    // 1. FIX: Format initial number to localized (Arabic) digits and only use ONE controller
    final formatNum = NumberFormat('0.##', locale);
    final initialAmount = formatNum.format(budget.allocated).toLocalizedDigits(locale);
    final controller = TextEditingController(text: initialAmount);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editBudgetAmount),
        content: TextField(
          controller: controller, // UI uses this controller
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [ArabicNumberInputFormatter(locale)],
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
            onPressed: () async { // Make it async to await the Firebase save
              // 2. FIX: Safely parse the user's input using your CurrencyFormatter
              final amt = CurrencyFormatter.parse(controller.text);
              if (amt <= 0) return;

              final double totalAllocatedOthers = existing.fold<double>(0, (sum, item) => sum + item.allocated) - budget.allocated;
              final double maxAllowed = monthly.totalAmount - totalAllocatedOthers;

              if (amt > maxAllowed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      locale == 'ar'
                          ? 'لا يمكن تخصيص أكثر من الميزانية المتبقية: ${NumberFormat.decimalPattern(locale).format(maxAllowed).toLocalizedDigits(locale)}'
                          : 'Cannot allocate more than remaining budget: ${NumberFormat.decimalPattern(locale).format(maxAllowed).toLocalizedDigits(locale)}',
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              // 3. FIX: Actually save the new amount to Firebase!
              // Note: Change 'updateBudget' to whatever method you use in BudgetService to edit the allocated amount
              try {
                await _budgetService.editAllocated(
                  userId: _authService.currentUser!.uid,
                  budgetId: budget.id,
                  newAllocated: amt,
                );
              } catch (e) {
                debugPrint('Check your BudgetService update method name! Error: $e');
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

              try {
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
                      content: Text(
                        l10n.templateSaved(name),
                      ),
                      backgroundColor: AppTheme.primary,
                    ),
                  );
                }
              } catch (e) {
                debugPrint('❌ Failed to save template: $e');

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
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
  void _useTemplateDialog({required List<BudgetModel> existingCategories}) {
    final l10n = AppLocalizations.of(context)!;
    final userId = _authService.currentUser!.uid;

    // Capture screen context BEFORE opening dialogs to avoid async context issues
    final screenContext = context;

    showDialog(
      context: screenContext,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.useTemplate,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
                      separatorBuilder: (_, __) => const Divider(height: 1),
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
                              // ── Delete Template Button ──
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

                              // ── Apply Template Button ──
                              ElevatedButton(
                                onPressed: () async {
                                  // 1. Pop the template picker immediately so dialogs don't stack
                                  Navigator.pop(dialogContext);

                                  // 2. Ask for confirmation if they already have categories setup
                                  if (existingCategories.isNotEmpty) {
                                    final shouldReplace = await showDialog<bool>(
                                      context: screenContext,
                                      builder: (confirmContext) => AlertDialog(
                                        title: Text(l10n.replaceCurrentCategories),
                                        content: Text(l10n.replaceCategoriesWarning),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(confirmContext, false),
                                            child: Text(l10n.cancel),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(confirmContext, true),
                                            child: Text(
                                              l10n.replace,
                                              style: const TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    // If user dismisses dialog or clicks cancel, abort.
                                    if (shouldReplace != true) return;
                                  }

                                  // 3. Apply the template
                                  if (!screenContext.mounted) return;

                                  try {
                                    // Why: We update the overarching Monthly Budget total to match the template.
                                    // If we don't do this, a $2,000 template applied to a $500 monthly budget
                                    // will cause an immediate allocation overflow error in the UI.
                                    await _budgetService.setMonthlyBudget(
                                      userId: userId,
                                      monthId: _currentMonthId,
                                      totalAmount: t.totalAmount,
                                    );

                                    // Apply categories (deletes old, creates new cleanly)
                                    await _templateService.applyTemplate(
                                      userId: userId,
                                      monthId: _currentMonthId,
                                      template: t,
                                      existingCategories: existingCategories,
                                    );

                                    if (screenContext.mounted) {
                                      ScaffoldMessenger.of(screenContext).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.templateApplied(t.name)),
                                          backgroundColor: AppTheme.primary,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    debugPrint('❌ Failed to apply template: $e');
                                    if (screenContext.mounted) {
                                      ScaffoldMessenger.of(screenContext).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.failedToSave(e.toString())),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
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
                  onPressed: () => Navigator.pop(dialogContext),
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
    final locale = Localizations.localeOf(context).languageCode;
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
            CurrencyFormatter.format(monthly.totalAmount, locale),
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
                value: CurrencyFormatter.format(totalAllocated, locale),
                color: Colors.white,
              ),
              _budgetStat(
                label: isFullyAllocated ? l10n.fullyAllocatedCheck : l10n.unallocated,
                value: isFullyAllocated
                    ? ''
                    : CurrencyFormatter.format(unallocated, locale),
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
              onPressed: () => _useTemplateDialog(existingCategories: []),
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
      body: Column(
          children: [
          // ── Offline banner: only visible when device has no connection ──
          if (_isOffline)
      Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.orange.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 15, color: Colors.orange.shade800),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.offlineBanner,
            style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
          ),
        ],
      ),
    ),

    // ── Main content ────────────────────────────────────────────────
    Expanded(
    child: StreamBuilder<MonthlyBudgetModel?>(
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
                              onTap: () => _useTemplateDialog(existingCategories: categories),
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
                      ...categories.map((budget) {
                        final locale = Localizations.localeOf(context).languageCode;
                        final formatNum = NumberFormat('#####0.00', locale);
                        // ── Compute state flags once, used throughout the card ──────────────
                        // True when the user has spent more than they allocated for this category
                        final isOverBudget = budget.spent > budget.allocated;
                        // True when at least some money has been spent (deposit = refund, so
                        // there must be spending to refund)
                        final hasSpending = budget.spent > 0;

                        //  Dynamic Translation Lookup & Fallback ──
                        // First, attempt standard lookup
                        String resolvedTitle = CategoryLocalization.getCategoryName(
                            context, budget.categoryKey, budget.customTitle);

                        // Fallback safety net: If it was created via a template and hardcoded to 'custom',
                        // but matches an internal system key, translate it anyway!
                        if (budget.categoryKey == 'custom') {
                          final isSystemKey = budgetCategories.any((c) => c.key == budget.customTitle);
                          if (isSystemKey) {
                            resolvedTitle = CategoryLocalization.getCategoryName(context, budget.customTitle, '');
                          }
                        }

                        return BudgetCard(
                          // ── Identity ────────────────────────────────────────────────────────
                          // Resolves the display name: uses customTitle for user-created
                          // categories, or the localized name for standard category keys
                          title: resolvedTitle, // 👈 Uses our newly resolved localized title
                          subtitle: l10n.category,

                          // ── Amounts ─────────────────────────────────────────────────────────
                          // The total budget ceiling the user set for this category
                          amount: CurrencyFormatter.format(budget.allocated, locale),
                          // How much has been spent so far this month
                          spentText: l10n.spentAmount(formatNum.format(budget.spent).toLocalizedDigits(locale)),

                          // ── Left / Over label ────────────────────────────────────────────────
                          // Normal:     "X left"       → how much remains before hitting the limit
                          // Over budget: "⚠ Over by X" → how far past the limit the user has gone
                          leftText: isOverBudget
                              ? l10n.overBy(formatNum.format(budget.spent - budget.allocated).toLocalizedDigits(locale))
                              : l10n.leftAmount(formatNum.format(budget.remaining).toLocalizedDigits(locale)),
                          // Red when over budget, default grey otherwise (null = use card default)
                          leftTextColor: isOverBudget ? Colors.redAccent : null,

                          // ── Progress bar ─────────────────────────────────────────────────────
                          // Clamped to 1.0 so the bar never visually overflows past 100%
                          // (the "Over by" label communicates the overage instead)
                          fillRatio: budget.spentRatio.clamp(0.0, 1.0),
                          // Bar and spent text turn red together when over budget
                          progressColor: isOverBudget ? Colors.redAccent : AppTheme.primary,
                          spentColor: isOverBudget ? Colors.redAccent : AppTheme.primary,

                          // ── Icon (static for now, could be per-category later) ───────────────
                          // UPDATED NOT STATIC ANYMORE
                          iconData: CategoryUIHelper.getIconData(budget.iconName),
                          iconBg: CategoryUIHelper.getColorsForScheme(budget.colorScheme)['iconBg']!,
                          iconColor: CategoryUIHelper.getColorsForScheme(budget.colorScheme)['iconColor']!,

                          // ── AI Insight chip at the bottom of the card ────────────────────────
                          // BudgetInsightHelper analyzes pace of spending vs days left in month
                          // and returns a short tip, an icon, and a color
                          insight: BudgetInsightHelper
                              .getInsight(context, budget, daysLeftInMonth: _daysLeft).text,
                          insightIcon: BudgetInsightHelper
                              .getInsight(context, budget, daysLeftInMonth: _daysLeft).icon,
                          // Insight color also turns red when over budget so the whole card
                          // signals danger consistently
                          insightColor: isOverBudget
                              ? Colors.redAccent
                              : BudgetInsightHelper
                              .getInsight(context, budget, daysLeftInMonth: _daysLeft).color,

                          // ── Action buttons ───────────────────────────────────────────────────
                          // Deposit = record a refund. Disabled (greyed out) when spent is 0
                          // because there is nothing to refund yet
                          onDeposit: hasSpending ? () => _showAddMoneyDialog(budget) : null,
                          // Withdraw = record spending. Always allowed — going over budget is
                          // a real-life event that must be recordable
                          onWithdraw: () => _showSubtractMoneyDialog(budget),
                          // Edit changes the allocated ceiling without touching spent
                          onEdit: () => _showEditBudgetDialog(budget, monthly, categories),
                          // Delete removes the category and all its data
                          onDelete: () => _deleteBudget(budget),
                        );
                      }),
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
      // closes StreamBuilder<MonthlyBudgetModel?>
    ),
    ), // closes Expanded
          ],   // closes Column children
      ),     // closes Column
    );
  }
}