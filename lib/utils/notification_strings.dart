import '../services/locale_service.dart';
import 'currency_formatter.dart'; // adjust path to match yours

class NotificationStrings {

  // ── Internal: read once and reuse across all methods ────
  static Future<String> _localeCode() async {
    final locale = await LocaleService.getSavedLocale();
    return locale.languageCode; // 'en' or 'ar'
  }

  static bool _isAr(String code) => code.startsWith('ar');

  // ── Budget exceeded ──────────────────────────────────────
  static Future<String> budgetExceededTitle(String budgetTitle) async {
    final code = await _localeCode();
    return _isAr(code)
        ? '🚨 تجاوز الميزانية: $budgetTitle'
        : '🚨 Budget Exceeded: $budgetTitle';
  }

  static Future<String> budgetExceededBody(String budgetTitle) async {
    final code = await _localeCode();
    return _isAr(code)
        ? 'لقد تجاوزت ميزانية $budgetTitle!'
        : 'You have gone over your $budgetTitle budget!';
  }

  // ── Budget warning ───────────────────────────────────────
  static Future<String> budgetWarningTitle(String budgetTitle) async {
    final code = await _localeCode();
    return _isAr(code)
        ? '⚠️ تنبيه الميزانية: $budgetTitle'
        : '⚠️ Budget Alert: $budgetTitle';
  }

  static Future<String> budgetWarningBody(
      String budgetTitle,
      int percent,
      int days,
      ) async {
    final code = await _localeCode();

    // ← your extension converts digits to ٨٠ / ١٢ automatically
    final localPercent = percent.toString().toLocalizedDigits(code);
    final localDays    = days.toString().toLocalizedDigits(code);

    return _isAr(code)
        ? 'لقد استخدمت $localPercent٪ من ميزانية $budgetTitle مع تبقي $localDays أيام.'
        : 'You\'ve used $localPercent% of your $budgetTitle budget with $localDays days left.';
  }

  // ── Savings milestone ────────────────────────────────────
  static Future<String> savingsTitle() async {
    final code = await _localeCode();
    return _isAr(code)
        ? '🎉 تقدم هدف الادخار'
        : '🎉 Savings Goal Progress';
  }

  static Future<String> savingsBody(int percent) async {
    final code = await _localeCode();
    final localPercent = percent.toString().toLocalizedDigits(code);

    return _isAr(code)
        ? 'أنت في $localPercent٪ من طريقك نحو هدفك الشهري للادخار!'
        : 'You\'re $localPercent% of the way to your monthly savings goal!';
  }

  // ── Weekly recap ─────────────────────────────────────────
  static Future<String> weeklyTitle() async {
    final code = await _localeCode();
    return _isAr(code)
        ? 'ملخص إنفاقك الأسبوعي 📊'
        : 'Your Weekly Spending Recap 📊';
  }

  static Future<String> weeklyBody(int percent, String category) async {
    final code = await _localeCode();
    final localPercent = percent.toString().toLocalizedDigits(code);

    return _isAr(code)
        ? 'استخدمت $localPercent٪ من ميزانيتك. الأكثر إنفاقاً: $category.'
        : 'You used $localPercent% of your budget. Most spent: $category.';
  }
}