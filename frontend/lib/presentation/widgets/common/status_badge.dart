import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;

  const StatusBadge({super.key, required this.status, this.fontSize});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Text(
        config.label,
        style: AppTextStyles.labelSmall.copyWith(
          color: config.textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING_APPROVAL':
        return _StatusConfig(
          label: 'Chờ duyệt',
          backgroundColor: AppColors.warning.withValues(alpha: 0.1),
          borderColor: AppColors.warning,
          textColor: AppColors.warning,
        );
      case 'APPROVED':
        return _StatusConfig(
          label: 'Đã duyệt',
          backgroundColor: AppColors.info.withValues(alpha: 0.1),
          borderColor: AppColors.info,
          textColor: AppColors.info,
        );
      case 'ACTIVE':
        return _StatusConfig(
          label: 'Đang diễn ra',
          backgroundColor: AppColors.success.withValues(alpha: 0.15),
          borderColor: AppColors.success,
          textColor: AppColors.accent,
        );
      case 'ENDED':
        return _StatusConfig(
          label: 'Đã kết thúc',
          backgroundColor: AppColors.grey.withValues(alpha: 0.1),
          borderColor: AppColors.grey,
          textColor: AppColors.grey,
        );
      case 'SETTLED':
        return _StatusConfig(
          label: 'Đã thanh toán',
          backgroundColor: AppColors.tertiary.withValues(alpha: 0.15),
          borderColor: AppColors.tertiary,
          textColor: AppColors.accent,
        );
      case 'REJECTED':
        return _StatusConfig(
          label: 'Bị từ chối',
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          borderColor: AppColors.error,
          textColor: AppColors.error,
        );
      case 'WINNING':
        return _StatusConfig(
          label: 'Đang thắng',
          backgroundColor: AppColors.success.withValues(alpha: 0.15),
          borderColor: AppColors.success,
          textColor: AppColors.accent,
        );
      case 'OUTBID':
        return _StatusConfig(
          label: 'Bị vượt giá',
          backgroundColor: AppColors.warning.withValues(alpha: 0.1),
          borderColor: AppColors.warning,
          textColor: AppColors.warning,
        );
      case 'VALID':
        return _StatusConfig(
          label: 'Hợp lệ',
          backgroundColor: AppColors.info.withValues(alpha: 0.1),
          borderColor: AppColors.info,
          textColor: AppColors.info,
        );
      default:
        return _StatusConfig(
          label: status,
          backgroundColor: AppColors.grey.withValues(alpha: 0.1),
          borderColor: AppColors.grey,
          textColor: AppColors.grey,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  _StatusConfig({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}
