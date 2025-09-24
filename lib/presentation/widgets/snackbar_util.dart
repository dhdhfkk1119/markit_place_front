import 'package:flutter/material.dart';
import '../../main.dart';

class SnackBarUtil {
  static void showSuccessGlobally(String message) {
    _showSnackBarGlobally(
      message: message,
      backgroundColor: Colors.green,
    );
  }

  static void showErrorGlobally(String message) {
    _showSnackBarGlobally(
      message: message,
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    );
  }

  static void showInfoGlobally(String message) {
    _showSnackBarGlobally(
      message: message,
    );
  }

  static void showWarningGlobally(String message) {
    _showSnackBarGlobally(
      message: message,
      backgroundColor: Colors.orange,
    );
  }

  static void _showSnackBarGlobally({
    required String message,
    Color? backgroundColor,
    Duration? duration,
  }) {
    Future.delayed(Duration.zero, () {
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              textAlign: TextAlign.center,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            backgroundColor: backgroundColor,
            duration: duration ?? const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  /// 성공 메시지 표시 (녹색 배경)
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 에러 메시지 표시 (빨간색 배경)
  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 일반 정보 메시지 표시 (기본 배경)
  static void showInfo(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 경고 메시지 표시 (주황색 배경)
  static void showWarning(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
