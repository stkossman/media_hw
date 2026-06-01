import 'package:flutter/material.dart';

class AppTheme {
  static const cream = Color(0xFFFFFBE6);
  static const orange = Color(0xFFFF5C00);

  static ThemeData get theme {
    const textTheme = TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.w800),
      displayMedium: TextStyle(fontWeight: FontWeight.w800),
      displaySmall: TextStyle(fontWeight: FontWeight.w800),
      headlineLarge: TextStyle(fontWeight: FontWeight.w800),
      headlineMedium: TextStyle(fontWeight: FontWeight.w800),
      headlineSmall: TextStyle(fontWeight: FontWeight.w800),
      titleLarge: TextStyle(fontWeight: FontWeight.w800),
      titleMedium: TextStyle(fontWeight: FontWeight.w800),
      titleSmall: TextStyle(fontWeight: FontWeight.w800),
      bodyLarge: TextStyle(fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(fontWeight: FontWeight.w700),
      bodySmall: TextStyle(fontWeight: FontWeight.w700),
      labelLarge: TextStyle(fontWeight: FontWeight.w800),
      labelMedium: TextStyle(fontWeight: FontWeight.w800),
      labelSmall: TextStyle(fontWeight: FontWeight.w800),
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Courier New',
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: orange,
        primary: Colors.black,
        secondary: orange,
        surface: Colors.white,
      ),
      textTheme: textTheme.apply(
        fontFamily: 'Courier New',
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          fontFamily: 'Courier New',
          letterSpacing: 2,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.black, width: 2),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontFamily: 'Courier New',
            letterSpacing: 1,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontFamily: 'Courier New',
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: const BorderSide(color: Colors.black, width: 2.5),
        ),
      ),
    );
  }
}
