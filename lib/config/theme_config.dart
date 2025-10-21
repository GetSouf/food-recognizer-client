// lib/config/theme_config.dart
import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.green,
  scaffoldBackgroundColor: Colors.white,
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.black87),
    titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
  ),
  iconTheme: const IconThemeData(color: Colors.black87),
  dividerColor: Colors.grey[300],
  cardColor: Colors.white,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.greenAccent,
  scaffoldBackgroundColor: Colors.black87,
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white),
    titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  dividerColor: Colors.grey[600],
  cardColor: Colors.grey[800],
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.greenAccent,
      foregroundColor: Colors.white,
    ),
  ),
);