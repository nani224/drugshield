import 'package:flutter/material.dart';

/// ============================================================================
/// DrugShield Design System — Tactical High-Contrast HUD Theme
/// SIH26231: Digital Companion for Field Drug Testing
///
/// Designed for extreme field conditions:
///   - OLED True Black base for night operations & sunlight readability
///   - WCAG AAA (7:1+) contrast ratios across all text/background pairs
///   - MIL-STD-1472 inspired touch targets (min 56dp) for gloved operation
/// ============================================================================

class DSColors {
  DSColors._();

  // ── Background & Surface ──
  static const Color bgAbyssal     = Color(0xFF000000); // Pure OLED black
  static const Color surfaceCarbon = Color(0xFF121721); // Card/Container
  static const Color surfaceBorder = Color(0xFF1E293B); // Hairline dividers

  // ── Text ──
  static const Color textPrimary   = Color(0xFFFFFFFF); // Headlines (21:1)
  static const Color textSecondary = Color(0xFF94A3B8); // Subtitles (7.4:1)
  static const Color textDisabled  = Color(0xFF475569);

  // ── Semantic Accents ──
  static const Color accentEmerald = Color(0xFF00E676); // Verified / Confirmed
  static const Color accentAmber   = Color(0xFFFFB300); // Presumptive / Warning
  static const Color accentCrimson = Color(0xFFFF1744); // Error / Breach
  static const Color hudCyan       = Color(0xFF00E5FF); // Camera reticle / HUD

  // ── Substance Category Colors (for charts & map pins) ──
  static const Color substCocaine  = Color(0xFF00B0FF); // Cyan-Blue
  static const Color substOpioid   = Color(0xFFAA00FF); // Violet
  static const Color substMeth     = Color(0xFFFFAB00); // Amber
  static const Color substCannabis = Color(0xFF00E676); // Green
  static const Color substLSD      = Color(0xFFFF4081); // Pink
}

class DSTypography {
  DSTypography._();

  static const String fontInter = 'Inter';
  static const String fontMono  = 'JetBrainsMono';

  static TextStyle headline1 = const TextStyle(
    fontFamily: fontInter,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: DSColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle headline2 = const TextStyle(
    fontFamily: fontInter,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: DSColors.textPrimary,
  );

  static TextStyle body = const TextStyle(
    fontFamily: fontInter,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: DSColors.textSecondary,
    height: 1.5,
  );

  static TextStyle label = const TextStyle(
    fontFamily: fontInter,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: DSColors.textSecondary,
    letterSpacing: 0.5,
  );

  static TextStyle mono = const TextStyle(
    fontFamily: fontMono,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: DSColors.hudCyan,
    letterSpacing: 0.8,
  );

  static TextStyle monoSmall = const TextStyle(
    fontFamily: fontMono,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: DSColors.textSecondary,
  );

  static TextStyle buttonText = const TextStyle(
    fontFamily: fontInter,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: DSColors.bgAbyssal,
    letterSpacing: 0.5,
  );
}

class DSTheme {
  DSTheme._();

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DSColors.bgAbyssal,
      colorScheme: const ColorScheme.dark(
        surface: DSColors.bgAbyssal,
        primary: DSColors.accentEmerald,
        secondary: DSColors.hudCyan,
        error: DSColors.accentCrimson,
        onSurface: DSColors.textPrimary,
        onPrimary: DSColors.bgAbyssal,
      ),
      cardTheme: CardTheme(
        color: DSColors.surfaceCarbon,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: DSColors.surfaceBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: DSColors.bgAbyssal,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: DSColors.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DSColors.accentEmerald,
          foregroundColor: DSColors.bgAbyssal,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: DSTypography.buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DSColors.textPrimary,
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: DSColors.surfaceBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DSColors.surfaceCarbon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DSColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DSColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DSColors.hudCyan, width: 2),
        ),
        labelStyle: DSTypography.label,
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: DSColors.textDisabled,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dividerTheme: const DividerThemeData(
        color: DSColors.surfaceBorder,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DSColors.surfaceCarbon,
        contentTextStyle: DSTypography.body.copyWith(color: DSColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
