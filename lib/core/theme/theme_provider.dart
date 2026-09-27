import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String _themeBoxName = 'settings';
const String _themeKey = 'isDarkMode';

/// Provides and persists the app's theme mode.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final box = Hive.box(_themeBoxName);
    final isDark = box.get(_themeKey, defaultValue: null);
    if (isDark == null) {
      state = ThemeMode.system;
    } else {
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  void setDark() {
    Hive.box(_themeBoxName).put(_themeKey, true);
    state = ThemeMode.dark;
  }

  void setLight() {
    Hive.box(_themeBoxName).put(_themeKey, false);
    state = ThemeMode.light;
  }

  void setSystem() {
    Hive.box(_themeBoxName).delete(_themeKey);
    state = ThemeMode.system;
  }

  void setThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        setSystem();
        break;
      case ThemeMode.light:
        setLight();
        break;
      case ThemeMode.dark:
        setDark();
        break;
    }
  }

  void toggle() {
    if (state == ThemeMode.dark) {
      setLight();
    } else {
      setDark();
    }
  }

  bool get isDark => state == ThemeMode.dark;
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
