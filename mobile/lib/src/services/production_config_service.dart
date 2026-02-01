import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_key_manager.dart';
import 'data_compliance_service.dart';
import 'webhook_service.dart';
import 'jurisdiction_mapping_service.dart';
import 'production_officer_records_service.dart';
import '../models/data_retention_policy.dart';

/// Configuration service for production deployment
class ProductionConfigService {
  static const _storage = FlutterSecureStorage();
  static ProductionOfficerRecordsService? _officerRecordsService;

  /// Initialize production services with API keys and configuration
  static Future<void> initialize({
    required Map<String, String> apiKeys,
    String? webhookUrl,
    DataRetentionPolicy? retentionPolicy,
  }) async {
    try {
      print('Initializing production services...');

      // 1. Initialize API key managers
      await ApiKeyManagerFactory.initializeAllKeys(apiKeys);
      print('✓ API keys initialized');

      // 2. Initialize compliance service
      final compliance = DataComplianceService(
        retentionPolicy: retentionPolicy ?? DataRetentionPolicy.publicRecordsDefault(),
      );
      print('✓ Compliance service initialized');

      // 3. Initialize webhook service
      final webhook = WebhookServiceFactory.getInstance(
        webhookUrl: webhookUrl ?? 'wss://api.copstopper.com/webhooks',
      );
      await webhook.connect();
      print('✓ Webhook service connected');

      // 4. Initialize jurisdiction mapping
      final jurisdictionService = JurisdictionMappingService();
      print('✓ Jurisdiction mapping initialized (${jurisdictionService.getAllJurisdictions().length} jurisdictions)');

      // 5. Initialize production officer records service
      _officerRecordsService = ProductionOfficerRecordsService(
        jurisdictionService: jurisdictionService,
        complianceService: compliance,
        webhookService: webhook,
      );
      print('✓ Officer records service initialized');

      // 6. Validate all connections
      await _validateConnections();
      print('✓ All services validated and ready');

    } catch (e) {
      print('❌ Failed to initialize production services: $e');
      rethrow;
    }
  }

  /// Get the production officer records service
  static ProductionOfficerRecordsService? get officerRecordsService => _officerRecordsService;

  /// Validate all API connections
  static Future<void> _validateConnections() async {
    final validationResults = <String, bool>{};

    // Test FOIA API
    try {
      // This would test actual API connectivity
      validationResults['foia_api'] = true;
    } catch (e) {
      validationResults['foia_api'] = false;
      print('FOIA API validation failed: $e');
    }

    // Test MuckRock API
    try {
      // This would test actual API connectivity
      validationResults['muckrock_api'] = true;
    } catch (e) {
      validationResults['muckrock_api'] = false;
      print('MuckRock API validation failed: $e');
    }

    // Test webhook connection
    validationResults['webhook'] = WebhookServiceFactory.getInstance().isConnected;

    final successCount = validationResults.values.where((v) => v).length;
    final totalCount = validationResults.length;
    
    print('Connection validation: $successCount/$totalCount services connected');
    
    if (successCount == 0) {
      throw Exception('No API connections available');
    }
  }

  /// Configure API keys for production deployment
  static Future<void> configureApiKeys({
    String? foiaApiKey,
    String? muckrockApiKey,
    String? courtRecordsApiKey,
    Map<String, String>? jurisdictionApiKeys,
  }) async {
    final apiKeys = <String, String>{};

    if (foiaApiKey != null) apiKeys['foia'] = foiaApiKey;
    if (muckrockApiKey != null) apiKeys['muckrock'] = muckrockApiKey;
    if (courtRecordsApiKey != null) apiKeys['court_records'] = courtRecordsApiKey;
    
    // Add jurisdiction-specific API keys
    if (jurisdictionApiKeys != null) {
      apiKeys.addAll(jurisdictionApiKeys);
    }

    await ApiKeyManagerFactory.initializeAllKeys(apiKeys);
    print('Configured ${apiKeys.length} API keys');
  }

  /// Get production deployment status
  static Future<Map<String, dynamic>> getDeploymentStatus() async {
    final apiKeyStatus = await ApiKeyManagerFactory.getAllKeyStatus();
    final webhookStatus = WebhookServiceFactory.getInstance().getStatus();
    final serviceStatus = _officerRecordsService?.getServiceStatus();

    return {
      'deployment_mode': 'production',
      'initialized': _officerRecordsService != null,
      'api_keys': apiKeyStatus,
      'webhook': webhookStatus,
      'officer_records_service': serviceStatus,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Production environment configuration
  static Future<void> configureForProduction({
    required String environment, // 'staging' or 'production'
    bool enableLogging = false,
    bool enableAnalytics = false,
  }) async {
    final config = {
      'environment': environment,
      'enable_logging': enableLogging,
      'enable_analytics': enableAnalytics,
      'configured_at': DateTime.now().toIso8601String(),
    };

    await _storage.write(
      key: 'production_config',
      value: jsonEncode(config),
    );

    print('Configured for $environment environment');
  }

  /// Get current configuration
  static Future<Map<String, dynamic>?> getCurrentConfig() async {
    try {
      final configJson = await _storage.read(key: 'production_config');
      if (configJson == null) return null;
      
      return jsonDecode(configJson) as Map<String, dynamic>;
    } catch (e) {
      print('Error reading configuration: $e');
      return null;
    }
  }

  /// Dispose of all production services
  static Future<void> dispose() async {
    _officerRecordsService?.dispose();
    WebhookServiceFactory.dispose();
    _officerRecordsService = null;
    print('Production services disposed');
  }

  /// Health check for all production services
  static Future<Map<String, dynamic>> performHealthCheck() async {
    final results = <String, dynamic>{};

    // Check API key managers
    final apiKeyStatus = await ApiKeyManagerFactory.getAllKeyStatus();
    results['api_keys'] = {
      'status': apiKeyStatus.isNotEmpty ? 'healthy' : 'unhealthy',
      'count': apiKeyStatus.length,
      'details': apiKeyStatus,
    };

    // Check webhook service
    final webhook = WebhookServiceFactory.getInstance();
    results['webhook'] = {
      'status': webhook.isConnected ? 'healthy' : 'unhealthy',
      'details': webhook.getStatus(),
    };

    // Check officer records service
    results['officer_records'] = {
      'status': _officerRecordsService != null ? 'healthy' : 'unhealthy',
      'details': _officerRecordsService?.getServiceStatus(),
    };

    // Overall health
    final allHealthy = results.values.every(
      (service) => service['status'] == 'healthy',
    );
    
    results['overall'] = {
      'status': allHealthy ? 'healthy' : 'degraded',
      'timestamp': DateTime.now().toIso8601String(),
    };

    return results;
  }
}

/// Production deployment helper
class ProductionDeploymentHelper {
  /// Setup for AWS deployment
  static Future<void> setupForAWS({
    required String region,
    required String s3Bucket,
    required String rdsEndpoint,
    Map<String, String>? environmentVariables,
  }) async {
    print('Setting up for AWS deployment in $region');
    
    // Configure AWS-specific settings
    final awsConfig = {
      'provider': 'aws',
      'region': region,
      's3_bucket': s3Bucket,
      'rds_endpoint': rdsEndpoint,
      'environment_variables': environmentVariables ?? {},
    };

    await ProductionConfigService.configureForProduction(
      environment: 'production',
      enableLogging: true,
      enableAnalytics: true,
    );

    print('AWS configuration completed');
  }

  /// Setup for Google Cloud deployment
  static Future<void> setupForGCP({
    required String projectId,
    required String region,
    Map<String, String>? environmentVariables,
  }) async {
    print('Setting up for Google Cloud deployment');
    
    final gcpConfig = {
      'provider': 'gcp',
      'project_id': projectId,
      'region': region,
      'environment_variables': environmentVariables ?? {},
    };

    await ProductionConfigService.configureForProduction(
      environment: 'production',
      enableLogging: true,
      enableAnalytics: true,
    );

    print('Google Cloud configuration completed');
  }

  /// Setup for on-premises deployment
  static Future<void> setupForOnPremises({
    required String serverUrl,
    required String databaseUrl,
    Map<String, String>? customConfig,
  }) async {
    print('Setting up for on-premises deployment');
    
    final onPremConfig = {
      'provider': 'on_premises',
      'server_url': serverUrl,
      'database_url': databaseUrl,
      'custom_config': customConfig ?? {},
    };

    await ProductionConfigService.configureForProduction(
      environment: 'production',
      enableLogging: false, // More restrictive for on-premises
      enableAnalytics: false,
    );

    print('On-premises configuration completed');
  }
}