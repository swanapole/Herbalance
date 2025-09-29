import 'package:flutter/material.dart';

ThemeData buildTheme() {
  final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF7C4DFF));
  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      centerTitle: true,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}
