import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1F1F1F);
  static const Color accentColor = Colors.green;
  static const Color cardColor = Color(0xFF2A2A2A);
  
  static ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: primaryColor,
    cardColor: cardColor,
    colorScheme: ColorScheme.dark(
      primary: accentColor,
      secondary: accentColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
  
  static const TextStyle headlineStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: Colors.white70,
  );
  
  static const EdgeInsets standardPadding = EdgeInsets.all(16.0);
  static const double cardRadius = 20.0;
} 