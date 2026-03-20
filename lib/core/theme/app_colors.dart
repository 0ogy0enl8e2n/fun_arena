import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF1E6BFF);
  static const primaryDark = Color(0xFF1449B5);
  static const accent = Color(0xFFFF7A00);
  static const success = Color(0xFF18A957);
  static const warning = Color(0xFFF4A100);
  static const error = Color(0xFFD64545);

  static const background = Color(0xFFF7F8FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFEEF1F5);
  static const textPrimary = Color(0xFF101828);
  static const textSecondary = Color(0xFF667085);
  static const border = Color(0xFFD9E0EA);

  static const darkBackground = Color(0xFF0F1720);
  static const darkSurface = Color(0xFF18212B);
  static const darkSurfaceAlt = Color(0xFF1F2937);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF9CA3AF);
  static const darkBorder = Color(0xFF374151);

  static const List<Color> teamColorPresets = [
    Color(0xFF1E6BFF),
    Color(0xFFD64545),
    Color(0xFF18A957),
    Color(0xFFFF7A00),
    Color(0xFF8B5CF6),
    Color(0xFF0891B2),
    Color(0xFFEC4899),
    Color(0xFFEAB308),
  ];

  static const List<String> teamColorNames = [
    'blue',
    'red',
    'green',
    'orange',
    'purple',
    'teal',
    'pink',
    'yellow',
  ];

  static Color colorFromTag(String tag) {
    final idx = teamColorNames.indexOf(tag);
    return idx >= 0 ? teamColorPresets[idx] : primary;
  }
}
