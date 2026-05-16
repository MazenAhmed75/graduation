import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// LocaleService
//
// Saves and loads the user's chosen language using
// SharedPreferences so the choice persists across app restarts.
//
// USAGE:
//   // Read on startup
//   final locale = await LocaleService.getSavedLocale();
//
//   // Save when user switches language
//   await LocaleService.saveLocale(const Locale('ar'));
// ============================================================

class LocaleService {
  static const String _key = 'app_locale';

  // ── Save the user's chosen locale ('en' or 'ar') ─────────────
  static Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }

  // ── Load the saved locale, defaulting to English ─────────────
  static Future<Locale> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'en';
    return Locale(code);
  }

  // ── Quick check: is Arabic currently active? ─────────────────
  static Future<bool> isArabic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) == 'ar';
  }
}