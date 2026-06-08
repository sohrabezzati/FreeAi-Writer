import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void _log(String level, String message, [Object? error, StackTrace? stackTrace]) {
    final time = DateTime.now().toIso8601String();
    final formattedMessage = '[$time] [$level] $message';
    
    // Log to developer tools
    developer.log(
      message,
      name: level,
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );

    // Print to console in debug mode
    if (kDebugMode) {
      print(formattedMessage);
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print(stackTrace);
      }
    }
  }

  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _log('DEBUG', message, error, stackTrace);
  }

  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    _log('INFO', message, error, stackTrace);
  }

  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log('WARNING', message, error, stackTrace);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace);
  }
}
