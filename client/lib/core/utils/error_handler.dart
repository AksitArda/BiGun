import 'package:flutter/material.dart';

class ErrorHandler {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static String handleException(dynamic error) {
    if (error is String) {
      return error;
    }
    
    // Network errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Connection refused')) {
      return 'Sunucuya bağlanılamadı. Lütfen internet bağlantınızı kontrol edin.';
    }
    
    // Timeout errors
    if (error.toString().contains('TimeoutException')) {
      return 'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.';
    }
    
    // Format errors
    if (error.toString().contains('FormatException')) {
      return 'Sunucudan geçersiz veri alındı.';
    }
    
    return error.toString();
  }
} 