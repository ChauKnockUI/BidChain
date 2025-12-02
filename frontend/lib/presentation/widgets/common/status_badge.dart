import 'package:flutter/material.dart';
import '../../../config/theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;

  const StatusBadge({super.key, required this.status, this.fontSize});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: config.borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        config.label,
        style: AppTextStyles.labelSmall.copyWith(
          color: config.textColor,
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING_APPROVAL':
        return _StatusConfig(
          label: 'Chờ duyệt',
          backgroundColor: const Color(
            0xFFFFA726,
          ).withOpacity(0.95), // Warm Orange
          borderColor: const Color(0xFFFF9800),
          textColor: Colors.white,
        );
      case 'APPROVED':
        return _StatusConfig(
          label: 'Đã duyệt',
          backgroundColor: const Color(
            0xFF42A5F5,
          ).withOpacity(0.95), // Bright Blue
          borderColor: const Color(0xFF2196F3),
          textColor: Colors.white,
        );
      case 'ACTIVE':
        return _StatusConfig(
          label: 'Đang diễn ra',
          backgroundColor: const Color(
            0xFF66BB6A,
          ).withOpacity(0.95), // Bright Green
          borderColor: const Color(0xFF4CAF50),
          textColor: Colors.white,
        );
      case 'ENDED':
        return _StatusConfig(
          label: 'Đã kết thúc',
          backgroundColor: const Color(
            0xFF78909C,
          ).withOpacity(0.95), // Blue Grey
          borderColor: const Color(0xFF607D8B),
          textColor: Colors.white,
        );
      case 'SETTLED':
        return _StatusConfig(
          label: 'Đã thanh toán',
          backgroundColor: const Color(0xFF9C27B0).withOpacity(0.95), // Purple
          borderColor: const Color(0xFF7B1FA2),
          textColor: Colors.white,
        );
      case 'REJECTED':
        return _StatusConfig(
          label: 'Bị từ chối',
          backgroundColor: const Color(
            0xFFEF5350,
          ).withOpacity(0.95), // Bright Red
          borderColor: const Color(0xFFF44336),
          textColor: Colors.white,
        );
      case 'WINNING':
        return _StatusConfig(
          label: 'Đang thắng',
          backgroundColor: const Color(
            0xFF66BB6A,
          ).withOpacity(0.95), // Bright Green
          borderColor: const Color(0xFF4CAF50),
          textColor: Colors.white,
        );
      case 'OUTBID':
        return _StatusConfig(
          label: 'Bị vượt giá',
          backgroundColor: const Color(
            0xFFFF7043,
          ).withOpacity(0.95), // Deep Orange
          borderColor: const Color(0xFFFF5722),
          textColor: Colors.white,
        );
      case 'VALID':
        return _StatusConfig(
          label: 'Hợp lệ',
          backgroundColor: const Color(
            0xFF42A5F5,
          ).withOpacity(0.95), // Bright Blue
          borderColor: const Color(0xFF2196F3),
          textColor: Colors.white,
        );
      default:
        return _StatusConfig(
          label: status,
          backgroundColor: const Color(0xFF9E9E9E).withOpacity(0.95), // Grey
          borderColor: const Color(0xFF757575),
          textColor: Colors.white,
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
