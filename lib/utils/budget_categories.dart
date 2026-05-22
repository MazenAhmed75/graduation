import '../models/budget_category.dart';

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