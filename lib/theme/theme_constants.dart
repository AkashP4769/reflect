import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,

  colorScheme: const ColorScheme.light(
    primary: Color(0xffFFAC5F),
    onPrimary: Colors.black,
    surface: Colors.white
  ),
  textTheme: ThemeData.light().textTheme.copyWith(
    titleMedium: const TextStyle(color: Colors.black, fontSize: 18, fontFamily: "Poppins", fontWeight: FontWeight.w600),
    titleSmall: const TextStyle(color: Colors.black, fontSize: 14, fontFamily: "Poppins", fontWeight: FontWeight.w400),
    bodyLarge: const TextStyle(color: Colors.black, fontSize: 15, fontFamily: "Poppins", fontWeight: FontWeight.w400),
    bodySmall: const TextStyle(color: Colors.black, fontSize: 12, fontFamily: "Poppins", fontWeight: FontWeight.w400),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orangeAccent,
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
  fontFamily: "Poppins",
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xffFFAC5F),
    onPrimary: Colors.white,
    surface: Color(0xff303030)
  ),
  textTheme: ThemeData.dark().textTheme.copyWith(
    titleMedium: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: "Poppins", fontWeight: FontWeight.w600),
    titleSmall: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: "Poppins", fontWeight: FontWeight.w400),
    bodyMedium: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: "Poppins", fontWeight: FontWeight.w400),
    bodySmall: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: "Poppins", fontWeight: FontWeight.w400),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orangeAccent,
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
  
  fontFamily: "Poppins",
);
