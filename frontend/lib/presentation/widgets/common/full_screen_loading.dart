import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

/// FullScreenLoading - Loading toàn màn hình với overlay
class FullScreenLoading extends StatelessWidget {
  final bool visible;
  final String? message;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final bool isDark;

  const FullScreenLoading({
    super.key,
    required this.visible,
    this.message,
    this.backgroundColor,
    this.indicatorColor,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final bgColor =
        backgroundColor ??
        (isDark
            ? Colors.black.withOpacity(0.7)
            : Colors.white.withOpacity(0.9));

    final textColor = isDark ? AppColors.white : AppColors.accentDark;
    final spinnerColor =
        indicatorColor ?? (isDark ? AppColors.white : AppColors.accent);

    return Material(
      color: Colors.transparent,
      child: Container(
        color: bgColor,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.accentDark.withOpacity(0.3)
                  : AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Loading Spinner
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
                  ),
                ),

                if (message != null) ...[
                  const SizedBox(height: 24),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 250),
                    child: Text(
                      message!,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper function để show FullScreenLoading như một overlay
class LoadingOverlay {
  static OverlayEntry? _overlayEntry;

  /// Show loading overlay
  static void show(
    BuildContext context, {
    String? message,
    bool isDark = false,
  }) {
    if (_overlayEntry != null) return; // Prevent multiple overlays

    _overlayEntry = OverlayEntry(
      builder: (context) =>
          FullScreenLoading(visible: true, message: message, isDark: isDark),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Hide loading overlay
  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Check if loading is currently showing
  static bool get isShowing => _overlayEntry != null;
}
