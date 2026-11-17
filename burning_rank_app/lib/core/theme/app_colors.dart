import 'package:flutter/material.dart';

class AppColors {
  // Base Colors
  static const Color background = Color(0xFF0A0A0A); // Nearly Black
  static const Color surface = Color(0xFF1E1E1E); // Dark Grey
  static const Color surfaceGlass = Color(0x991E1E1E); // Glass effect

  // Primary Brand Colors (Burning Gradient)
  static const Color primaryOrange = Color(0xFFFF512F);
  static const Color primaryRed = Color(0xFFDD2476);
  static const LinearGradient burningGradient = LinearGradient(
    colors: [primaryOrange, primaryRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Secondary Accents
  static const Color accentPurple = Color(0xFF8E2DE2);
  static const Color accentBlue = Color(0xFF4A00E0);
  static const LinearGradient deepSpaceGradient = LinearGradient(
    colors: [accentPurple, accentBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Functional Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color greyText = Color(0xFFB0B0B0);
  static const Color darkGrey = Color(0xFF2C2C2C);

  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFFF3D00);
  static const Color warning = Color(0xFFFFD600);
}
