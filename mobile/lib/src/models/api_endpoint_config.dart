/// Configuration for API endpoints by jurisdiction
class ApiEndpointConfig {
  final String id;
  final String name;
  final String baseUrl;
  final ApiType apiType;
  final AuthType authType;
  final int rateLimitPerMinute;
  final List<String> dataTypes;
  final Map<String, String>? headers;
  final String? apiKeyHeader;
  final bool isActive;

  const ApiEndpointConfig({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.apiType,
    required this.authType,
    required this.rateLimitPerMinute,
    required this.dataTypes,
    this.headers,
    this.apiKeyHeader,
    this.isActive = true,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'base_url': baseUrl,
      'api_type': apiType.name,
      'auth_type': authType.name,
      'rate_limit_per_minute': rateLimitPerMinute,
      'data_types': dataTypes,
      'headers': headers,
      'api_key_header': apiKeyHeader,
      'is_active': isActive,
    };
  }

  /// Create from JSON
  factory ApiEndpointConfig.fromJson(Map<String, dynamic> json) {
    return ApiEndpointConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      baseUrl: json['base_url'] as String,
      apiType: ApiType.values.byName(json['api_type'] as String),
      authType: AuthType.values.byName(json['auth_type'] as String),
      rateLimitPerMinute: json['rate_limit_per_minute'] as int,
      dataTypes: (json['data_types'] as List<dynamic>).cast<String>(),
      headers: (json['headers'] as Map<String, dynamic>?)?.cast<String, String>(),
      apiKeyHeader: json['api_key_header'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Check if this endpoint supports a specific data type
  bool supportsDataType(String dataType) {
    return dataTypes.contains(dataType);
  }

  /// Get the API key header name (default or custom)
  String getApiKeyHeader() {
    return apiKeyHeader ?? _getDefaultApiKeyHeader();
  }

  String _getDefaultApiKeyHeader() {
    return 'Authorization'; // Default header for API key
    switch (authType) {
      case AuthType.apiKey:
        return 'X-API-Key';
      case AuthType.bearer:
        return 'Authorization';
      case AuthType.basic:
        return 'Authorization';
      case AuthType.none:
        return '';
    }
  }

  /// Create a copy with updated values
  ApiEndpointConfig copyWith({
    String? id,
    String? name,
    String? baseUrl,
    ApiType? apiType,
    AuthType? authType,
    int? rateLimitPerMinute,
    List<String>? dataTypes,
    Map<String, String>? headers,
    String? apiKeyHeader,
    bool? isActive,
  }) {
    return ApiEndpointConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      apiType: apiType ?? this.apiType,
      authType: authType ?? this.authType,
      rateLimitPerMinute: rateLimitPerMinute ?? this.rateLimitPerMinute,
      dataTypes: dataTypes ?? this.dataTypes,
      headers: headers ?? this.headers,
      apiKeyHeader: apiKeyHeader ?? this.apiKeyHeader,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'ApiEndpointConfig(id: $id, name: $name, baseUrl: $baseUrl)';
  }
}

/// Types of APIs
enum ApiType {
  rest,       // RESTful HTTP API
  graphql,    // GraphQL API
  soap,       // SOAP web service
  websocket,  // WebSocket connection
}

/// Authentication types
enum AuthType {
  none,       // No authentication required
  apiKey,     // API key in header
  bearer,     // Bearer token
  basic,      // Basic authentication
  oauth2,     // OAuth 2.0
}