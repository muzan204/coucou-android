import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF07101D);
  static const bgSoft = Color(0xFF0A1423);
  static const surface = Color(0xFF0F1B2D);
  static const surface2 = Color(0xFF142238);
  static const surface3 = Color(0xFF1A2B44);

  static const text = Color(0xFFF8FAFC);
  static const muted = Color(0xFF91A4BE);
  static const line = Color(0x263A4B63);

  static const cyan = Color(0xFF16E7FF);
  static const blue = Color(0xFF5B7CFA);
  static const violet = Color(0xFF9B6CFF);
  static const pink = Color(0xFFFF5FD2);
  static const green = Color(0xFF3BD88F);
  static const amber = Color(0xFFF7C451);
  static const red = Color(0xFFFF627D);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.cyan,
    brightness: Brightness.dark,
    surface: AppColors.surface,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: scheme.copyWith(
      primary: AppColors.cyan,
      secondary: AppColors.violet,
      tertiary: AppColors.green,
      surface: AppColors.surface,
    ),
    dividerColor: AppColors.line,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.text,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 23,
        fontWeight: FontWeight.w900,
        letterSpacing: -.4,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface2,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.line),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: Color(0x3316E7FF),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface2,
      hintStyle: const TextStyle(color: AppColors.muted),
      prefixIconColor: AppColors.muted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.cyan, width: 1.3),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.surface3,
      contentTextStyle: const TextStyle(color: AppColors.text),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
  );
}
