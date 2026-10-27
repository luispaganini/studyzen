import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0E1020);
  static const surface = Color(0xFF171A2E);
  static const surfaceHigh = Color(0xFF20243D);
  static const primary = Color(0xFF7C9CFF);
  static const secondary = Color(0xFF5EEAD4);
  static const accent = Color(0xFFC4A1FF);
  static const textPrimary = Color(0xFFF2F4FF);
  static const textSecondary = Color(0xFF9AA0C3);
  static const danger = Color(0xFFFF7A8A);

  static const focusGradient = LinearGradient(
    colors: [primary, accent, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const backgroundGradient = LinearGradient(
    colors: [Color(0xFF15183A), background, Color(0xFF0B1A22)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface.withValues(alpha: 0.7),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
