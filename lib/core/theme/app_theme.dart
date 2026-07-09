import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _AppColors.backgroundMint,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF32B8E8), // Vibrant Cyan
        onPrimary: Colors.white,
        secondary: Color(0xFF7CD070), // Vibrant Green
        onSecondary: Colors.white,
        tertiary: Color(0xFF6366F1), // Vibrant Indigo
        onTertiary: Colors.white,
        surface: Colors.white, // Cards and surfaces should be white to pop
        onSurface: _AppColors.textDark,
        error: _AppColors.error,
        onError: Colors.white,
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),
        outline: Color(0xFFCBD5E1),
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: _AppColors.textDark,
        displayColor: _AppColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: _AppColors.backgroundMint,
        foregroundColor: _AppColors.textDark,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: _AppColors.primaryBlue.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1B242C), width: 1.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.error)) {
            return const TextStyle(color: _AppColors.error, fontWeight: FontWeight.bold);
          }
          return const TextStyle(color: _AppColors.primaryBlue);
        }),
        labelStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.error)) {
            return const TextStyle(color: _AppColors.error);
          }
          return const TextStyle(color: _AppColors.textDark);
        }),
        errorStyle: const TextStyle(color: _AppColors.error, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _AppColors.fitnessGreen, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _AppColors.fitnessGreen.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _AppColors.error, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _AppColors.primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: _AppColors.brandCyanDark,
        onPrimary: _AppColors.darkBackground,
        secondary: _AppColors.secondaryBlueDark,
        onSecondary: _AppColors.darkBackground,
        tertiary: _AppColors.proteinIndigoDark,
        onTertiary: Colors.white,
        surface: _AppColors.darkSurface,
        onSurface: _AppColors.darkText,
        surfaceContainerHighest: Color(0xFF233039), // Deep Navy Lighter
        surfaceContainerHigh: Color(0xFF1F2932),
        surfaceContainer: Color(0xFF1B242C),
        surfaceContainerLow: Color(0xFF161E24),
        surfaceContainerLowest: Color(0xFF0F1418),
        error: _AppColors.error,
        onError: Colors.white,
        outline: _AppColors.darkBorder,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: _AppColors.darkText,
        displayColor: _AppColors.darkText,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: _AppColors.darkBackground,
        foregroundColor: _AppColors.darkText,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _AppColors.darkText,
        ),
      ),
      cardTheme: CardThemeData(
        color: _AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _AppColors.darkBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _AppColors.darkInputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _AppColors.brandCyanDark, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AppColors {
  const _AppColors._();

  // Custom Light Palette
  static const Color fitnessGreen = Color(0xFF69995D);
  static const Color backgroundMint = Color(0xFFF7FFF7);
  static const Color primaryBlue = Color(0xFF087CA7);
  static const Color textDark = Color(0xFF1B1B1B);

  // New Dark Palette Colors (Modern Deep Navy/Teal)
  static const Color brandCyanDark = Color(0xFF268FB1); // Ocean Blue (Dimmed)
  static const Color secondaryBlueDark = Color(0xFF5D9B53); // Sage Green (Dimmed)
  static const Color proteinIndigoDark = Color(0xFF4F46E5); // Indigo (Dimmed)
  static const Color darkBackground = Color(0xFF0F1418); // Very Deep Navy Background
  static const Color darkSurface = Color(0xFF1B242C); // Deep Ocean Surface for cards
  static const Color error = Color(0xFFEF4444);

  // Dark Mode Support Colors
  static const Color darkText = Color(0xFFE2E2E2); // Off-white/grey text
  static const Color darkBorder = Color(0xFF25313A); // Deep Navy Border
  static const Color darkInputFill = Color(0xFF141C22); // Darker navy for inputs

  // UI Support Colors
  static const Color slate050 = Color(0xFFF9FAFB);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
}
