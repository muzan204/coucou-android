import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0F172A);
  static const surface = Color(0xFF1E293B);
  static const surface2 = Color(0xFF111827);
  static const text = Color(0xFFF3F4F6);
  static const muted = Color(0xFF94A3B8);
  static const cyan = Color(0xFF00F0FF);
  static const violet = Color(0xFF8B5CF6);
  static const green = Color(0xFF35D07F);
  static const red = Color(0xFFFF5D73);
  static const amber = Color(0xFFF5B942);
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
    colorScheme: scheme,
    cardTheme: const CardThemeData(
      color: AppColors.surface2,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.surface2,
      indicatorColor: Color(0x3322D3EE),
    ),
  );
}
