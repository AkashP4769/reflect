import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: "Poppins",
  colorScheme: const ColorScheme.light(
    primary: Color(0xffFFAC5F),
    onPrimary: Color.fromARGB(255, 34, 34, 34),
    secondary: Color(0xffFFE3C3),
    secondaryContainer: Color.fromARGB(255, 255, 233, 207),
    onSecondary: Colors.black,
    surface: Colors.white,
    surfaceContainerHigh: Colors.white,
    surfaceContainerHighest: Color(0xffFFAC5F),
    tertiary: Colors.white,
    onTertiary: Color(0xffFFDEB7),
    

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
      backgroundColor: const Color(0xffFFAC5F),
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
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.transparent
  ),

  timePickerTheme: const TimePickerThemeData(
    hourMinuteColor: Color(0xffFFE3C3),
    dialHandColor: Color.fromARGB(255, 34, 34, 34),
    dialBackgroundColor: Color(0xffFFE3C3),

    dayPeriodTextStyle: const TextStyle(
      fontSize: 20, // Adjust font size
      color: Color(0xffFFAC5F), // Set selected AM/PM text color
      fontWeight: FontWeight.w600, // You can also adjust other styles
    ),
  )
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: "Poppins",
  colorScheme: const ColorScheme.dark(
    primary: Color(0xffFFAC5F),
    onPrimary: Colors.white,
    secondary: Color(0xff303030),
    secondaryContainer: Color(0xff262626),
    onSecondary: Colors.white,
    surface: Color(0xff303030),
    surfaceContainer: Colors.white, 
    surfaceContainerHighest: Colors.white,
    tertiary: Color(0xff303030),
    onTertiary: Color(0xff141414),
    
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
      backgroundColor: const Color(0xffFFAC5F),
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
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.transparent
  ),

  timePickerTheme: TimePickerThemeData(
    dialHandColor: const Color(0xffFFAC5F),
    dialBackgroundColor: const Color(0xff141414),
    hourMinuteColor: const Color((0xff141414)),
    hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xffFFAC5F);
      }
      return Colors.white;
    }),
    dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xffFFAC5F);
      }
      return Colors.white;
    }),
    dayPeriodTextStyle: const TextStyle(
      fontSize: 20, // Adjust font size
      color: Color(0xffFFAC5F), // Set selected AM/PM text color
      fontWeight: FontWeight.w600, // You can also adjust other styles
    ),
  )
  
  
);
