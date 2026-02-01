import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mobile/src/services/storage_service.dart';
import 'package:mobile/src/services/notification_service.dart';

/// Centralized error handling service for the application
class ErrorHandlingService {
  final StorageService _storageService;
  final NotificationService _notificationService;
  
  final StreamController<AppError> _errorController = StreamController<AppError>.broadcast();
  
  ErrorHandlingService(this._storageService, this._notificationService);
  
  /// Stream of application errors
  Stream<AppError> get errorStream => _errorController.stream;
  
  /// Handle a general error
  Future<void> handleError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    ErrorSeverity severity = ErrorSeverity.medium,
    bool showToUser = true,
  }) async {
    final appError = AppError(
      error: error,
      stackTrace: stackTrace,
      context: context,
      severity: severity,
      timestamp: DateTime.now(),
    );
    
    // Log the error
    await _logError(appError);
    
    // Notify listeners
    _errorController.add(appError);
    
    // Show user notification if requested
    if (showToUser) {
      await _showUserNotification(appError);
    }
    
    // Handle critical errors
    if (severity == ErrorSeverity.critical) {
      await _handleCriticalError(appError);
    }
  }
  
  /// Handle recording-specific errors with retry logic
  Future<void> handleRecordingError(
    dynamic error, {
    StackTrace? stackTrace,
    int retryCount = 0,
    int maxRetries = 3,
  }) async {
    final appError = AppError(
      error: error,
      stackTrace: stackTrace,
      context: 'Recording',
      severity: ErrorSeverity.high,
      timestamp: DateTime.now(),
      retryCount: retryCount,
      maxRetries: maxRetries,
    );
    
    await _logError(appError);
    _errorController.add(appError);
    
    // Show specific recording error message
    await _notificationService.showError(
      'Recording Error',
      _getRecordingErrorMessage(error),
    );
    
    // Implement retry logic for recoverable errors
    if (retryCount < maxRetries && _isRecoverableRecordingError(error)) {
      // Wait before retry with exponential backoff
      await Future.delayed(Duration(seconds: (retryCount + 1) * 2));
      // The calling code should handle the actual retry
    }
  }
  
  /// Handle API errors with retry logic
  Future<void> handleApiError(
    dynamic error, {
    StackTrace? stackTrace,
    String? endpoint,
    int retryCount = 0,
    int maxRetries = 3,
  }) async {
    final appError = AppError(
      error: error,
      stackTrace: stackTrace,
      context: 'API: $endpoint',
      severity: _getApiErrorSeverity(error),
      timestamp: DateTime.now(),
      retryCount: retryCount,
      maxRetries: maxRetries,
    );
    
    await _logError(appError);
    _errorController.add(appError);
    
    // Handle specific API error types
    if (error is SocketException) {
      await _notificationService.showError(
        'Connection Error',
        'Unable to connect to server. Please check your internet connection.',
      );
    } else if (error is TimeoutException) {
      await _notificationService.showError(
        'Request Timeout',
        'The request took too long to complete. Please try again.',
      );
    } else if (error is HttpException) {
      await _notificationService.showError(
        'Server Error',
        'Server returned an error. Please try again later.',
      );
    }
  }
  
  /// Handle platform-specific errors
  Future<void> handlePlatformError(
    PlatformException error, {
    StackTrace? stackTrace,
    String? context,
  }) async {
    final appError = AppError(
      error: error,
      stackTrace: stackTrace,
      context: 'Platform: $context',
      severity: _getPlatformErrorSeverity(error),
      timestamp: DateTime.now(),
    );
    
    await _logError(appError);
    _errorController.add(appError);
    
    // Handle specific platform errors
    switch (error.code) {
      case 'PERMISSION_DENIED':
        await _notificationService.showError(
          'Permission Required',
          'This feature requires additional permissions to work properly.',
        );
        break;
      case 'CAMERA_ACCESS_DENIED':
        await _notificationService.showError(
          'Camera Access Denied',
          'Please enable camera access in your device settings.',
        );
        break;
      case 'MICROPHONE_ACCESS_DENIED':
        await _notificationService.showError(
          'Microphone Access Denied',
          'Please enable microphone access in your device settings.',
        );
        break;
      case 'LOCATION_ACCESS_DENIED':
        await _notificationService.showError(
          'Location Access Denied',
          'Please enable location access in your device settings.',
        );
        break;
      default:
        await _notificationService.showError(
          'System Error',
          error.message ?? 'An unexpected system error occurred.',
        );
    }
  }
  
  /// Log error to storage
  Future<void> _logError(AppError error) async {
    try {
      final errorLog = {
        'timestamp': error.timestamp.toIso8601String(),
        'error': error.error.toString(),
        'stackTrace': error.stackTrace?.toString(),
        'context': error.context,
        'severity': error.severity.toString(),
        'retryCount': error.retryCount,
        'maxRetries': error.maxRetries,
      };
      
      await _storageService.appendToFile('error_log.json', errorLog.toString());
      
      // Also log to console in debug mode
      if (kDebugMode) {
        print('ERROR [${error.severity}] ${error.context}: ${error.error}');
        if (error.stackTrace != null) {
          print('Stack trace: ${error.stackTrace}');
        }
      }
    } catch (e) {
      // Fallback logging if storage fails
      if (kDebugMode) {
        print('Failed to log error: $e');
        print('Original error: ${error.error}');
      }
    }
  }
  
  /// Show user-friendly error notification
  Future<void> _showUserNotification(AppError error) async {
    String title = 'Error';
    String message = 'An unexpected error occurred.';
    
    switch (error.severity) {
      case ErrorSeverity.low:
        title = 'Notice';
        message = 'A minor issue occurred but the app should continue working normally.';
        break;
      case ErrorSeverity.medium:
        title = 'Warning';
        message = 'An issue occurred that may affect some functionality.';
        break;
      case ErrorSeverity.high:
        title = 'Error';
        message = 'An error occurred that may affect app functionality.';
        break;
      case ErrorSeverity.critical:
        title = 'Critical Error';
        message = 'A critical error occurred. Please restart the app.';
        break;
    }
    
    await _notificationService.showError(title, message);
  }
  
  /// Handle critical errors that may require app restart
  Future<void> _handleCriticalError(AppError error) async {
    // Log critical error with high priority
    await _logError(error);
    
    // Could implement crash reporting here
    // await _crashReportingService.reportCrash(error);
    
    // Show critical error dialog
    await _notificationService.showError(
      'Critical Error',
      'A critical error occurred. The app may need to be restarted. Error details have been logged.',
    );
  }
  
  /// Get user-friendly recording error message
  String _getRecordingErrorMessage(dynamic error) {
    if (error is PlatformException) {
      switch (error.code) {
        case 'CAMERA_ACCESS_DENIED':
          return 'Camera access is required for video recording.';
        case 'MICROPHONE_ACCESS_DENIED':
          return 'Microphone access is required for audio recording.';
        case 'STORAGE_FULL':
          return 'Not enough storage space for recording.';
        case 'RECORDING_IN_PROGRESS':
          return 'Another recording is already in progress.';
        default:
          return error.message ?? 'Recording failed due to an unknown error.';
      }
    }
    return 'Recording failed. Please try again.';
  }
  
  /// Check if a recording error is recoverable
  bool _isRecoverableRecordingError(dynamic error) {
    if (error is PlatformException) {
      switch (error.code) {
        case 'CAMERA_ACCESS_DENIED':
        case 'MICROPHONE_ACCESS_DENIED':
        case 'STORAGE_FULL':
          return false; // These require user action
        case 'RECORDING_FAILED':
        case 'INITIALIZATION_FAILED':
          return true; // These might work on retry
        default:
          return false;
      }
    }
    return false;
  }
  
  /// Get severity for API errors
  ErrorSeverity _getApiErrorSeverity(dynamic error) {
    if (error is SocketException || error is TimeoutException) {
      return ErrorSeverity.medium; // Network issues are medium severity
    } else if (error is HttpException) {
      return ErrorSeverity.high; // Server errors are high severity
    }
    return ErrorSeverity.medium;
  }
  
  /// Get severity for platform errors
  ErrorSeverity _getPlatformErrorSeverity(PlatformException error) {
    switch (error.code) {
      case 'PERMISSION_DENIED':
      case 'CAMERA_ACCESS_DENIED':
      case 'MICROPHONE_ACCESS_DENIED':
      case 'LOCATION_ACCESS_DENIED':
        return ErrorSeverity.high; // Permission errors affect core functionality
      case 'STORAGE_FULL':
        return ErrorSeverity.critical; // Storage full is critical
      default:
        return ErrorSeverity.medium;
    }
  }
  
  /// Get recent errors for debugging
  Future<List<AppError>> getRecentErrors({int limit = 50}) async {
    // This would read from the error log file
    // For now, return empty list
    return [];
  }
  
  /// Clear error logs
  Future<void> clearErrorLogs() async {
    try {
      await _storageService.deleteFile('error_log.json');
    } catch (e) {
      if (kDebugMode) {
        print('Failed to clear error logs: $e');
      }
    }
  }
  
  /// Dispose resources
  void dispose() {
    _errorController.close();
  }
}

/// Application error model
class AppError {
  final dynamic error;
  final StackTrace? stackTrace;
  final String? context;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final int retryCount;
  final int maxRetries;
  
  AppError({
    required this.error,
    this.stackTrace,
    this.context,
    required this.severity,
    required this.timestamp,
    this.retryCount = 0,
    this.maxRetries = 0,
  });
  
  @override
  String toString() {
    return 'AppError(error: $error, context: $context, severity: $severity, timestamp: $timestamp)';
  }
}

/// Error severity levels
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}