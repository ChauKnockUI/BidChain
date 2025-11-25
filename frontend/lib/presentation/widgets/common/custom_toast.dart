import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

enum ToastType { success, error, warning, info }

enum ToastPosition { top, bottom }

class CustomToast extends StatefulWidget {
  final String message;
  final ToastType type;
  final ToastPosition position;
  final Duration duration;
  final VoidCallback? onDismiss;

  const CustomToast({
    super.key,
    required this.message,
    this.type = ToastType.info,
    this.position = ToastPosition.bottom,
    this.duration = const Duration(seconds: 3),
    this.onDismiss,
  });

  @override
  State<CustomToast> createState() => _CustomToastState();
}

class _CustomToastState extends State<CustomToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Slide animation based on position
    _slideAnimation = Tween<Offset>(
      begin: widget.position == ToastPosition.top
          ? const Offset(0, -1)
          : const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Start animation
    _controller.forward();

    // Auto dismiss
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.error:
        return AppColors.error;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.info:
        return AppColors.info;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
        return Icons.info;
    }
  }

  String _getTitle() {
    switch (widget.type) {
      case ToastType.success:
        return 'Thành công';
      case ToastType.error:
        return 'Lỗi';
      case ToastType.warning:
        return 'Cảnh báo';
      case ToastType.info:
        return 'Thông báo';
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    final icon = _getIcon();
    final title = _getTitle();

    return Positioned(
      top: widget.position == ToastPosition.top ? 50 : null,
      bottom: widget.position == ToastPosition.bottom ? 50 : null,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColors.white, size: 24),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.message,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Close button
                  InkWell(
                    onTap: _dismiss,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        color: AppColors.white.withOpacity(0.8),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Toast Helper - Static methods để show toast dễ dàng
class Toast {
  static OverlayEntry? _currentToast;

  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Remove existing toast if any
    _currentToast?.remove();

    _currentToast = OverlayEntry(
      builder: (context) => CustomToast(
        message: message,
        type: type,
        position: position,
        duration: duration,
        onDismiss: () {
          _currentToast?.remove();
          _currentToast = null;
        },
      ),
    );

    Overlay.of(context).insert(_currentToast!);
  }

  // Convenience methods
  static void success(
    BuildContext context,
    String message, {
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: ToastType.success,
      position: position,
      duration: duration,
    );
  }

  static void error(
    BuildContext context,
    String message, {
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: ToastType.error,
      position: position,
      duration: duration,
    );
  }

  static void warning(
    BuildContext context,
    String message, {
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: ToastType.warning,
      position: position,
      duration: duration,
    );
  }

  static void info(
    BuildContext context,
    String message, {
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: ToastType.info,
      position: position,
      duration: duration,
    );
  }

  static void hide() {
    _currentToast?.remove();
    _currentToast = null;
  }
}
