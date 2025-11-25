import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class SecondaryButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPress;
  final bool loading;
  final bool disabled;
  final double? width;
  final double height;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.title,
    this.onPress,
    this.loading = false,
    this.disabled = false,
    this.width,
    this.height = 52,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = disabled || loading;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDisabled
              ? AppColors.grey.withOpacity(0.3)
              : AppColors.accent,
          width: 1.5,
        ),
      ),
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPress,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.accent,
          disabledForegroundColor: AppColors.grey.withOpacity(0.5),
          side: BorderSide.none,
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
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          disabled ? AppColors.grey : AppColors.accent,
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: disabled ? AppColors.grey : AppColors.accent,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: AppTextStyles.labelLarge.copyWith(
                color: disabled ? AppColors.grey : AppColors.accent,
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
        color: disabled ? AppColors.grey : AppColors.accent,
        fontWeight: FontWeight.w600,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
