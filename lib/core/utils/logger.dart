import 'package:flutter/foundation.dart';

class AppLogger {
  static void i(String message) {
    if (kDebugMode) {
      print('💡 [INFO] ${DateTime.now().toIso8601String()}: $message');
    }
  }

  static void w(String message) {
    if (kDebugMode) {
      print('⚠️ [WARN] ${DateTime.now().toIso8601String()}: $message');
    }
  }

  static void e(dynamic error, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('❌ [ERROR] ${DateTime.now().toIso8601String()}: $error');
      if (stackTrace != null) {
        print(stackTrace);
      }
    }
  }
}
