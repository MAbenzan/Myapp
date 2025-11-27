import 'package:logger/logger.dart';

/// Global logger instance used throughout the app.
///
/// Example usage:
///   logger.i('Informational message');
///   logger.w('Warning message');
///   logger.e('Error message');
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2, // number of method calls to display
    errorMethodCount: 3,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);
