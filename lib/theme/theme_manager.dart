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
    final colorValue = Color.fromARGB(255, 255, 112, 129); //Color(settingsBox.get('themeColor', defaultValue: 0xffFFB2AF));

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

  
}