import 'dart:async';
import 'package:files/core/widgets/notification/notification_view.dart';
import 'package:flutter/material.dart';

enum NotificationType { success, error, info }

class CustomNotification {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show({
    required BuildContext context,
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    dismiss();

    final overlay = Overlay.of(context, rootOverlay: true);

    _entry = OverlayEntry(
      builder:
          (_) => SimpleNotificationView(
            message: message,
            type: type,
            onClose: dismiss,
          ),
    );

    overlay.insert(_entry!);

    _timer = Timer(duration, dismiss);
  }

  static void dismiss() {
    _timer?.cancel();
    _timer = null;

    _entry?.remove();
    _entry = null;
  }
}
