import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Handles localized formatting and safe parsing for currency values
class CurrencyFormatter {
  /// Formats a double to a localized currency string (e.g., EGP ١٬٥٠٠٫٠٠ or EGP 1,500.00)
  static String format(double amount, String locale) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '\$',
      decimalDigits: 2,
    );

    // 1. Format the number normally using intl
    String formattedAmount = formatter.format(amount);

    // 2. Force the digits into Arabic if the locale is Arabic
    return formattedAmount.toLocalizedDigits(locale);
  }

  /// Centralized parser: Safely converts both English and Eastern Arabic digits into a standard double.
  /// Use this in every screen instead of double.tryParse().
  static double parse(String text, {double defaultValue = 0.0}) {
    if (text.trim().isEmpty) return defaultValue;

    String standardizedNumbers = text;
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    for (int i = 0; i < 10; i++) {
      standardizedNumbers = standardizedNumbers.replaceAll(arabicDigits[i], englishDigits[i]);
    }

    // Also standardize the Arabic decimal separator to a standard dot
    standardizedNumbers = standardizedNumbers.replaceAll('٫', '.').replaceAll(',', '');

    return double.tryParse(standardizedNumbers) ?? defaultValue;
  }
}

/// Automatically converts English digits to Eastern Arabic digits in TextFields when the locale is Arabic
class ArabicNumberInputFormatter extends TextInputFormatter {
  final String locale;

  ArabicNumberInputFormatter(this.locale);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (!locale.startsWith('ar')) return newValue;

    String text = newValue.text;
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < 10; i++) {
      text = text.replaceAll(englishDigits[i], arabicDigits[i]);
    }

    return newValue.copyWith(
      text: text,
      selection: newValue.selection,
    );
  }
}

// ==========================================
// THE NEW EXTENSION
// ==========================================
extension ArabicNumbersExtension on String {
  /// Converts English digits to Eastern Arabic numerals if the locale is Arabic
  String toLocalizedDigits(String locale) {
    // Check if the locale starts with 'ar' (covers 'ar', 'ar_EG', 'ar_SA', etc.)
    if (!locale.startsWith('ar')) return this;

    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = this;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }

    return result;
  }
}