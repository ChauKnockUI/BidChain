import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class UserAvatar extends StatelessWidget {
  /// Tên người dùng (dùng để hiển thị initials nếu không có ảnh)
  final String name;

  /// URL ảnh đại diện (có thể null)
  final String? imageUrl;

  /// Kích thước avatar (default: 48)
  final double size;

  /// Callback khi tap vào avatar
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 48,
    this.onTap,
  });

  /// Lấy 2 ký tự đầu tiên của tên để làm initials
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'HC'; // Fallback mặc định

    if (parts.length == 1) {
      // Nếu chỉ có 1 từ, lấy 2 ký tự đầu
      return parts[0].substring(0, 2.clamp(0, parts[0].length)).toUpperCase();
    } else {
      // Nếu có 2+ từ, lấy ký tự đầu của từ 1 và từ 2
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Gradient background dùng màu chủ đạo
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.tertiary, AppColors.accent],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: hasImage ? _buildImageAvatar() : _buildInitialsAvatar(initials),
      ),
    );
  }

  /// Hiển thị ảnh đại diện với fallback
  Widget _buildImageAvatar() {
    return ClipOval(
      child: Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Nếu ảnh lỗi, hiển thị initials thay vì error
          return _buildInitialsAvatar(_getInitials(name));
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 2,
            ),
          );
        },
      ),
    );
  }

  /// Hiển thị initials khi không có ảnh
  Widget _buildInitialsAvatar(String initials) {
    return Center(
      child: Text(
        initials,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.35, // Scale font theo kích thước avatar
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
