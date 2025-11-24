import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Custom Palette)
  static const Color primary = Color(0xFFF1F3E0); // Cream
  static const Color primaryLight = Color(0xFFFAFBF8);
  static const Color primaryDark = Color(0xFFE8EAD6);

  // Secondary Colors
  static const Color secondary = Color(0xFFD2DCB6); // Light Sage
  static const Color secondaryLight = Color(0xFFE3EDD1);
  static const Color secondaryDark = Color(0xFFC4CE9B);

  // Tertiary Colors
  static const Color tertiary = Color(0xFFA1BC98); // Sage
  static const Color tertiaryLight = Color(0xFFB8CCA9);
  static const Color tertiaryDark = Color(0xFF8AAB7F);

  // Accent Colors
  static const Color accent = Color(0xFF778873); // Dark Olive
  static const Color accentLight = Color(0xFF8B9D83);
  static const Color accentDark = Color(0xFF6B7D6B);

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF6B7280);
  static const Color greyLight = Color(0xFFF3F4F6);
  static const Color greyDark = Color(0xFF374151);

  // Status
  static const Color success = Color(0xFFA1BC98);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFB923C);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [secondary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
