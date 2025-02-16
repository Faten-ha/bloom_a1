import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: Colors.green.shade900,
  scaffoldBackgroundColor: Colors.green.shade100,
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white, fontSize: 18),
    titleLarge: TextStyle(
        color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green.shade700,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
);
