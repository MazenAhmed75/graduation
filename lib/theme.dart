import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors from DESIGN.md
  static const Color primary = Color(0xFF3C6A35);
  static const Color secondary = Color(0xFF4B6368);
  static const Color neutral = Color(0xFFF8FAF2); // base surface
  static const Color primaryDim = Color(0xFF305D2A);
  
  static const Color surfaceContainerLow = Color(0xFFF1F5EB);
  static const Color surfaceContainer = Color(0xFFEBEFE4);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color outlineVariant = Color(0xFFADB4A7);
  static const Color outline = Color(0xFF767D71);
  static const Color onSurface = Color(0xFF2E342B);
  static const Color onSurfaceVariant = Color(0xFF5A6156);
  static const Color primaryContainer = Color(0xFFB9EEAB);
  static const Color onPrimaryContainer = Color(0xFF2D5A27);

  static const Color secondaryContainer = Color(0xFFCDE7ED);
  static const Color onSecondaryContainer = Color(0xFF3E565A);
  static const Color secondaryFixed = Color(0xFFCDE7ED);
  static const Color onSecondaryFixed = Color(0xFF2B4348);

  static const Color tertiary = Color(0xFF62622C);
  static const Color tertiaryContainer = Color(0xFFFBFAB5);
  static const Color onTertiaryContainer = Color(0xFF60602A);
  static const Color errorContainer = Color(0xFFFD795A);
  static const Color onErrorContainer = Color(0xFF6E1400);

  // App Theme Base
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: neutral,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outlineVariant: outlineVariant,
      ),
      scaffoldBackgroundColor: neutral,
      textTheme: GoogleFonts.manropeTextTheme().copyWith(
        displayMedium: GoogleFonts.manrope(
          fontSize: 36, // 2.25rem according to tailwind display sizes generally. 
          letterSpacing: -0.88, 
          fontWeight: FontWeight.w800,
        ),
        headlineSmall: GoogleFonts.manrope(
          fontSize: 24, // 1.5rem
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.manrope(
          fontSize: 18, // 1.125rem
          fontWeight: FontWeight.w600, // Semi-Bold
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 14, // 0.875rem
          height: 1.6,
        ),
      ),
    );
  }
}
