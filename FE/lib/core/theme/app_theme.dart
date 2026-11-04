import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();
  static const _seed = Color(0xFF7C8CFF);

  static ThemeData dark() =>
      _build(Brightness.dark, const Color(0xFF0B0D12), const Color(0xFF151922));
  static ThemeData light() =>
      _build(Brightness.light, const Color(0xFFF5F6FA), Colors.white);

  static ThemeData _build(
      Brightness brightness, Color background, Color surface) {
    final scheme = ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: brightness,
        surface: surface,
        primary: _seed,
        error: const Color(0xFFFF647C));
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
          backgroundColor: background,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface)),
      cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: .35)))),
      inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      navigationBarTheme: NavigationBarThemeData(
          backgroundColor: surface,
          indicatorColor: _seed.withValues(alpha: .18)),
      dividerTheme:
          DividerThemeData(color: scheme.outlineVariant.withValues(alpha: .35)),
    );
  }
}
