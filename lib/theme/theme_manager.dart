import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  ThemeManager() : super(ThemeMode.system == ThemeMode.dark ? darkTheme : lightTheme); // Initial value

  // Toggle between dark and light themes
  void toggleTheme(bool isDark) {
    state = isDark ? darkTheme : lightTheme;
  }
}