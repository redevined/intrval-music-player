import 'package:flutter/material.dart';

/// intrval's app theme: sleek, modern, dark-friendly Material 3.
class AppTheme {
  static const Color seed = Color(0xFF6750E4);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seed),
      appBarTheme: const AppBarTheme(centerTitle: false),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(centerTitle: false),
    );
  }
}
