import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final Widget? leading; // <--- 1. Thêm biến này

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = false,
    this.leading, // <--- 2. Thêm vào constructor
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 1,
      centerTitle: centerTitle,
      iconTheme: const IconThemeData(color: AppColors.black),
      leading: leading, // <--- 3. Truyền vào AppBar gốc
      title: Text(title, style: AppTextStyles.h3),
      actions: actions,
    );
  }
}