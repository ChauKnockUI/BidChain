import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

enum ConfirmDialogType { warning, danger, info, success }

class ConfirmDialog extends StatelessWidget {
  final bool visible;
  final VoidCallback onClose;
  final VoidCallback onConfirm;
  final String? title;
  final String? message;
  final String? confirmText;
  final String? cancelText;
  final ConfirmDialogType type;
  final IconData? icon;
  final bool isLoading;

  const ConfirmDialog({
    super.key,
    required this.visible,
    required this.onClose,
    required this.onConfirm,
    this.title,
    this.message,
    this.confirmText,
    this.cancelText,
    this.type = ConfirmDialogType.warning,
    this.icon,
    this.isLoading = false,
  });

  Color _getTypeColor() {
    switch (type) {
      case ConfirmDialogType.danger:
        return AppColors.error;
      case ConfirmDialogType.info:
        return AppColors.info;
      case ConfirmDialogType.success:
        return AppColors.success;
      case ConfirmDialogType.warning:
        return AppColors.warning;
    }
  }

  IconData _getTypeIcon() {
    if (icon != null) return icon!;

    switch (type) {
      case ConfirmDialogType.danger:
        return Icons.error_outline;
      case ConfirmDialogType.info:
        return Icons.info_outline;
      case ConfirmDialogType.success:
        return Icons.check_circle_outline;
      case ConfirmDialogType.warning:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final typeColor = _getTypeColor();
    final typeIcon = _getTypeIcon();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop
          GestureDetector(
            onTap: isLoading ? null : onClose,
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          // Dialog
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(typeIcon, color: typeColor, size: 48),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      title ?? 'Xác nhận',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.accentDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Message
                    Text(
                      message ??
                          'Bạn có chắc chắn muốn thực hiện hành động này?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            title: cancelText ?? 'Hủy',
                            onPress: onClose,
                            disabled: isLoading,
                            height: 48,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            title: confirmText ?? 'Xác nhận',
                            onPress: onConfirm,
                            loading: isLoading,
                            height: 48,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
