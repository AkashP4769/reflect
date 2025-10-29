import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reflect/theme/theme_constants.dart';

class ThemeManager extends StateNotifier<ThemeData> {
  late ThemeData lightTheme;
  late ThemeData darkTheme;

  ThemeManager(super._state){
    initializeTheme();
  }

  Future<List<ThemeData>> initializeTheme() async {
    final settingsBox = Hive.box('settings');
    final themeValue = settingsBox.get('theme', defaultValue: 'system');
    final colorValue = Color(settingsBox.get('themeColor', defaultValue: 0xffFFAC5F));

    lightTheme = ThemeBuilder.buildLightTheme('light', colorValue);
    darkTheme = ThemeBuilder.buildDarkTheme('dark', colorValue);

    WidgetsBinding.instance.addPostFrameCallback((_){
      state = themeValue == 'system' ? (ThemeMode.system == ThemeMode.dark ? darkTheme : lightTheme) : (themeValue == 'light' ? lightTheme : darkTheme);
    });

    return [lightTheme, darkTheme];
  }

  // Toggle between dark and light themes
  void toggleTheme(bool isDark) {
    state = isDark ? darkTheme : lightTheme;
    Hive.box('settings').put('theme', isDark ? 'dark' : 'light');
  }

  void setThemeColor(Color color) {
    lightTheme = ThemeBuilder.buildLightTheme('light', color);
    darkTheme = ThemeBuilder.buildDarkTheme('dark', color);
    state = state.brightness == Brightness.dark ? darkTheme : lightTheme;
    Hive.box('settings').put('themeColor', color.toARGB32());
  }

  
}