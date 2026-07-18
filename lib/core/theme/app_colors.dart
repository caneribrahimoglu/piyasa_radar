import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color lightSeed = Color(0xFF00897B);
  static const Color darkSeed = Color(0xFF22D3EE);

  static const Color lightBackground = Color(0xFFF7FAF9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF00796B);
  static const Color lightSecondary = Color(0xFF2F6F73);
  static const Color lightTertiary = Color(0xFF5F7D00);
  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightOutline = Color(0xFFD6E0DD);

  static const Color darkBackground = Color(0xFF071311);
  static const Color darkSurface = Color(0xFF10201D);
  static const Color darkSurfaceContainer = Color(0xFF152A26);
  static const Color darkPrimary = Color(0xFF22D3EE);
  static const Color darkSecondary = Color(0xFF5EEAD4);
  static const Color darkTertiary = Color(0xFFA3E635);
  static const Color darkError = Color(0xFFFF6B6B);
  static const Color darkOutline = Color(0xFF31524C);

  static const Color priceDownLight = Color(0xFF1B7F3A);
  static const Color priceDownDark = Color(0xFF7CFC9A);
  static const Color priceUpLight = lightError;
  static const Color priceUpDark = darkError;
}
