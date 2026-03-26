import 'package:flutter/material.dart';

class AppTheme {
  static const Color bgPrimary = Color(0xFF070B14);
  static const Color bgSecondary = Color(0xFF0C1322);
  static const Color accentCyan = Color(0xFF2EE6D6);
  static const Color accentBlue = Color(0xFF3FA0FF);
  static const Color textPrimary = Color(0xFFE8F0FF);
  static const Color textMuted = Color(0xFF9FB0CC);

  static ThemeData get lightTheme {
    const primary = Color(0xFF0F766E);
    const secondary = Color(0xFF0EA5E9);
    const surface = Color(0xFFF4F8FA);
    const onSurface = Color(0xFF102A43);

    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: primary,
        secondary: secondary,
        onSurface: onSurface,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        titleTextStyle: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: onSurface,
          letterSpacing: -0.3,
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 15, height: 1.4),
        bodyMedium: TextStyle(fontSize: 14, height: 1.45),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      chipTheme: ChipThemeData(
        selectedColor: primary.withValues(alpha: 0.15),
        backgroundColor: primary.withValues(alpha: 0.08),
        side: BorderSide.none,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: StadiumBorder(),
        elevation: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    const error = Color(0xFFFF6B87);

    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: accentCyan,
      onPrimary: Color(0xFF031415),
      secondary: accentBlue,
      onSecondary: Colors.white,
      error: error,
      onError: Colors.white,
      surface: bgSecondary,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bgPrimary,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        titleTextStyle: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          color: textPrimary,
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: textPrimary),
        titleMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 16, height: 1.45, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: textMuted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF101A2D),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: const TextStyle(color: textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF1A2740)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF1A2740)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: accentCyan, width: 1.2),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF101A2D),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: StadiumBorder(),
        elevation: 0,
        backgroundColor: accentCyan,
        foregroundColor: Color(0xFF052026),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF0F1B2F),
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerColor: const Color(0xFF1B2A44),
    );
  }

  const AppTheme._();
}
