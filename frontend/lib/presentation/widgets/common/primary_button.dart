import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPress;
  final bool loading;
  final bool disabled;
  final double? width;
  final double height;
  final IconData? icon;
  final Color? backgroundColor;

  const PrimaryButton({
    super.key,
    required this.title,
    this.onPress,
    this.loading = false,
    this.disabled = false,
    this.width,
    this.height = 52,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = disabled || loading;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDisabled
            ? []
            : [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? AppColors.grey.withOpacity(0.3)
              : (backgroundColor ?? AppColors.accent),
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.grey.withOpacity(0.3),
          disabledForegroundColor: AppColors.grey,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loading ? _buildLoadingIndicator() : _buildButtonContent(),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: AppTextStyles.labelLarge.copyWith(
                color: disabled ? AppColors.grey : AppColors.white,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      title,
      style: AppTextStyles.labelLarge.copyWith(
        color: disabled ? AppColors.grey : AppColors.white,
        fontWeight: FontWeight.w600,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
