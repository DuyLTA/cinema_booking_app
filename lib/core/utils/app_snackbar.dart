import 'package:flutter/material.dart';

import '../../theme/text_style_helper.dart';
import 'size_utils.dart';

enum AppSnackBarType { success, error, info }

class AppSnackBar {
  const AppSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(_build(message: message, type: type));
  }

  static void showWithMessenger(
    ScaffoldMessengerState messenger, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
  }) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(_build(message: message, type: type));
  }

  static SnackBar _build({
    required String message,
    required AppSnackBarType type,
  }) {
    final config = switch (type) {
      AppSnackBarType.success => _SnackBarConfig(
        icon: Icons.check_circle,
        backgroundColor: const Color(0xFF123D2A),
        borderColor: const Color(0xFF41D287),
      ),
      AppSnackBarType.error => _SnackBarConfig(
        icon: Icons.error_outline,
        backgroundColor: const Color(0xFF4A1118),
        borderColor: const Color(0xFFFF6B7A),
      ),
      AppSnackBarType.info => _SnackBarConfig(
        icon: Icons.info_outline,
        backgroundColor: const Color(0xFF261E1B),
        borderColor: const Color(0xFFFFDF9E),
      ),
    };

    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 4),
      margin: EdgeInsets.all(16.h),
      content: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 12.h),
        decoration: BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(10.h),
          border: Border.all(color: config.borderColor, width: 1.h),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 18.h,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(config.icon, color: config.borderColor, size: 22.h),
            SizedBox(width: 10.h),
            Expanded(
              child: Text(
                message,
                style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SnackBarConfig {
  const _SnackBarConfig({
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
}
