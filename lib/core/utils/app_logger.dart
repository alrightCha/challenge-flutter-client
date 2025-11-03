import 'package:logger/logger.dart';

class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to be displayed
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Log a debug message
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log an info message
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log an error message
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log HTTP request details
  static void httpRequest(String method, String url, {Map<String, dynamic>? body}) {
    info('HTTP $method $url${body != null ? '\nBody: $body' : ''}');
  }

  /// Log HTTP response details
  static void httpResponse(int statusCode, String url, {String? body}) {
    if (statusCode >= 200 && statusCode < 300) {
      info('HTTP Response [$statusCode] $url${body != null ? '\nBody: $body' : ''}');
    } else {
      error('HTTP Error [$statusCode] $url${body != null ? '\nBody: $body' : ''}');
    }
  }
}
