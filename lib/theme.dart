import 'package:flutter/material.dart';

const Color kAccent = Color(0xFF14B8A6);

ThemeData buildTheme(Brightness brightness) {
  final bool dark = brightness == Brightness.dark;
  final Color background =
      dark ? const Color(0xFF0F1B1F) : const Color(0xFFF4F7F7);
  final Color surface = dark ? const Color(0xFF16262B) : Colors.white;

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kAccent,
      brightness: brightness,
      surface: surface,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: dark ? Colors.transparent : const Color(0xFFDDE5E7),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kAccent,
      foregroundColor: Color(0xFF0F1B1F),
    ),
  );
}