import 'package:flutter/material.dart';

/// Morandi Bullet Journal Palette — exact hex coordinates from design spec.
class AppColors {
  AppColors._();

  // ── Primary Palette ──

  /// Base background — journal notebook pages, Polaroid photo borders.
  static const Color wisteria = Color(0xFFBAACEB);

  /// Primary text, hand-drawn sketch borders, card outlines, faux sticky tape.
  static const Color ultraViolet = Color(0xFF5F5AA5);

  /// Core highlight accent — check-in stamp, active button, glowing vine leaves.
  static const Color yellowGreen = Color(0xFFB8D062);

  /// Secondary indicators — progress bar, waveform default, vocab card front.
  static const Color avocado = Color(0xFF5E891B);

  /// Deep grass — court icons, text on yellow-green backgrounds, contrast.
  static const Color pakistanGreen = Color(0xFF283B0A);

  // ── Derived shades ──

  /// Lighter ultra violet for backgrounds / tape
  static const Color ultraVioletLight = Color(0xFF8B86C8);

  /// Very light wisteria for page backgrounds
  static const Color wisteriaLight = Color(0xFFE8E3F7);

  /// Darker yellow-green for pressed states
  static const Color yellowGreenDark = Color(0xFFA3BD46);

  /// Light yellow-green for subtle glow
  static const Color yellowGreenLight = Color(0xFFDFE9B8);

  /// Lighter avocado for subtle use
  static const Color avocadoLight = Color(0xFF8CAA4E);

  // ── Semantic Colors ──
  static const Color coralRed = Color(0xFFE8A0A0);
  static const Color mintGreen = Color(0xFFA8D8B9);
  static const Color amber = Color(0xFFD8C8A0);
  static const Color skyBlue = Color(0xFFA0C4D8);

  // ── Neutrals ──
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey100 = Color(0xFFF0EDF2);
  static const Color grey200 = Color(0xFFE0DCE5);
  static const Color grey400 = Color(0xFFB0A8B8);
  static const Color grey600 = Color(0xFF807888);
  static const Color grey800 = Color(0xFF504858);
  static const Color black = Color(0xFF1A1A1A);

  // ── Gradients ──
  static const LinearGradient vineGradient = LinearGradient(
    colors: [yellowGreen, yellowGreenDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [ultraViolet, Color(0xFF4A4488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pageGradient = LinearGradient(
    colors: [wisteriaLight, wisteria],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Backward compat aliases for existing widgets ──
  static const Color pistachio = yellowGreen;
  static const Color pistachioDark = yellowGreenDark;
  static const Color pistachioLight = yellowGreenLight;
  static const Color taroDeep = ultraViolet;
  static const Color taro = wisteria;
  static const Color taroLight = wisteriaLight;
  static const Color cream = wisteriaLight;
  static const Color lavender = wisteria;
  static const Color lavenderLight = wisteriaLight;
  static const Color deepPurple = ultraViolet;
  static const Color purple = wisteria;
  static const Color voltGreen = yellowGreen;
  static const Color voltGreenDark = yellowGreenDark;
  static const Color voltGreenLight = yellowGreenLight;
  static const LinearGradient voltGradient = vineGradient;
  static const LinearGradient purpleGradient = pageGradient;
}

/// Legacy alias — prefer AppColors going forward.
typedef TennisColors = AppColors;

class TennisTheme {
  TennisTheme._();

  static const double radiusXS = 6.0;
  static const double radiusSM = 10.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 24.0;
  static const double radiusXL = 32.0;
  static const double radiusFull = 999.0;

  static const double shadowLight = 4.0;
  static const double shadowMedium = 8.0;
  static const double shadowHeavy = 16.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.wisteriaLight,

      colorScheme: const ColorScheme.light(
        primary: AppColors.avocado,
        onPrimary: AppColors.white,
        secondary: AppColors.ultraViolet,
        onSecondary: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.ultraViolet,
        error: AppColors.coralRed,
        onError: AppColors.white,
      ),

      // AppBar — ultra violet, white text
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.ultraViolet,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.white,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.wisteria,
        elevation: TennisTheme.shadowMedium,
        shadowColor: AppColors.ultraViolet.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TennisTheme.radiusLG),
        ),
      ),

      // Buttons — yellowGreen fill, pakistanGreen text
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yellowGreen,
          foregroundColor: AppColors.pakistanGreen,
          elevation: TennisTheme.shadowLight,
          shadowColor: AppColors.yellowGreen.withValues(alpha: 0.30),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ultraViolet,
          side: const BorderSide(color: AppColors.yellowGreen, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // Chips / Tags
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.wisteriaLight,
        selectedColor: AppColors.yellowGreen,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.ultraViolet,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.ultraViolet,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
        ),
        side: BorderSide.none,
      ),

      // Sliders
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.yellowGreen,
        inactiveTrackColor: AppColors.wisteria,
        thumbColor: AppColors.yellowGreen,
        overlayColor: AppColors.yellowGreen.withValues(alpha: 0.20),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
        valueIndicatorColor: AppColors.yellowGreen,
        valueIndicatorTextStyle: const TextStyle(
          color: AppColors.pakistanGreen,
          fontWeight: FontWeight.w800,
        ),
      ),

      // Progress bars
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.avocado,
        linearTrackColor: AppColors.wisteriaLight,
        circularTrackColor: AppColors.wisteriaLight,
      ),

      // Bottom Nav
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.ultraViolet,
        selectedItemColor: AppColors.yellowGreen,
        unselectedItemColor: AppColors.grey400,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),

      // Dividers
      dividerTheme: DividerThemeData(
        color: AppColors.wisteria.withValues(alpha: 0.5),
        thickness: 1,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.ultraViolet,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TennisTheme.radiusLG),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.white,
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ultraViolet,
        contentTextStyle: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TennisTheme.radiusMD),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
