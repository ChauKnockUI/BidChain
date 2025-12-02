import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';

/// A reusable back button widget that navigates to the previous page
/// 
/// Usage:
/// ```dart
/// AppBar(
///   leading: CustomBackButton(),
/// )
/// ```
class CustomBackButton extends StatelessWidget {
  /// Optional callback to execute before navigation
  final VoidCallback? onPressed;
  
  /// Icon to display (defaults to iOS-style back arrow)
  final IconData icon;
  
  /// Icon size (defaults to 20)
  final double size;
  
  /// Icon color (defaults to black)
  final Color? color;

  const CustomBackButton({
    super.key,
    this.onPressed,
    this.icon = Icons.arrow_back_ios_new,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: size),
      color: color ?? AppColors.black,
      onPressed: () {
        // Execute custom callback if provided
        onPressed?.call();
        
        // Navigate back
        if (context.canPop()) {
          context.pop();
        } else {
          // Fallback to home if cannot pop
          context.go(AppRoutes.home);
        }
      },
      tooltip: 'Back',
    );
  }
}
