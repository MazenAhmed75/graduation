import 'package:flutter/material.dart';
import '../models/budget_category.dart';
import '../theme.dart';

const List<BudgetCategory> budgetCategories = [
  BudgetCategory(
    key: 'groceries',
    iconName: 'shopping_cart',
    colorScheme: 'green',
  ),
  BudgetCategory(
    key: 'travel',
    iconName: 'flight',
    colorScheme: 'blue',
  ),
  BudgetCategory(
    key: 'entertainment',
    iconName: 'movie',
    colorScheme: 'purple',
  ),
  BudgetCategory(
    key: 'food',
    iconName: 'restaurant',
    colorScheme: 'orange',
  ),
  BudgetCategory(
    key: 'shopping',
    iconName: 'shopping_bag',
    colorScheme: 'pink',
  ),
  BudgetCategory(
    key: 'custom',
    iconName: 'edit',
    colorScheme: 'grey',
  ),
];

/// A central helper to convert database strings into Flutter Colors and Icons
class CategoryUIHelper {
  static Map<String, Color> getColorsForScheme(String colorScheme) {
    switch (colorScheme) {
      case 'green':
        return {
          'iconBg': AppTheme.primaryContainer,
          'iconColor': AppTheme.onPrimaryContainer,
          'progressColor': AppTheme.primary,
        };
      case 'blue':
      case 'purple':
        return {
          'iconBg': AppTheme.secondaryContainer,
          'iconColor': AppTheme.onSecondaryContainer,
          'progressColor': AppTheme.secondary,
        };
      case 'yellow':
      case 'orange':
      case 'pink':
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

  static IconData getIconData(String iconName) {
    switch (iconName) {
      case 'shopping_cart':
      case 'shopping_bag':
        return Icons.shopping_cart;
      case 'home':
        return Icons.home;
      case 'theater_comedy':
      case 'movie':
        return Icons.theater_comedy;
      case 'flight_takeoff':
      case 'flight':
        return Icons.flight_takeoff;
      case 'restaurant':
      case 'food':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'edit':
        return Icons.edit;
      default:
        return Icons.category;
    }
  }
}