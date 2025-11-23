import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Secondary
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF6B7280);
  static const Color greyLight = Color(0xFFF3F4F6);
  static const Color greyDark = Color(0xFF374151);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF2F2F2);
  static const Color warning = Color(0xFFFB923C);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
