import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import '../../presentation/widgets/notification_popup.dart';
class NotificationPopupService {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    showOverlayNotification(
      (context) {
        return NotificationPopup(
          title: title,
          message: message,
          onTap: () {
            OverlaySupportEntry.of(context)?.dismiss();
            onTap?.call();
          },
        );
      },
      duration: duration,
      position: NotificationPosition.top,
    );
  }
}