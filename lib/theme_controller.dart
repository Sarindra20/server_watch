import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.dark);
  static const String _key = 'theme_mode';

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      mode.value =
          prefs.getString(_key) == 'light' ? ThemeMode.light : ThemeMode.dark;
    } catch (_) {
      // on garde le mode sombre par défaut
    }
  }

  static Future<void> toggle() async {
    mode.value =
        mode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        mode.value == ThemeMode.light ? 'light' : 'dark',
      );
    } catch (_) {
      // le choix n'est simplement pas mémorisé
    }
  }
}