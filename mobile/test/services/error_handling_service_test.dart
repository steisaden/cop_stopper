import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/services.dart';
import 'package:mobile/src/services/error_handling_service.dart';
import 'package:mobile/src/services/storage_service.dart';
import 'package:mobile/src/services/notification_service.dart';

import '../mocks/mock_storage_service.dart';

@GenerateMocks([NotificationService])
import 'error_handling_service_test.mocks.dart';

void main() {
  group('ErrorHandlingService', () {
    late ErrorHandlingService errorHandlingService;
    late MockStorageService mockStorageService;
    late MockNotificationService mockNotificationService;

    setUp(() {
      mockStorageService = MockStorageService();
      mockNotificationService = MockNotificationService();
      errorHandlingService = ErrorHandlingService(
        mockStorageService,
        mockNotificationService,
      );
    });

    tearDown(() {
      errorHandlingService.dispose();
    });

    group('handleError', () {
      test('should log error and notify listeners', () async {
        // Arrange
        const testError = 'Test error';
        const testContext = 'Test context';
        
        // Act
        await errorHandlingService.handleError(
          testError,
          context: testContext,
          severity: ErrorSeverity.medium,
        );

        // Assert
        verify(mockStorageService.appendToFile(any, any)).called(1);
        verify(mockNotificationService.showError(any, any)).called(1);
      });

      test('should handle critical errors specially', () async {
        // Arrange
        const testError = 'Critical test error';
        
        // Act
        await errorHandlingService.handleError(
          testError,
          severity: ErrorSeverity.critical,
        );

        // Assert
        verify(mockStorageService.appendToFile(any, any)).called(1);
        verify(mockNotificationService.showError('Critical Error', any)).called(1);
      });

      test('should not show user notification when showToUser is false', () async {
        // Arrange
        const testError = 'Test error';
        
        // Act
        await errorHandlingService.handleError(
          testError,
          showToUser: false,
        );

        // Assert
        verify(mockStorageService.appendToFile(any, any)).called(1);
        verifyNever(mockNotificationService.showError(any, any));
      });
    });

    group('handleRecordingError', () {
      test('should handle camera access denied error', () async {
        // Arrange
        final testError = PlatformException(
          code: 'CAMERA_ACCESS_DENIED',
          message: 'Camera access denied',
        );
        
        // Act
        await errorHandlingService.handleRecordingError(testError);

        // Assert
        verify(mockStorageService.appendToFile(any, any)).called(1);
        verify(mockNotificationService.showError(
          'Recording Error',
          'Camera access is required for video recording.',
        )).called(1);
      });

      test('should handle microphone access denied error', () async {
        // Arrange
        final testError = PlatformException(
          code: 'MICROPHONE_ACCESS_DENIED',
          message: 'Microphone access denied',
        );
        
        // Act
        await errorHandlingService.handleRecordingError(testError);

        // Assert
        verify(mockStorageService.appendToFile(any, any)).called(1);
        verify(mockNotificationService.showError(
          'Recording Error',
          'Microphone access is required for audio recording.',
        )).called(1);
      });

      test('should handle storage full error', () async {
        // Arrange
        final testError = PlatformException(
          code: 'STORAGE_FULL',
          message: 'Storage full',
        );
        
        // Act
        await errorHandlingService.handleRecordingError(testError);

        // Assert
        verify(mockStorageService.appendToFile(any, any)).called(1);
        verify(mockNotificationService.showError(
          'Recording Error',
          'Not enough storage space for recording.',
        )).called(1);
      });
    });

    group('handlePlatformError', () {
      test('should handle permission denied error', () async {
        // Arrange
        final testError = PlatformException(
          code: 'PERMISSION_DENIED',
          message: 'Permission denied',
        );
        
        // Act
        await errorHandlingService.handlePlatformError(
          testError,
          context: 'Test context',
        );

        // Assert
        verify(mockStorageService.appendToFile(any, any)).called(1);
        verify(mockNotificationService.showError(
          'Permission Required',
          'This feature requires additional permissions to work properly.',
        )).called(1);
      });

      test('should handle location access denied error', () async {
        // Arrange
        final testError = PlatformException(
          code: 'LOCATION_ACCESS_DENIED',
          message: 'Location access denied',
        );
        
        // Act
        await errorHandlingService.handlePlatformError(testError);

        // Assert
        verify(mockStorageService.appendToFile(any, any)).called(1);
        verify(mockNotificationService.showError(
          'Location Access Denied',
          'Please enable location access in your device settings.',
        )).called(1);
      });
    });

    group('error stream', () {
      test('should emit errors to stream', () async {
        // Arrange
        const testError = 'Stream test error';
        final errorStream = errorHandlingService.errorStream;
        
        // Act & Assert
        expectLater(
          errorStream,
          emits(predicate<AppError>((error) => error.error == testError)),
        );
        
        await errorHandlingService.handleError(testError, showToUser: false);
      });
    });

    group('clearErrorLogs', () {
      test('should clear error logs', () async {
        // Act
        await errorHandlingService.clearErrorLogs();

        // Assert
        verify(mockStorageService.deleteFile('error_log.json')).called(1);
      });
    });
  });

  group('AppError', () {
    test('should create AppError with required fields', () {
      // Arrange & Act
      final error = AppError(
        error: 'Test error',
        severity: ErrorSeverity.medium,
        timestamp: DateTime.now(),
      );

      // Assert
      expect(error.error, equals('Test error'));
      expect(error.severity, equals(ErrorSeverity.medium));
      expect(error.retryCount, equals(0));
      expect(error.maxRetries, equals(0));
    });

    test('should create AppError with all fields', () {
      // Arrange
      final timestamp = DateTime.now();
      final stackTrace = StackTrace.current;
      
      // Act
      final error = AppError(
        error: 'Test error',
        stackTrace: stackTrace,
        context: 'Test context',
        severity: ErrorSeverity.high,
        timestamp: timestamp,
        retryCount: 2,
        maxRetries: 3,
      );

      // Assert
      expect(error.error, equals('Test error'));
      expect(error.stackTrace, equals(stackTrace));
      expect(error.context, equals('Test context'));
      expect(error.severity, equals(ErrorSeverity.high));
      expect(error.timestamp, equals(timestamp));
      expect(error.retryCount, equals(2));
      expect(error.maxRetries, equals(3));
    });

    test('should have proper toString implementation', () {
      // Arrange
      final timestamp = DateTime.now();
      final error = AppError(
        error: 'Test error',
        context: 'Test context',
        severity: ErrorSeverity.medium,
        timestamp: timestamp,
      );

      // Act
      final result = error.toString();

      // Assert
      expect(result, contains('Test error'));
      expect(result, contains('Test context'));
      expect(result, contains('ErrorSeverity.medium'));
    });
  });
}