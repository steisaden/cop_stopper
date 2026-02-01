import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/src/services/api_service.dart';
import 'package:mobile/src/services/recording_service_interface.dart';
import 'package:mobile/src/services/storage_service.dart';
import 'package:mobile/src/ui/theme.dart';
import 'mocks/mock_api_service.dart';
import 'mocks/mock_recording_service.dart';
import 'mocks/mock_storage_service.dart';

final GetIt locator = GetIt.instance;

void setupLocatorForTest() {
  locator.registerLazySingleton<ApiService>(() => MockApiService());
  locator.registerLazySingleton<StorageService>(() => MockStorageService());
  locator.registerLazySingleton<RecordingService>(() => MockRecordingService());
}

class TestHelpers {
  /// Creates a test app wrapper with proper theme and material app
  static Widget createTestApp({required Widget child}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: Scaffold(
        body: SingleChildScrollView(
          child: child,
        ),
      ),
    );
  }

  /// Creates a test app wrapper with custom theme mode
  static Widget createTestAppWithTheme({
    required Widget child,
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: Scaffold(
        body: child,
      ),
    );
  }
}