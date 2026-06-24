import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Brand cyan color extracted from the Bonyaan logo
  static const Color brandCyan = Color(0xFF00D4FF);

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _AppColors.lightBackground,
      colorScheme: ColorScheme.light(
        primary: _AppColors.brandCyanLight,
        onPrimary: Colors.white,
        secondary: _AppColors.secondaryBlue,
        onSecondary: Colors.white,
        tertiary: _AppColors.accentOrangeLight,
        onTertiary: Colors.white,
        error: _AppColors.error,
        onError: Colors.white,
        surface: _AppColors.lightSurface,
        onSurface: _AppColors.slate950,
        inverseSurface: _AppColors.slate100,
        onInverseSurface: _AppColors.slate950,
        inversePrimary: _AppColors.brandCyanLight,
        surfaceTint: _AppColors.brandCyanLight,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: _AppColors.slate950,
        displayColor: _AppColors.slate950,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _AppColors.lightSurface,
        foregroundColor: _AppColors.slate950,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _AppColors.slate950,
        ),
      ),
      cardTheme: CardThemeData(
        color: _AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _AppColors.slate200),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _AppColors.slate100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _AppColors.slate300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _AppColors.slate300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _AppColors.brandCyanLight, width: 1.5),
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
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: _AppColors.slate300),
        selectedColor: _AppColors.brandCyanLight.withValues(alpha: 0.15),
        backgroundColor: _AppColors.slate100,
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: _AppColors.slate900,
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
      colorScheme: ColorScheme.dark(
        primary: _AppColors.brandCyanDark,
        onPrimary: _AppColors.slate950, // Dark text on bright cyan buttons
        secondary: _AppColors.secondaryBlueDark,
        onSecondary: _AppColors.slate950,
        tertiary: _AppColors.accentOrangeDark,
        onTertiary: _AppColors.slate950,
        error: _AppColors.error,
        onError: Colors.white,
        surface: _AppColors.darkSurface,
        onSurface: _AppColors.slate100,
        outline: _AppColors.borderDark,
        shadow: Colors.black,
        inverseSurface: _AppColors.slate900,
        onInverseSurface: _AppColors.slate100,
        inversePrimary: _AppColors.brandCyanDark,
        surfaceTint: _AppColors.brandCyanDark,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: _AppColors.slate100,
        displayColor: _AppColors.slate100,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _AppColors.darkBackground, // Match scaffold background
        foregroundColor: _AppColors.slate050,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _AppColors.slate050,
        ),
      ),
      cardTheme: CardThemeData(
        color: _AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _AppColors.slate800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _AppColors.slate900,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _AppColors.slate700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _AppColors.slate700),
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
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: _AppColors.slate700),
        selectedColor: _AppColors.brandCyanDark.withValues(alpha: 0.2),
        backgroundColor: _AppColors.slate900,
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: _AppColors.slate100,
        ),
      ),
    );
  }
}

class _AppColors {
  const _AppColors._();

  // Primary Brand Colors — Cyan (matches Bonyaan logo)
  static const Color brandCyanLight = Color(0xFF0099CC); // Deep cyan for light mode (readable on white)
  static const Color brandCyanDark = Color(0xFF4DD9F0);  // Bright cyan for dark mode (pops on dark bg)

  // Secondary Colors
  static const Color secondaryBlue = Color(0xFF3C70FF);
  static const Color secondaryBlueDark = Color(0xFF85A1FF);

  // Tertiary/Accent Colors
  static const Color accentOrangeLight = Color(0xFFE55B2B); // Web Secondary Orange (Light Mode)
  static const Color accentOrangeDark = Color(0xFFFFB066);  // Brightened Orange (Dark Mode)

  static const Color error = Color(0xFFEF4444);

  // Backgrounds & Surfaces (Tailwind Slate)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);

  // Text & Borders
  static const Color slate050 = Color(0xFFF9FAFB);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);

  static const Color borderDark = Color(0xFF334155);
}