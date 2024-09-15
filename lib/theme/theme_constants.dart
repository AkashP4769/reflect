import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: "Poppins",
  colorScheme: const ColorScheme.light(
    primary: Color(0xffFFAC5F),
    onPrimary: Colors.black,
    surface: Colors.white,
    surfaceContainerHigh: Colors.white,
    surfaceContainerHighest: Color(0xffFFAC5F),
    tertiary: Colors.white,
    onTertiary: Color(0xffFFDEB7)
  ),
  textTheme: ThemeData.light().textTheme.copyWith(
    titleLarge: const TextStyle(color: Colors.black, fontSize: 24, fontFamily: "Poppins", fontWeight: FontWeight.w700),
    titleMedium: const TextStyle(color: Colors.black, fontSize: 18, fontFamily: "Poppins", fontWeight: FontWeight.w600),
    titleSmall: const TextStyle(color: Colors.black, fontSize: 14, fontFamily: "Poppins", fontWeight: FontWeight.w400),
    bodyMedium: const TextStyle(color: Colors.black, fontSize: 15, fontFamily: "Poppins", fontWeight: FontWeight.w400),
    bodySmall: const TextStyle(color: Colors.black, fontSize: 12, fontFamily: "Poppins", fontWeight: FontWeight.w400),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xffFFAC5F),
      minimumSize: const Size(double.infinity, 50),
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      textStyle: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontFamily: "Poppins",
        fontWeight: FontWeight.w600
      )
    )
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: "Poppins",
  colorScheme: const ColorScheme.dark(
    primary: Color(0xffFFAC5F),
    onPrimary: Colors.white,
    surface: Color(0xff303030),
    surfaceContainer: Colors.white, 
    surfaceContainerHighest: Colors.white,
    tertiary: Color(0xff303030),
    onTertiary: Color(0xff141414)
  ),
  textTheme: ThemeData.dark().textTheme.copyWith(
    titleLarge: const TextStyle(color: Colors.white, fontSize: 24, fontFamily: "Poppins", fontWeight: FontWeight.w700),
    titleMedium: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: "Poppins", fontWeight: FontWeight.w600),
    titleSmall: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: "Poppins", fontWeight: FontWeight.w400),
    bodyMedium: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: "Poppins", fontWeight: FontWeight.w400),
    bodySmall: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: "Poppins", fontWeight: FontWeight.w400),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xffFFAC5F),
      minimumSize: const Size(double.infinity, 50),
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontFamily: "Poppins",
        fontWeight: FontWeight.w600
      )
    )
  ),
  
  
);
