<<<<<<< HEAD
// ignore_for_file: unnecessary_non_null_assertion

=======
>>>>>>> 8d74ad55b5bab5a46ab285fac6e80e24915b999a
import 'package:flutter/material.dart';
import 'package:mindful_curator/l10n/app_localizations.dart';

class CategoryLocalization {
  static String getCategoryName(
      BuildContext context,
      String categoryKey,
      String customTitle,
      ) {
    final l10n = AppLocalizations.of(context)!;

    // Custom category
    if (categoryKey == 'custom') {
      return customTitle;
    }

    switch (categoryKey) {
      case 'groceries':
        return l10n.category_groceries;

      case 'travel':
        return l10n.category_travel;

      case 'entertainment':
        return l10n.category_entertainment;

      case 'food':
        return l10n.category_food;

      case 'shopping':
        return l10n.category_shopping;

      case 'custom':
        return l10n.category_custom;

      default:
        return categoryKey;
    }
  }
}