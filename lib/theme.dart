import 'package:flutter/material.dart';

const kOrange = Color(0xFFF57C00);
const kDeepOrange = Color(0xFFE65100);
const kCream = Color(0xFFFFF8F0);

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: kOrange,
    brightness: Brightness.light,
  ).copyWith(primary: kOrange, onPrimary: Colors.white);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: kCream,
    appBarTheme: const AppBarTheme(
      backgroundColor: kOrange,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kDeepOrange,
        foregroundColor: Colors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

const kHeaderGradient = LinearGradient(
  colors: [kOrange, kDeepOrange],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
