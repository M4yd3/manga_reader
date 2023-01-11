import 'package:flutter/material.dart';

ThemeData theme = ThemeData(
  brightness: Brightness.dark,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
    ),
  ),
  cardTheme: const CardTheme(color: Color(0xff404040)),
  dividerTheme: const DividerThemeData(color: Colors.grey, thickness: 1.25),
  colorScheme:
      ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple).copyWith(
    secondary: Colors.deepPurpleAccent,
  ),
);
