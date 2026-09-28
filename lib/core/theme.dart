import 'package:flutter/material.dart';

/// Paleta de pissarra fosca amb accents daurats.
abstract final class AppColors {
  static const ink = Color(0xFF12161D);
  static const slate = Color(0xFF1C232D);
  static const card = Color(0xFF26303C);
  static const gold = Color(0xFFE0B04A);
  static const chalk = Color(0xFFEDEBE4);
  static const ok = Color(0xFF6BCB77);
  static const error = Color(0xFFEF7D82);

  static const library = Color(0xFF3F7CAC);
  static const clocks = Color(0xFFC08A2E);
  static const domino = Color(0xFF6A994E);
}

/// [fontFamily] i [fontFamilyFallback] només cal passar-los fora del mòbil
/// (p. ex. per generar captures); a Android es fa servir la font del sistema.
ThemeData buildTheme({String? fontFamily, List<String>? fontFamilyFallback}) {
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
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
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
        textStyle: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
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

/// Relació de contrast WCAG entre dues colors opaques (1–21).
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// Color de text (ink o chalk) amb més contrast sobre [background].
Color onColor(Color background) =>
    contrastRatio(AppColors.ink, background) >=
        contrastRatio(AppColors.chalk, background)
    ? AppColors.ink
    : AppColors.chalk;

/// Aclareix [color] cap a chalk fins que arriba a [minRatio] sobre
/// [background] (AA per a text normal: 4,5).
Color readableOn(
  Color color, {
  Color background = AppColors.ink,
  double minRatio = 4.5,
}) {
  for (var t = 0.0; t <= 1.0; t += 0.05) {
    final c = Color.lerp(color, AppColors.chalk, t)!;
    if (contrastRatio(c, background) >= minRatio) return c;
  }
  return AppColors.chalk;
}

/// Fons per a barres i insígnies de color: si ni ink ni chalk hi arriben a
/// AA (4,5), s'enfosqueix [color] el mínim necessari perquè chalk hi arribi.
Color accessibleBar(Color color) {
  double best(Color c) {
    final a = contrastRatio(AppColors.ink, c),
        b = contrastRatio(AppColors.chalk, c);
    return a > b ? a : b;
  }

  if (best(color) >= 4.5) return color;
  for (var t = 0.05; t <= 1.0; t += 0.05) {
    final c = Color.lerp(color, AppColors.ink, t)!;
    if (contrastRatio(AppColors.chalk, c) >= 4.5) return c;
  }
  return AppColors.ink;
}
