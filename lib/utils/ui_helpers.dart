import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/logger_service.dart';

class UIHelpers {
  static final LoggerService _logger = LoggerService();

  static void showSuccess({required String title, required String message}) {
    _logger.ui(
      widget: 'Snackbar',
      action: 'Show Success',
      metadata: {'title': title, 'message': message},
    );
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.white,
        size: 28,
      ),
      duration: const Duration(seconds: 3),
    );
  }

  static void showError({required String title, required String message}) {
    _logger.ui(
      widget: 'Snackbar',
      action: 'Show Error',
      metadata: {'title': title, 'message': message},
    );
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: Colors.white, size: 28),
      duration: const Duration(seconds: 4),
    );
  }

  static void showWarning({required String title, required String message}) {
    _logger.ui(
      widget: 'Snackbar',
      action: 'Show Warning',
      metadata: {'title': title, 'message': message},
    );
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.orange.shade800,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  static void showInfo({required String title, required String message}) {
    _logger.ui(
      widget: 'Snackbar',
      action: 'Show Info',
      metadata: {'title': title, 'message': message},
    );
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.blue.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.info_outline, color: Colors.white, size: 28),
    );
  }

  static Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Ya, Lanjutkan',
    String cancelText = 'Batal',
    Color? confirmColor,
  }) async {
    _logger.ui(
      widget: 'Dialog',
      action: 'Show Confirm',
      metadata: {'title': title},
    );
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              cancelText,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
