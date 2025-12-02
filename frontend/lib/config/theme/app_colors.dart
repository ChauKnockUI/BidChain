import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - White for backgrounds
  static const Color primary = Color(0xFFFFFFFF); // White
  static const Color primaryLight = Color(0xFFFFFFFF);
  static const Color primaryDark = Color(0xFFF5F5F5);

  // Secondary Colors - Light grey for subtle backgrounds
  static const Color secondary = Color(0xFFF5F5F5); // Very Light Grey
  static const Color secondaryLight = Color(0xFFFAFAFA);
  static const Color secondaryDark = Color(0xFFEEEEEE);

  // Tertiary Colors - Medium grey
  static const Color tertiary = Color(0xFFE0E0E0); // Light Grey
  static const Color tertiaryLight = Color(0xFFEEEEEE);
  static const Color tertiaryDark = Color(0xFFBDBDBD);

  // Accent Colors - Black for buttons, borders, and emphasis
  static const Color accent = Color(0xFF000000); // Black
  static const Color accentLight = Color(0xFF424242);
  static const Color accentDark = Color(0xFF000000);

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyDark = Color(0xFF424242);

  // Status
  static const Color success = Color(0xFF000000); // Black instead of green
  static const Color error = Color(0xFF000000); // Black instead of red
  static const Color warning = Color(0xFF424242); // Dark grey instead of orange
  static const Color info = Color(0xFF616161); // Grey instead of blue

  // Timer Urgency Colors
  static const Color timerWarning = Color(0xFFFF9800); // Orange for <10 minutes
  static const Color timerCritical = Color(0xFFEF4444); // Red rgb(239,68,68) for <3 minutes

  // Gradients - Black to grey gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [white, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentLight, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
