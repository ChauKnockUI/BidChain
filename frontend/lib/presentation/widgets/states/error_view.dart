import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class ErrorView extends StatelessWidget {
  /// Tiêu đề lỗi (default: "Đã xảy ra lỗi")
  final String title;

  /// Thông báo lỗi chi tiết
  final String message;

  /// Icon hiển thị (default: error icon)
  final IconData icon;

  /// Nút thử lại
  final String retryLabel;
  final VoidCallback? onRetry;

  /// Nút đóng / quay lại (tùy chọn)
  final String? closeLabel;
  final VoidCallback? onClose;

  /// Màu icon (default: error color)
  final Color iconColor;

  /// Kích thước icon (default: 80)
  final double iconSize;

  const ErrorView({
    super.key,
    this.title = 'Đã xảy ra lỗi',
    required this.message,
    this.icon = Icons.error_outline,
    this.retryLabel = 'Thử lại',
    this.onRetry,
    this.closeLabel,
    this.onClose,
    this.iconColor = AppColors.error,
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
            // Icon lỗi
            Container(
              width: iconSize + 20,
              height: iconSize + 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Nền nhẹ dùng màu error
                color: AppColors.error.withValues(alpha: 0.1),
              ),
              child: Icon(icon, size: iconSize, color: iconColor),
            ),

            const SizedBox(height: 20),

            // Tiêu đề lỗi
            Text(
              title,
              style: AppTextStyles.h3.copyWith(color: AppColors.accent),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Thông báo chi tiết
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Nút Thử lại
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  retryLabel,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Nút Đóng / Quay lại (nếu có)
            if (closeLabel != null && onClose != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onClose,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    closeLabel!,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
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
