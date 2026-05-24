import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mindful_curator/theme.dart';
import 'package:mindful_curator/screens/home_screen.dart';
import 'package:mindful_curator/screens/budgets_screen.dart';
import 'package:mindful_curator/screens/profile_screen.dart';
import 'package:mindful_curator/screens/invest_screen.dart';
import 'package:mindful_curator/l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  // 0=Home 1=Budgets 2=Invest 3=Profile
  final ValueNotifier<bool> _isDrawerOpen = ValueNotifier(false);

  // ============================================================
  // This function lets child screens switch the tab.
  // We pass it down as a callback so HomeScreen can call it.
  // ============================================================
  void _switchToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Build screens here so we can pass the callback to HomeScreen
    final List<Widget> screens = [
      // Pass the _switchToTab function directly to HomeScreen
      // READ DRAWER STATE FROM HOME SCREEN
      HomeScreen(
        onNavigateToBudgets: () => _switchToTab(1),
        onNavigateToTab: _switchToTab,
        onDrawerChanged: (isOpen) {
          _isDrawerOpen.value = isOpen;
        },
      ),
      const BudgetsScreen(),
      const InvestScreen(),
      ProfileScreen(onNavigateToTab: _switchToTab),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: ValueListenableBuilder<bool>(
        valueListenable: _isDrawerOpen,
        builder: (context, isDrawerOpen, child) {
          return AnimatedSlide(
            duration: const Duration(milliseconds: 180),
            offset: isDrawerOpen
                ? const Offset(0, 1.5)
                : Offset.zero,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isDrawerOpen ? 0 : 1,
              child: child,
            ),
          );
        },

        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            border: Border(
              top: BorderSide(
                color: AppTheme.outlineVariant.withOpacity(0.15),
                width: 1,
              ),
            ),
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E342B).withOpacity(0.04),
                offset: const Offset(0, -10),
                blurRadius: 30,
              ),
            ],
          ),
          height: 90,
          child: ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    0,
                    Icons.home_rounded,
                    l10n.home,
                  ),

                  _buildNavItem(
                    1,
                    Icons.account_balance_wallet_rounded,
                    l10n.budgets,
                  ),

                  _buildNavItem(
                    2,
                    Icons.trending_up_rounded,
                    l10n.invest,
                  ),

                  _buildNavItem(
                    3,
                    Icons.person_rounded,
                    l10n.profile,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _switchToTab(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(24),
        )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected
                  ? const Color(0xFFEBFFE0)
                  : AppTheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isSelected
                    ? const Color(0xFFEBFFE0)
                    : AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}