import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reflect/theme/theme_constants.dart';

/*class ThemeManager with ChangeNotifier{
  ThemeMode _themeMode = ThemeMode.system;

  get themeMode => _themeMode;

  toggleTheme(bool isDark){
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}*/

class ThemeManager extends StateNotifier<ThemeData> {
  ThemeManager() : super(lightTheme);

  void initializeTheme() async {
    final settingsBox = Hive.box('settings');
    final themeValue = settingsBox.get('theme', defaultValue: 'system');
    WidgetsBinding.instance.addPostFrameCallback((_){
      state = themeValue == 'system' ? (ThemeMode.system == ThemeMode.dark ? darkTheme : lightTheme) : (themeValue == 'light' ? lightTheme : darkTheme);
    });
  }

  // Toggle between dark and light themes
  void toggleTheme(bool isDark) {
    state = isDark ? darkTheme : lightTheme;
    Hive.box('settings').put('theme', isDark ? 'dark' : 'light');
  }
}