import 'package:flutter/material.dart';

class WhatsAppTheme {
  // Colors
  static const Color lightGreen = Color(0xFF25D366);
  static const Color darkGreen = Color(0xFF128C7E);
  static const Color tealGreen = Color(0xFF075E54);
  static const Color lightBlue = Color(0xFF34B7F1);
  static const Color chatBackground = Color(0xFFECE5DD);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color(0xFF8696A0);
  static const Color lightGrey = Color(0xFFE2E2E2);

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: tealGreen,
      secondary: lightGreen,
      onPrimary: white,
      onSecondary: white,
      background: white,
      surface: white,
      error: Colors.red,
      onBackground: black,
      onSurface: black,
      onError: white,
    ),
    scaffoldBackgroundColor: white,
    appBarTheme: const AppBarTheme(
      backgroundColor: tealGreen,
      foregroundColor: white,
      elevation: 0,
      iconTheme: IconThemeData(color: white),
      titleTextStyle: TextStyle(
        color: white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    // tabBarTheme: const TabBarTheme(
    //   labelColor: white,
    //   unselectedLabelColor: Color(0xFFB3D9D2),
    //   indicatorSize: TabBarIndicatorSize.tab,
    //   labelStyle: TextStyle(fontWeight: FontWeight.bold),
    // ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: lightGreen,
      foregroundColor: white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: lightGreen,
      unselectedItemColor: grey,
      backgroundColor: white,
    ),
    dividerTheme: const DividerThemeData(
      color: lightGrey,
      thickness: 0.5,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightGreen,
        foregroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: tealGreen,
      ),
    ),
    iconTheme: const IconThemeData(
      color: grey,
    ),
    fontFamily: 'Roboto',
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: tealGreen,
      secondary: lightGreen,
      onPrimary: white,
      onSecondary: white,
      background: const Color(0xFF121B22),
      surface: const Color(0xFF1F2C34),
      error: Colors.red,
      onBackground: white,
      onSurface: white,
      onError: white,
    ),
    scaffoldBackgroundColor: const Color(0xFF121B22),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F2C34),
      foregroundColor: white,
      elevation: 0,
      iconTheme: IconThemeData(color: white),
      titleTextStyle: TextStyle(
        color: white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    // tabBarTheme: const TabBarTheme(
    //   labelColor: lightGreen,
    //   unselectedLabelColor: grey,
    //   indicatorSize: TabBarIndicatorSize.tab,
    //   labelStyle: TextStyle(fontWeight: FontWeight.bold),
    // ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: lightGreen,
      foregroundColor: white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: lightGreen,
      unselectedItemColor: grey,
      backgroundColor: Color(0xFF1F2C34),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF313D45),
      thickness: 0.5,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightGreen,
        foregroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: lightGreen,
      ),
    ),
    iconTheme: const IconThemeData(
      color: grey,
    ),
    fontFamily: 'Roboto',
  );
}
