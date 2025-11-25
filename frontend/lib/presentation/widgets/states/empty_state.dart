import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  /// Icon hiển thị (ví dụ: Icons.shopping_bag_outlined)
  final IconData icon;

  /// Tiêu đề / thông báo chính
  final String title;

  /// Mô tả chi tiết (tùy chọn)
  final String? description;

  /// Nút action (tùy chọn)
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  /// Màu icon (default: accent color)
  final Color iconColor;

  /// Kích thước icon (default: 80)
  final double iconSize;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onActionPressed,
    this.iconColor = AppColors.accent,
    this.iconSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: iconSize + 20,
              height: iconSize + 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Nền nhẹ dùng màu secondary
                color: AppColors.secondary.withValues(alpha: 0.15),
              ),
              child: Icon(icon, size: iconSize, color: iconColor),
            ),

            const SizedBox(height: 20),

            // Tiêu đề
            Text(
              title,
              style: AppTextStyles.h3.copyWith(color: AppColors.accent),
              textAlign: TextAlign.center,
            ),

            // Mô tả (nếu có)
            if (description != null) ...[
              const SizedBox(height: 12),
              Text(
                description!,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
            ],

            // Button action (nếu có)
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onActionPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    actionLabel!,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
