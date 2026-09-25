import 'package:flutter/material.dart';

/// Paleta de pissarra fosca amb accents daurats.
abstract final class AppColors {
  static const ink = Color(0xFF12161D);
  static const slate = Color(0xFF1C232D);
  static const card = Color(0xFF26303C);
  static const gold = Color(0xFFE0B04A);
  static const chalk = Color(0xFFEDEBE4);
  static const ok = Color(0xFF6BCB77);
  static const error = Color(0xFFE5646B);

  static const library = Color(0xFF3F7CAC);
  static const clocks = Color(0xFFC08A2E);
  static const domino = Color(0xFF6A994E);
}

ThemeData buildTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.gold,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.gold,
        onPrimary: AppColors.ink,
        surface: AppColors.slate,
        onSurface: AppColors.chalk,
        error: AppColors.error,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.ink,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.ink,
      foregroundColor: AppColors.chalk,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.ink,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: AppColors.chalk,
        side: BorderSide(color: AppColors.chalk.withValues(alpha: 0.35)),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

/// Formata segons com a `mm:ss` (o `h:mm:ss` si passa d'una hora).
String formatTime(int seconds) {
  final s = seconds < 0 ? 0 : seconds;
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final sec = s % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(sec)}' : '${two(m)}:${two(sec)}';
}
