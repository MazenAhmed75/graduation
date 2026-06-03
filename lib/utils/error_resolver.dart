import 'package:flutter/widgets.dart';
import 'package:mindful_curator/l10n/app_localizations.dart';

extension LocalizedErrorResolver on BuildContext {
  /// Translates any backend or service error key into its localized UI string.
  String translateError(String? errorKey, [List<String>? errorArgs, Map<String, String>? mapArgs]) {
    if (errorKey == null) return '';

    final localizations = AppLocalizations.of(this);
    if (localizations == null) return '';

    // Safeguard to extract the first argument if your ARB translation expects one
    final primaryArg = (errorArgs != null && errorArgs.isNotEmpty) ? errorArgs.first : '';
    final secondaryArg = (errorArgs != null && errorArgs.length > 1) ? errorArgs[1] : '';

    switch (errorKey) {
    // ── ALPACA SERVICE KEYS ──────────────────────────────────────────
      case 'alpaca_not_configured_settings':
        return localizations.alpaca_not_configured_settings;
      case 'alpaca_not_configured':
        return localizations.alpaca_not_configured;
      case 'order_failed':
        return localizations.order_failed;
      case 'close_failed':
        return localizations.close_failed(primaryArg);
      case 'sell_failed':
        return localizations.sell_failed(primaryArg);
      case 'alpaca_api_error':
        return localizations.alpaca_api_error(primaryArg);
      case 'alpaca_exception':
        return localizations.alpaca_exception(primaryArg);


    // ── AUTH SERVICE KEYS ───────────────────────────────────────────
      case 'invalid_credential':
        return Localizations.localeOf(this).languageCode == 'ar'
            ? 'البريد الإلكتروني أو كلمة المرور غير صحيحة.'
            : 'Invalid email address or password.';

      case 'email_already_in_use':          return localizations.emailAlreadyInUse;
      case 'weak_password':                 return localizations.weakPassword;
      case 'invalid_email':                 return localizations.invalidEmail;
      case 'unexpected_error':              return localizations.unexpectedError;
      case 'user_not_found':                return localizations.userNotFound;
      case 'wrong_password':                return localizations.wrongPassword;
      case 'google_sign_in_cancelled':      return localizations.googleSignInCancelled;
      case 'google_sign_in_failed':         return localizations.googleSignInFailed;
      case 'change_password_user_not_found': return localizations.changePasswordUserNotFound;
      case 'change_password_wrong_password': return localizations.changePasswordWrongPassword;

      case 'registration_failed':
        return Localizations.localeOf(this).languageCode == 'ar'
            ? 'حدث خطأ أثناء إنشاء الحساب. يرجى المحاولة مرة أخرى.'
            : 'An error occurred during registration. Please try again.';

      case 'login_failed':
        return Localizations.localeOf(this).languageCode == 'ar'
            ? 'فشل تسجيل الدخول. يرجى التحقق من بياناتك.'
            : 'Login failed. Please check your credentials.';

      case 'password_reset_failed':
        return Localizations.localeOf(this).languageCode == 'ar'
            ? 'فشل إرسال بريد إعادة التعيين. يرجى المحاولة مرة أخرى.'
            : 'Failed to send reset email. Please try again.';

      case 'auth_generic_message':
        return Localizations.localeOf(this).languageCode == 'ar'
            ? 'حدث خطأ في المصادقة. يرجى المحاولة لاحقاً.'
            : 'An authentication error occurred. Please try again later.';

    // ── AGENT SERVICE LOGS ───────────────────────────────────────────
      case 'auto_trade_enabled':
        return localizations.auto_trade_enabled(mapArgs?['interval'] ?? '');
      case 'auto_trade_disabled':
        return localizations.auto_trade_disabled;
      case 'cycle_started_gathering':
        return localizations.cycle_started_gathering;
      case 'no_market_data':
        return localizations.no_market_data;
      case 'data_ready':
        return localizations.data_ready(
          mapArgs?['assets'] ?? '0',
          mapArgs?['news'] ?? '0',
          mapArgs?['positions'] ?? '0',
          mapArgs?['cash'] ?? '0',
        );
      case 'step_analyzing_sentiment':
        return localizations.step_analyzing_sentiment;
      case 'analysis_failed':
        return localizations.analysis_failed;
      case 'sentiment_preview':
        return localizations.sentiment_preview(mapArgs?['preview'] ?? '');
      case 'step_evaluating_positions':
        return localizations.step_evaluating_positions;
      case 'position_hold':
        return localizations.position_hold(mapArgs?['name'] ?? '', mapArgs?['reason'] ?? '');
      case 'position_action':
        return localizations.position_action(mapArgs?['action'] ?? '', mapArgs?['name'] ?? '', mapArgs?['reason'] ?? '');
      case 'position_closed':
        return localizations.position_closed(mapArgs?['name'] ?? '');
      case 'parse_positions_error':
        return localizations.parse_positions_error(mapArgs?['error'] ?? '');
      case 'no_open_positions':
        return localizations.no_open_positions;
      case 'step_scanning_buy_opps':
        return localizations.step_scanning_buy_opps;
      case 'parse_buy_opps_error':
        return localizations.parse_buy_opps_error(mapArgs?['error'] ?? '');
      case 'buy_opportunities_found':
        return localizations.buy_opportunities_found(mapArgs?['count'] ?? '0');
      case 'no_buy_opportunities':
        return localizations.no_buy_opportunities;
      case 'cycle_complete_with_sells':
        return localizations.cycle_complete_with_sells(mapArgs?['count'] ?? '0', mapArgs?['nextRun'] ?? '');
      case 'cycle_complete_no_sells':
        return localizations.cycle_complete_no_sells(mapArgs?['nextRun'] ?? '');
      case 'cycle_error':
        return localizations.cycle_error(mapArgs?['error'] ?? '');


    // ── BUDGET SERVICE LOGS ───────────────────────────────────────────

      case 'budget_warning_title':
        return Localizations.localeOf(this).languageCode == 'ar'
            ? 'تحذير الميزانية'
            : 'Budget Warning';

      case 'budget_warning_body':
        final percentUsed = errorArgs != null && errorArgs.isNotEmpty ? errorArgs[0] : '0';
        final categoryKey = errorArgs != null && errorArgs.length > 1 ? errorArgs[1] : '';
        // Resolve the category name dynamically within the extension context
        final localizedCategory = translateError('category_$categoryKey');

        return Localizations.localeOf(this).languageCode == 'ar'
            ? 'لقد استهلكت $percentUsed٪ من ميزانية $localizedCategory.'
            : 'You have used $percentUsed% of your $localizedCategory budget.';

    // Fallback category translations dynamically evaluated
      case 'category_food':
        return Localizations.localeOf(this).languageCode == 'ar' ? 'الطعام ' : 'Food & Dining';
      case 'category_transport':
        return Localizations.localeOf(this).languageCode == 'ar' ? 'المواصلات' : 'Transportation';
      case 'category_shopping':
        return Localizations.localeOf(this).languageCode == 'ar' ? 'التسوق' : 'Shopping';
      case 'category_entertainment':
        return Localizations.localeOf(this).languageCode == 'ar' ? 'الترفيه' : 'Entertainment';
      case 'category_bills':
        return Localizations.localeOf(this).languageCode == 'ar' ? 'الفواتير والخدمات' : 'Bills & Utilities';

    // ── RECURRING SERVICE LOGS ───────────────────────────────────────────

      case 'recurring_fallback':
        final fallbackTitle = errorArgs != null && errorArgs.isNotEmpty ? errorArgs[0] : '';
        return AppLocalizations.of(this)!.recurring_fallback(fallbackTitle);

      case 'auto_prefix':
        final rawNote = errorArgs != null && errorArgs.isNotEmpty ? errorArgs[0] : '';
        // If the inner note is also a structured key, recursively decode it; otherwise display it directly
        String processedNote = rawNote;
        if (rawNote.contains(':')) {
          final parts = rawNote.split(':');
          processedNote = translateError(parts[0], [parts.sublist(1).join(':')]);
        }
        return AppLocalizations.of(this)!.auto_prefix(processedNote);

    // ── STORAGE SERVICE LOGS ───────────────────────────────────────────


      case 'cloudinary_upload_failed':
        return AppLocalizations.of(this)!.cloudinary_upload_failed;

      case 'failed_to_upload':
        return AppLocalizations.of(this)!.failed_to_upload;

    // ── STORAGE SERVICE LOGS ───────────────────────────────────────────


    // ── GLOBAL FALLBACK ──────────────────────────────────────────────
      default:
        return localizations.order_failed;
    }
  }
}