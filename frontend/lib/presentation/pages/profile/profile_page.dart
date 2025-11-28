import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTextStyles.h2.copyWith(color: AppColors.black),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.black,
          onPressed: () => context.go(AppRoutes.home),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_rounded, size: 80, color: AppColors.accent),
            const SizedBox(height: 16),
            Text(
              'Profile Page',
              style: AppTextStyles.h2.copyWith(color: AppColors.black),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon...',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
