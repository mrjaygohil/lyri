import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  static String formatError(dynamic error) {
    if (error is PostgrestException) {
      return error.message;
    } else if (error is AuthException) {
      return error.message;
    } else if (error is StorageException) {
      return error.message;
    }
    
    final String errorStr = error.toString();
    if (errorStr.startsWith('Exception: ')) {
      return errorStr.substring('Exception: '.length);
    }
    return errorStr;
  }
}
