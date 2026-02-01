import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mobile/src/services/storage_service.dart';
import 'package:mobile/src/services/api_service.dart';

/// Service for managing deployment configuration and monitoring
class DeploymentService {
  final StorageService _storageService;
  final ApiService _apiService;
  
  static const String _deploymentConfigKey = 'deployment_config';
  static const String _buildInfoKey = 'build_info';
  static const String _featureFlagsKey = 'feature_flags';
  
  DeploymentService(this._storageService, this._apiService);
  
  /// Get current deployment environment
  DeploymentEnvironment get currentEnvironment {
    if (kDebugMode) {
      return DeploymentEnvironment.development;
    } else if (kProfileMode) {
      return DeploymentEnvironment.staging;
    } else {
      return DeploymentEnvironment.production;
    }
  }
  
  /// Get deployment configuration
  Future<DeploymentConfig> getDeploymentConfig() async {
    try {
      final configJson = await _storageService.readFromFile(_deploymentConfigKey);
      if (configJson != null) {
        final configMap = jsonDecode(configJson);
        return DeploymentConfig.fromJson(configMap);
      }
    } catch (e) {
      print('Error reading deployment config: $e');
    }
    
    // Return default config if none exists
    return DeploymentConfig.defaultConfig(currentEnvironment);
  }
  
  /// Save deployment configuration
  Future<void> saveDeploymentConfig(DeploymentConfig config) async {
    try {
      final configJson = jsonEncode(config.toJson());
      await _storageService.writeToFile(_deploymentConfigKey, configJson);
    } catch (e) {
      print('Error saving deployment config: $e');
    }
  }
  
  /// Get build information
  Future<BuildInfo> getBuildInfo() async {
    try {
      final buildInfoJson = await _storageService.readFromFile(_buildInfoKey);
      if (buildInfoJson != null) {
        final buildInfoMap = jsonDecode(buildInfoJson);
        return BuildInfo.fromJson(buildInfoMap);
      }
    } catch (e) {
      print('Error reading build info: $e');
    }
    
    // Return default build info
    return BuildInfo.defaultInfo();
  }
  
  /// Save build information
  Future<void> saveBuildInfo(BuildInfo buildInfo) async {
    try {
      final buildInfoJson = jsonEncode(buildInfo.toJson());
      await _storageService.writeToFile(_buildInfoKey, buildInfoJson);
    } catch (e) {
      print('Error saving build info: $e');
    }
  }
  
  /// Get feature flags
  Future<Map<String, bool>> getFeatureFlags() async {
    try {
      final flagsJson = await _storageService.readFromFile(_featureFlagsKey);
      if (flagsJson != null) {
        final flagsMap = jsonDecode(flagsJson);
        return Map<String, bool>.from(flagsMap);
      }
    } catch (e) {
      print('Error reading feature flags: $e');
    }
    
    // Return default feature flags
    return _getDefaultFeatureFlags();
  }
  
  /// Save feature flags
  Future<void> saveFeatureFlags(Map<String, bool> flags) async {
    try {
      final flagsJson = jsonEncode(flags);
      await _storageService.writeToFile(_featureFlagsKey, flagsJson);
    } catch (e) {
      print('Error saving feature flags: $e');
    }
  }
  
  /// Check if a feature is enabled
  Future<bool> isFeatureEnabled(String featureName) async {
    final flags = await getFeatureFlags();
    return flags[featureName] ?? false;
  }
  
  /// Enable or disable a feature
  Future<void> setFeatureEnabled(String featureName, bool enabled) async {
    final flags = await getFeatureFlags();
    flags[featureName] = enabled;
    await saveFeatureFlags(flags);
  }
  
  /// Fetch remote configuration
  Future<void> fetchRemoteConfig() async {
    try {
      final response = await _apiService.get('/config/deployment');
      if (response['success'] == true) {
        final remoteConfig = DeploymentConfig.fromJson(response['data']);
        await saveDeploymentConfig(remoteConfig);
        
        if (response['data']['feature_flags'] != null) {
          final remoteFlags = Map<String, bool>.from(response['data']['feature_flags']);
          await saveFeatureFlags(remoteFlags);
        }
      }
    } catch (e) {
      print('Error fetching remote config: $e');
      // Continue with local config if remote fetch fails
    }
  }
  
  /// Send deployment metrics
  Future<void> sendDeploymentMetrics() async {
    try {
      final config = await getDeploymentConfig();
      final buildInfo = await getBuildInfo();
      
      final metrics = {
        'environment': currentEnvironment.toString(),
        'version': buildInfo.version,
        'build_number': buildInfo.buildNumber,
        'platform': Platform.operatingSystem,
        'timestamp': DateTime.now().toIso8601String(),
        'config': config.toJson(),
      };
      
      await _apiService.post('/metrics/deployment', metrics);
    } catch (e) {
      print('Error sending deployment metrics: $e');
      // Don't throw - metrics are not critical
    }
  }
  
  /// Perform health check
  Future<HealthCheckResult> performHealthCheck() async {
    final results = <String, bool>{};
    final errors = <String>[];
    
    // Check API connectivity
    try {
      await _apiService.get('/health');
      results['api_connectivity'] = true;
    } catch (e) {
      results['api_connectivity'] = false;
      errors.add('API connectivity failed: $e');
    }
    
    // Check storage
    try {
      await _storageService.writeToFile('health_check', 'test');
      await _storageService.deleteFile('health_check');
      results['storage'] = true;
    } catch (e) {
      results['storage'] = false;
      errors.add('Storage check failed: $e');
    }
    
    // Check permissions (basic check)
    results['permissions'] = true; // Would implement actual permission checks
    
    final isHealthy = results.values.every((result) => result);
    
    return HealthCheckResult(
      isHealthy: isHealthy,
      checks: results,
      errors: errors,
      timestamp: DateTime.now(),
    );
  }
  
  /// Get default feature flags based on environment
  Map<String, bool> _getDefaultFeatureFlags() {
    switch (currentEnvironment) {
      case DeploymentEnvironment.development:
        return {
          'debug_mode': true,
          'crash_reporting': false,
          'analytics': false,
          'beta_features': true,
          'offline_mode': true,
          'advanced_logging': true,
        };
      case DeploymentEnvironment.staging:
        return {
          'debug_mode': false,
          'crash_reporting': true,
          'analytics': true,
          'beta_features': true,
          'offline_mode': true,
          'advanced_logging': true,
        };
      case DeploymentEnvironment.production:
        return {
          'debug_mode': false,
          'crash_reporting': true,
          'analytics': true,
          'beta_features': false,
          'offline_mode': true,
          'advanced_logging': false,
        };
    }
  }
}

/// Deployment environment enum
enum DeploymentEnvironment {
  development,
  staging,
  production,
}

/// Deployment configuration model
class DeploymentConfig {
  final DeploymentEnvironment environment;
  final String apiBaseUrl;
  final bool enableCrashReporting;
  final bool enableAnalytics;
  final int apiTimeoutSeconds;
  final int maxRetryAttempts;
  final bool enableDebugLogging;
  final Map<String, dynamic> customSettings;
  
  DeploymentConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableCrashReporting,
    required this.enableAnalytics,
    required this.apiTimeoutSeconds,
    required this.maxRetryAttempts,
    required this.enableDebugLogging,
    required this.customSettings,
  });
  
  factory DeploymentConfig.defaultConfig(DeploymentEnvironment environment) {
    switch (environment) {
      case DeploymentEnvironment.development:
        return DeploymentConfig(
          environment: environment,
          apiBaseUrl: 'http://localhost:3000/api',
          enableCrashReporting: false,
          enableAnalytics: false,
          apiTimeoutSeconds: 30,
          maxRetryAttempts: 3,
          enableDebugLogging: true,
          customSettings: {},
        );
      case DeploymentEnvironment.staging:
        return DeploymentConfig(
          environment: environment,
          apiBaseUrl: 'https://staging-api.copstopperapp.com/api',
          enableCrashReporting: true,
          enableAnalytics: true,
          apiTimeoutSeconds: 30,
          maxRetryAttempts: 3,
          enableDebugLogging: true,
          customSettings: {},
        );
      case DeploymentEnvironment.production:
        return DeploymentConfig(
          environment: environment,
          apiBaseUrl: 'https://api.copstopperapp.com/api',
          enableCrashReporting: true,
          enableAnalytics: true,
          apiTimeoutSeconds: 30,
          maxRetryAttempts: 3,
          enableDebugLogging: false,
          customSettings: {},
        );
    }
  }
  
  factory DeploymentConfig.fromJson(Map<String, dynamic> json) {
    return DeploymentConfig(
      environment: DeploymentEnvironment.values.firstWhere(
        (e) => e.toString() == json['environment'],
        orElse: () => DeploymentEnvironment.production,
      ),
      apiBaseUrl: json['api_base_url'] ?? '',
      enableCrashReporting: json['enable_crash_reporting'] ?? false,
      enableAnalytics: json['enable_analytics'] ?? false,
      apiTimeoutSeconds: json['api_timeout_seconds'] ?? 30,
      maxRetryAttempts: json['max_retry_attempts'] ?? 3,
      enableDebugLogging: json['enable_debug_logging'] ?? false,
      customSettings: Map<String, dynamic>.from(json['custom_settings'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'environment': environment.toString(),
      'api_base_url': apiBaseUrl,
      'enable_crash_reporting': enableCrashReporting,
      'enable_analytics': enableAnalytics,
      'api_timeout_seconds': apiTimeoutSeconds,
      'max_retry_attempts': maxRetryAttempts,
      'enable_debug_logging': enableDebugLogging,
      'custom_settings': customSettings,
    };
  }
}

/// Build information model
class BuildInfo {
  final String version;
  final String buildNumber;
  final DateTime buildDate;
  final String gitCommit;
  final String gitBranch;
  final String buildEnvironment;
  
  BuildInfo({
    required this.version,
    required this.buildNumber,
    required this.buildDate,
    required this.gitCommit,
    required this.gitBranch,
    required this.buildEnvironment,
  });
  
  factory BuildInfo.defaultInfo() {
    return BuildInfo(
      version: '1.0.0',
      buildNumber: '1',
      buildDate: DateTime.now(),
      gitCommit: 'unknown',
      gitBranch: 'main',
      buildEnvironment: kDebugMode ? 'debug' : 'release',
    );
  }
  
  factory BuildInfo.fromJson(Map<String, dynamic> json) {
    return BuildInfo(
      version: json['version'] ?? '1.0.0',
      buildNumber: json['build_number'] ?? '1',
      buildDate: DateTime.parse(json['build_date'] ?? DateTime.now().toIso8601String()),
      gitCommit: json['git_commit'] ?? 'unknown',
      gitBranch: json['git_branch'] ?? 'main',
      buildEnvironment: json['build_environment'] ?? 'release',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'build_number': buildNumber,
      'build_date': buildDate.toIso8601String(),
      'git_commit': gitCommit,
      'git_branch': gitBranch,
      'build_environment': buildEnvironment,
    };
  }
}

/// Health check result model
class HealthCheckResult {
  final bool isHealthy;
  final Map<String, bool> checks;
  final List<String> errors;
  final DateTime timestamp;
  
  HealthCheckResult({
    required this.isHealthy,
    required this.checks,
    required this.errors,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'is_healthy': isHealthy,
      'checks': checks,
      'errors': errors,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}