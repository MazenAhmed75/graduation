import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/user_model.dart';
import '../models/budget_model.dart';
import '../services/user_service.dart';
import '../services/budget_service.dart';
import '../services/auth_service.dart';
import '../utils/currency_formatter.dart';
import 'package:mindful_curator/l10n/app_localizations.dart';
import '../screens/insights_sheet.dart';
import '../screens/reports_sheet.dart';
import '../utils/category_localization.dart';
import '../utils/budget_categories.dart';
import 'package:intl/intl.dart'; //  arabic numbers

class HomeScreen extends StatelessWidget {
  // ============================================================
  // onNavigateToBudgets is a callback from MainScreen.
  // When called, MainScreen switches to the Budgets tab (index 1).
  // ============================================================
  final VoidCallback onNavigateToBudgets;
  final Function(int) onNavigateToTab;
  final Function(bool) onDrawerChanged;

  const HomeScreen({
    super.key,
    required this.onNavigateToBudgets,
    required this.onNavigateToTab,
    required this.onDrawerChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Get the current active language ('en', 'ar', etc.)
    final String locale = Localizations.localeOf(context).languageCode;
    final UserService userService = UserService();
    final BudgetService budgetService = BudgetService();
    final AuthService authService = AuthService();
    final String userId = authService.currentUser!.uid;

    // ──  Generate the current month ID ──────────────────────────
    // This allows us to fetch only the budgets for the active month.
    final now = DateTime.now();
    final monthId = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppTheme.neutral,
      //   THE DRAWER
      drawer: _buildDrawer(context, userService, userId),
      //CHECK IF DRAWER IS OPEN
      onDrawerChanged: onDrawerChanged,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                // 2. BUILDER WRAPPER: Required to open drawer from a button
                Builder(
                  builder: (context) => IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.menu, color: AppTheme.primary),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.surfaceContainerLow,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                 Text(
                   l10n.appName,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            // Profile picture in top right — tap to go to profile tab
            StreamBuilder<UserModel?>(
              stream: userService.getUserStream(userId),
              builder: (context, snapshot) {
                final user = snapshot.data;
                return GestureDetector(
                  // This does nothing here because we can't switch to profile
                  // tab from HomeScreen directly. User can tap the nav bar icon.
                  onTap: () {},
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                      Border.all(color: AppTheme.primaryContainer, width: 2),
                      color: AppTheme.surfaceContainerLow,
                    ),
                    child: user?.photoUrl != null && user!.photoUrl.isNotEmpty
                        ? ClipOval(
                      child: Image.network(
                        user.photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) =>
                        const Icon(Icons.person,
                            color: AppTheme.primary),
                      ),
                    )
                        : const Icon(Icons.person, color: AppTheme.primary),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<UserModel?>(
        stream: userService.getUserStream(userId),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = userSnapshot.data;
          if (user == null) {
            return Center(child: Text(l10n.userDataNotFound));
          }

          return StreamBuilder<List<BudgetModel>>(
            // ──  Call the correct method with monthId ─────────────
            stream: budgetService.getCategoryBudgetsStream(userId, monthId),
            builder: (context, budgetsSnapshot) {
              final budgets = budgetsSnapshot.data ?? [];

              final now = DateTime.now();
              final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
              final daysLeft = lastDayOfMonth.day - now.day;

              // ── LIVE savings calculation ──────────────────────────
              // "Saved" = money you allocated but haven't spent yet.
              // This updates instantly whenever any budget changes.
              final totalAllocated = budgets.fold(0.0, (sum, b) => sum + b.allocated);
              final totalSpent = budgets.fold(0.0, (sum, b) => sum + b.spent);
              final liveSavings = (totalAllocated - totalSpent).clamp(0.0, double.infinity);

              final savingsPercent = user.monthlySavingsGoal > 0
                  ? ((liveSavings / user.monthlySavingsGoal) * 100)
                  .clamp(0.0, 100.0)
                  .round()
                  : 0;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome Section
                    Text(
                      _getGreeting(context).toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.welcomeUser(user.name.split(' ')[0]),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.onSurface,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Monthly Savings Goal Card
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: AppTheme.outlineVariant.withOpacity(0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E342B).withOpacity(0.06),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -48,
                            right: -48,
                            child: Container(
                              width: 192,
                              height: 192,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                AppTheme.primaryContainer.withOpacity(0.2),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                         Text(
                                          l10n.monthlyBudgetGoal.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.onSurfaceVariant,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                      // Tap to edit savings goal
                      GestureDetector(
                        onTap: () =>
                            _showEditSavingsGoalDialog(
                                context, user, userService),
                        child: Row(
                            children: [
                        Text(
                        // Pass the locale, and handle truncation safely via NumberFormat if your utility supports it,
                        // or let it format with digits natively.
                        CurrencyFormatter.format(user.monthlySavingsGoal, locale),
                                                style: const TextStyle(
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.primary,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(Icons.edit,
                                                  size: 16,
                                                  color: AppTheme.primary),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.secondaryContainer,
                                        borderRadius:
                                        BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        l10n.daysLeftText(daysLeft),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color:
                                          AppTheme.onSecondaryContainer,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${NumberFormat.decimalPattern(locale).format(savingsPercent)}%',
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.onSurface,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 6.0),
                                      child: Text(
                                        l10n.completed,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                          color: AppTheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: AlignmentDirectional.centerStart,
                                    widthFactor: (savingsPercent / 100)
                                        .clamp(0.0, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary,
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.savedGoalText(
                                    CurrencyFormatter.format(liveSavings, locale),
                                    CurrencyFormatter.format(user.monthlySavingsGoal, locale),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ============================================================
                    // Quick Actions — all same size, matching style
                    // ============================================================
                    SizedBox(
                      height: 144,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                // New Budget — calls onNavigateToBudgets to switch tab
                                Expanded(
                                  child: _buildActionCard(
                                    l10n.newBudget,
                                    Icons.add_circle,
                                    AppTheme.primaryContainer,
                                    AppTheme.onPrimaryContainer,
                                    onNavigateToBudgets,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Reports
                                Expanded(
                                  child: _buildActionCard(
                                    l10n.reports,
                                    Icons.analytics,
                                    AppTheme.secondaryContainer,
                                    AppTheme.onSecondaryContainer,
                                        () => showReportsSheet(context, budgets),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Insights — full height
                          Expanded(
                            child: _buildActionCard(
                              l10n.insights,
                              Icons.tips_and_updates,
                              AppTheme.tertiaryContainer,
                              AppTheme.onTertiaryContainer,
                                  () => showInsightsSheet(context, budgets, daysLeft),
                              isFullHeight: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Active Budgets section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.activeBudgets,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          //  calls callback to switch to Budgets tab
                          onPressed: onNavigateToBudgets,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            alignment: Alignment.centerRight,
                          ),
                          child:  Text(
                            l10n.manage,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppTheme.primaryContainer,
                              decorationThickness: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Budget List
                    if (budgets.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.account_balance_wallet,
                                size: 48, color: AppTheme.outlineVariant),
                            const SizedBox(height: 16),
                             Text(
                              l10n.noBudgetsYet,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 8),
                             Text(
                              l10n.tapNewBudgetToStart,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: onNavigateToBudgets,
                              icon: const Icon(Icons.add),
                              label:  Text(l10n.createFirstBudget),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: const Color(0xFFEBFFE0),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: budgets.take(3).map((budget) {
                            final colors =
                            _getColorsForScheme(budget.colorScheme);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: _buildMiniBudgetCard(
                                // Dynamic translation fix
                                (budget.categoryKey == 'custom' && budgetCategories.any((c) => c.key == budget.customTitle))
                                    ? CategoryLocalization.getCategoryName(context, budget.customTitle, '')
                                    : CategoryLocalization.getCategoryName(context, budget.categoryKey, budget.customTitle),
                                l10n.amountLeftText(
                                  NumberFormat.decimalPattern(locale).format(budget.remaining),
                                ),
                                budget.spentRatio,
                                _getIconData(budget.iconName),
                                colors['iconBg']!,
                                colors['iconColor']!,
                                colors['progressColor']!,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getGreeting(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final hour = DateTime.now().hour;

    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }



  Widget _buildActionCard(
      String title,
      IconData icon,
      Color bg,
      Color color,
      VoidCallback onTap, {
        bool isFullHeight = false,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: isFullHeight ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBudgetCard(
      String title,
      String subtitle,
      double fillRatio,
      IconData iconData,
      Color iconBg,
      Color iconColor,
      Color progressColor,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(iconData, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface)),
                ],
              ),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: fillRatio,
              child: Container(
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, Color> _getColorsForScheme(String colorScheme) {
    switch (colorScheme) {
      case 'green':
        return {
          'iconBg': AppTheme.primaryContainer,
          'iconColor': AppTheme.onPrimaryContainer,
          'progressColor': AppTheme.primary,
        };
      case 'blue':
        return {
          'iconBg': AppTheme.secondaryContainer,
          'iconColor': AppTheme.onSecondaryContainer,
          'progressColor': AppTheme.secondary,
        };
      case 'yellow':
        return {
          'iconBg': AppTheme.tertiaryContainer,
          'iconColor': AppTheme.onTertiaryContainer,
          'progressColor': AppTheme.tertiary,
        };
      default:
        return {
          'iconBg': AppTheme.surfaceContainer,
          'iconColor': AppTheme.onSurface,
          'progressColor': AppTheme.primary,
        };
    }
  }

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
      default:
        return Icons.category;
    }
  }

  static void _showEditSavingsGoalDialog(
      BuildContext context, UserModel user, UserService userService) {
    // 1. Get the current active language code
    final String locale = Localizations.localeOf(context).languageCode;

    // 2. Use '0' pattern instead of decimalPattern to avoid inserting thousands-separator
    // commas (like ١٬٥٠٠) inside the input field, making it much easier to edit.
    final controller = TextEditingController(
      text: NumberFormat('0', locale).format(user.monthlySavingsGoal),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.editSavingsGoal,
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),

          // ======= ARABIC FORMATTER =======
          inputFormatters: [ArabicNumberInputFormatter(locale)],
          // =================================

          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.monthlyGoal,
            hintText: AppLocalizations.of(context)!.enterMonthlySavingsGoal,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              // 3. SANITIZE THE INPUT BEFORE PARSING
              String textInput = controller.text;

              // Maps Eastern Arabic digits to standard Western digits
              const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
              const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

              for (int i = 0; i < 10; i++) {
                textInput = textInput.replaceAll(arabicDigits[i], englishDigits[i]);
              }

              // Replace Arabic decimal separators (٫) and thousands separators spaces/commas
              textInput = textInput
                  .replaceAll('٫', '.')
                  .replaceAll(',', '')
                  .replaceAll(' ', '');

              // 4. Now double.tryParse can read it perfectly!
              final newGoal = double.tryParse(textInput) ?? 0.0;

              if (newGoal > 0) {
                await userService.updateSavingsGoal(user.id, newGoal);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }
  // DRAWER UI DESIGN
  Widget _buildDrawer(BuildContext context, UserService userService, String userId) {
    final l10n = AppLocalizations.of(context)!;
    return Drawer(
      backgroundColor: AppTheme.neutral,
      child: StreamBuilder<UserModel?>(
        stream: userService.getUserStream(userId),
        builder: (context, snapshot) {
          final user = snapshot.data;

          return Column(
            children: [
              // Header with Profile Pic and Name
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: AppTheme.primary),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: AppTheme.primaryContainer,
                  backgroundImage: (user?.photoUrl != null && user!.photoUrl.isNotEmpty)
                      ? NetworkImage(user.photoUrl)
                      : null,
                  child: (user?.photoUrl == null || user!.photoUrl.isEmpty)
                      ? const Icon(Icons.person, color: AppTheme.primary, size: 40)
                      : null,
                ),
                accountName: Text(
                  user?.name ?? AppLocalizations.of(context)!.loading,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                accountEmail: Text(user?.email ?? ''),
              ),

              // Navigation Options - Matches Bottom Nav
              _buildDrawerItem(context, l10n.home, Icons.home_rounded, 0),
              _buildDrawerItem(context, l10n.budgets, Icons.account_balance_wallet_rounded, 1),
              _buildDrawerItem(context, l10n.invest, Icons.trending_up_rounded, 2),
              _buildDrawerItem(context, l10n.profile, Icons.person_rounded, 3),

              const Spacer(),
              const Divider(),

              // Logout Option
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: Text(
                    l10n.logout, style: TextStyle(color: Colors.redAccent)),
                onTap: () async {
                  await AuthService().logout();
                },
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  // Helper to build drawer items consistently
  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, int index) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Manrope'),
      ),
      onTap: () {
        Navigator.pop(context); // Close the drawer first
        onNavigateToTab(index); // Switch the tab in MainScreen
      },
    );
  }
}
