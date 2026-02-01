import '../models/jurisdiction_info.dart';
import '../models/api_endpoint_config.dart';

/// Service for mapping geographic locations to jurisdictions and their data sources
class JurisdictionMappingService {
  final Map<String, JurisdictionInfo> _jurisdictions = {};
  final Map<String, List<ApiEndpointConfig>> _jurisdictionEndpoints = {};

  JurisdictionMappingService() {
    _initializeJurisdictions();
  }

  /// Initialize all US jurisdictions and their data sources
  void _initializeJurisdictions() {
    // Federal jurisdiction
    _addJurisdiction(JurisdictionInfo(
      id: 'federal',
      name: 'Federal',
      type: JurisdictionType.federal,
      state: null,
      county: null,
      city: null,
      boundaries: null, // Covers entire US
      dataAvailability: DataAvailability.high,
      lastUpdated: DateTime.now(),
    ));

    // Add all 50 states + DC + territories
    _initializeStates();
    
    // Add major cities with their own police departments
    _initializeMajorCities();
    
    // Add counties with sheriff departments
    _initializeCounties();
  }

  /// Initialize all US states and territories
  void _initializeStates() {
    final states = [
      // 50 States
      {'code': 'AL', 'name': 'Alabama', 'availability': DataAvailability.medium},
      {'code': 'AK', 'name': 'Alaska', 'availability': DataAvailability.low},
      {'code': 'AZ', 'name': 'Arizona', 'availability': DataAvailability.high},
      {'code': 'AR', 'name': 'Arkansas', 'availability': DataAvailability.medium},
      {'code': 'CA', 'name': 'California', 'availability': DataAvailability.high},
      {'code': 'CO', 'name': 'Colorado', 'availability': DataAvailability.high},
      {'code': 'CT', 'name': 'Connecticut', 'availability': DataAvailability.medium},
      {'code': 'DE', 'name': 'Delaware', 'availability': DataAvailability.medium},
      {'code': 'FL', 'name': 'Florida', 'availability': DataAvailability.high},
      {'code': 'GA', 'name': 'Georgia', 'availability': DataAvailability.medium},
      {'code': 'HI', 'name': 'Hawaii', 'availability': DataAvailability.low},
      {'code': 'ID', 'name': 'Idaho', 'availability': DataAvailability.low},
      {'code': 'IL', 'name': 'Illinois', 'availability': DataAvailability.high},
      {'code': 'IN', 'name': 'Indiana', 'availability': DataAvailability.medium},
      {'code': 'IA', 'name': 'Iowa', 'availability': DataAvailability.medium},
      {'code': 'KS', 'name': 'Kansas', 'availability': DataAvailability.medium},
      {'code': 'KY', 'name': 'Kentucky', 'availability': DataAvailability.medium},
      {'code': 'LA', 'name': 'Louisiana', 'availability': DataAvailability.medium},
      {'code': 'ME', 'name': 'Maine', 'availability': DataAvailability.low},
      {'code': 'MD', 'name': 'Maryland', 'availability': DataAvailability.high},
      {'code': 'MA', 'name': 'Massachusetts', 'availability': DataAvailability.high},
      {'code': 'MI', 'name': 'Michigan', 'availability': DataAvailability.medium},
      {'code': 'MN', 'name': 'Minnesota', 'availability': DataAvailability.high},
      {'code': 'MS', 'name': 'Mississippi', 'availability': DataAvailability.low},
      {'code': 'MO', 'name': 'Missouri', 'availability': DataAvailability.medium},
      {'code': 'MT', 'name': 'Montana', 'availability': DataAvailability.low},
      {'code': 'NE', 'name': 'Nebraska', 'availability': DataAvailability.medium},
      {'code': 'NV', 'name': 'Nevada', 'availability': DataAvailability.medium},
      {'code': 'NH', 'name': 'New Hampshire', 'availability': DataAvailability.medium},
      {'code': 'NJ', 'name': 'New Jersey', 'availability': DataAvailability.high},
      {'code': 'NM', 'name': 'New Mexico', 'availability': DataAvailability.medium},
      {'code': 'NY', 'name': 'New York', 'availability': DataAvailability.high},
      {'code': 'NC', 'name': 'North Carolina', 'availability': DataAvailability.medium},
      {'code': 'ND', 'name': 'North Dakota', 'availability': DataAvailability.low},
      {'code': 'OH', 'name': 'Ohio', 'availability': DataAvailability.medium},
      {'code': 'OK', 'name': 'Oklahoma', 'availability': DataAvailability.medium},
      {'code': 'OR', 'name': 'Oregon', 'availability': DataAvailability.high},
      {'code': 'PA', 'name': 'Pennsylvania', 'availability': DataAvailability.medium},
      {'code': 'RI', 'name': 'Rhode Island', 'availability': DataAvailability.medium},
      {'code': 'SC', 'name': 'South Carolina', 'availability': DataAvailability.medium},
      {'code': 'SD', 'name': 'South Dakota', 'availability': DataAvailability.low},
      {'code': 'TN', 'name': 'Tennessee', 'availability': DataAvailability.medium},
      {'code': 'TX', 'name': 'Texas', 'availability': DataAvailability.high},
      {'code': 'UT', 'name': 'Utah', 'availability': DataAvailability.medium},
      {'code': 'VT', 'name': 'Vermont', 'availability': DataAvailability.low},
      {'code': 'VA', 'name': 'Virginia', 'availability': DataAvailability.medium},
      {'code': 'WA', 'name': 'Washington', 'availability': DataAvailability.high},
      {'code': 'WV', 'name': 'West Virginia', 'availability': DataAvailability.low},
      {'code': 'WI', 'name': 'Wisconsin', 'availability': DataAvailability.medium},
      {'code': 'WY', 'name': 'Wyoming', 'availability': DataAvailability.low},
      
      // Federal District
      {'code': 'DC', 'name': 'District of Columbia', 'availability': DataAvailability.high},
      
      // Territories
      {'code': 'PR', 'name': 'Puerto Rico', 'availability': DataAvailability.low},
      {'code': 'VI', 'name': 'U.S. Virgin Islands', 'availability': DataAvailability.low},
      {'code': 'GU', 'name': 'Guam', 'availability': DataAvailability.low},
      {'code': 'AS', 'name': 'American Samoa', 'availability': DataAvailability.low},
      {'code': 'MP', 'name': 'Northern Mariana Islands', 'availability': DataAvailability.low},
    ];

    for (final state in states) {
      final jurisdiction = JurisdictionInfo(
        id: 'state_${state['code']}',
        name: state['name'] as String,
        type: JurisdictionType.state,
        state: state['code'] as String,
        county: null,
        city: null,
        boundaries: null, // Would be populated with actual geographic boundaries
        dataAvailability: state['availability'] as DataAvailability,
        lastUpdated: DateTime.now(),
      );
      
      _addJurisdiction(jurisdiction);
      _addStateEndpoints(state['code'] as String, state['availability'] as DataAvailability);
    }
  }

  /// Initialize major cities with their own police departments
  void _initializeMajorCities() {
    final majorCities = [
      {'name': 'New York City', 'state': 'NY', 'availability': DataAvailability.high},
      {'name': 'Los Angeles', 'state': 'CA', 'availability': DataAvailability.high},
      {'name': 'Chicago', 'state': 'IL', 'availability': DataAvailability.high},
      {'name': 'Houston', 'state': 'TX', 'availability': DataAvailability.medium},
      {'name': 'Phoenix', 'state': 'AZ', 'availability': DataAvailability.medium},
      {'name': 'Philadelphia', 'state': 'PA', 'availability': DataAvailability.high},
      {'name': 'San Antonio', 'state': 'TX', 'availability': DataAvailability.medium},
      {'name': 'San Diego', 'state': 'CA', 'availability': DataAvailability.high},
      {'name': 'Dallas', 'state': 'TX', 'availability': DataAvailability.medium},
      {'name': 'San Jose', 'state': 'CA', 'availability': DataAvailability.high},
      {'name': 'Austin', 'state': 'TX', 'availability': DataAvailability.medium},
      {'name': 'Jacksonville', 'state': 'FL', 'availability': DataAvailability.medium},
      {'name': 'Fort Worth', 'state': 'TX', 'availability': DataAvailability.medium},
      {'name': 'Columbus', 'state': 'OH', 'availability': DataAvailability.medium},
      {'name': 'Charlotte', 'state': 'NC', 'availability': DataAvailability.medium},
      {'name': 'San Francisco', 'state': 'CA', 'availability': DataAvailability.high},
      {'name': 'Indianapolis', 'state': 'IN', 'availability': DataAvailability.medium},
      {'name': 'Seattle', 'state': 'WA', 'availability': DataAvailability.high},
      {'name': 'Denver', 'state': 'CO', 'availability': DataAvailability.high},
      {'name': 'Washington', 'state': 'DC', 'availability': DataAvailability.high},
      {'name': 'Boston', 'state': 'MA', 'availability': DataAvailability.high},
      {'name': 'El Paso', 'state': 'TX', 'availability': DataAvailability.medium},
      {'name': 'Detroit', 'state': 'MI', 'availability': DataAvailability.medium},
      {'name': 'Nashville', 'state': 'TN', 'availability': DataAvailability.medium},
      {'name': 'Portland', 'state': 'OR', 'availability': DataAvailability.high},
      {'name': 'Memphis', 'state': 'TN', 'availability': DataAvailability.medium},
      {'name': 'Oklahoma City', 'state': 'OK', 'availability': DataAvailability.medium},
      {'name': 'Las Vegas', 'state': 'NV', 'availability': DataAvailability.medium},
      {'name': 'Louisville', 'state': 'KY', 'availability': DataAvailability.medium},
      {'name': 'Baltimore', 'state': 'MD', 'availability': DataAvailability.high},
      {'name': 'Milwaukee', 'state': 'WI', 'availability': DataAvailability.medium},
      {'name': 'Albuquerque', 'state': 'NM', 'availability': DataAvailability.medium},
      {'name': 'Tucson', 'state': 'AZ', 'availability': DataAvailability.medium},
      {'name': 'Fresno', 'state': 'CA', 'availability': DataAvailability.medium},
      {'name': 'Mesa', 'state': 'AZ', 'availability': DataAvailability.medium},
      {'name': 'Sacramento', 'state': 'CA', 'availability': DataAvailability.high},
      {'name': 'Atlanta', 'state': 'GA', 'availability': DataAvailability.medium},
      {'name': 'Kansas City', 'state': 'MO', 'availability': DataAvailability.medium},
      {'name': 'Colorado Springs', 'state': 'CO', 'availability': DataAvailability.medium},
      {'name': 'Miami', 'state': 'FL', 'availability': DataAvailability.high},
      {'name': 'Raleigh', 'state': 'NC', 'availability': DataAvailability.medium},
      {'name': 'Omaha', 'state': 'NE', 'availability': DataAvailability.medium},
      {'name': 'Long Beach', 'state': 'CA', 'availability': DataAvailability.high},
      {'name': 'Virginia Beach', 'state': 'VA', 'availability': DataAvailability.medium},
      {'name': 'Oakland', 'state': 'CA', 'availability': DataAvailability.high},
      {'name': 'Minneapolis', 'state': 'MN', 'availability': DataAvailability.high},
      {'name': 'Tulsa', 'state': 'OK', 'availability': DataAvailability.medium},
      {'name': 'Arlington', 'state': 'TX', 'availability': DataAvailability.medium},
      {'name': 'Tampa', 'state': 'FL', 'availability': DataAvailability.medium},
      {'name': 'New Orleans', 'state': 'LA', 'availability': DataAvailability.medium},
    ];

    for (final city in majorCities) {
      final jurisdiction = JurisdictionInfo(
        id: 'city_${city['name']!.toString().toLowerCase().replaceAll(' ', '_')}_${city['state']}',
        name: '${city['name']}, ${city['state']}',
        type: JurisdictionType.city,
        state: city['state'] as String,
        county: null, // Would be populated with actual county
        city: city['name'] as String,
        boundaries: null, // Would be populated with actual city boundaries
        dataAvailability: city['availability'] as DataAvailability,
        lastUpdated: DateTime.now(),
      );
      
      _addJurisdiction(jurisdiction);
      _addCityEndpoints(city['name'] as String, city['state'] as String, city['availability'] as DataAvailability);
    }
  }

  /// Initialize major counties (placeholder - would be expanded)
  void _initializeCounties() {
    // This would be expanded to include all 3,000+ US counties
    // For now, just adding a few major ones as examples
    final majorCounties = [
      {'name': 'Los Angeles County', 'state': 'CA', 'availability': DataAvailability.high},
      {'name': 'Cook County', 'state': 'IL', 'availability': DataAvailability.high},
      {'name': 'Harris County', 'state': 'TX', 'availability': DataAvailability.medium},
      {'name': 'Maricopa County', 'state': 'AZ', 'availability': DataAvailability.medium},
      {'name': 'San Diego County', 'state': 'CA', 'availability': DataAvailability.high},
      {'name': 'Orange County', 'state': 'CA', 'availability': DataAvailability.high},
      {'name': 'Miami-Dade County', 'state': 'FL', 'availability': DataAvailability.high},
      {'name': 'Kings County', 'state': 'NY', 'availability': DataAvailability.high},
      {'name': 'Dallas County', 'state': 'TX', 'availability': DataAvailability.medium},
      {'name': 'Queens County', 'state': 'NY', 'availability': DataAvailability.high},
    ];

    for (final county in majorCounties) {
      final jurisdiction = JurisdictionInfo(
        id: 'county_${county['name']!.toString().toLowerCase().replaceAll(' ', '_').replaceAll('county', '').trim()}_${county['state']}',
        name: '${county['name']}, ${county['state']}',
        type: JurisdictionType.county,
        state: county['state'] as String,
        county: county['name'] as String,
        city: null,
        boundaries: null, // Would be populated with actual county boundaries
        dataAvailability: county['availability'] as DataAvailability,
        lastUpdated: DateTime.now(),
      );
      
      _addJurisdiction(jurisdiction);
      _addCountyEndpoints(county['name'] as String, county['state'] as String, county['availability'] as DataAvailability);
    }
  }

  /// Add a jurisdiction to the mapping
  void _addJurisdiction(JurisdictionInfo jurisdiction) {
    _jurisdictions[jurisdiction.id] = jurisdiction;
  }

  /// Add API endpoints for a state
  void _addStateEndpoints(String stateCode, DataAvailability availability) {
    final endpoints = <ApiEndpointConfig>[];
    
    // Add state-specific endpoints based on availability
    if (availability == DataAvailability.high) {
      endpoints.addAll([
        ApiEndpointConfig(
          id: 'state_${stateCode}_transparency',
          name: '$stateCode State Transparency Portal',
          baseUrl: 'https://transparency.$stateCode.gov/api',
          apiType: ApiType.rest,
          authType: AuthType.apiKey,
          rateLimitPerMinute: 100,
          dataTypes: ['officer_records', 'complaints', 'disciplinary_actions'],
        ),
        ApiEndpointConfig(
          id: 'state_${stateCode}_courts',
          name: '$stateCode Court Records',
          baseUrl: 'https://courts.$stateCode.gov/api',
          apiType: ApiType.rest,
          authType: AuthType.apiKey,
          rateLimitPerMinute: 60,
          dataTypes: ['court_records', 'legal_proceedings'],
        ),
      ]);
    } else if (availability == DataAvailability.medium) {
      endpoints.add(
        ApiEndpointConfig(
          id: 'state_${stateCode}_foia',
          name: '$stateCode FOIA Portal',
          baseUrl: 'https://foia.$stateCode.gov/api',
          apiType: ApiType.rest,
          authType: AuthType.none,
          rateLimitPerMinute: 30,
          dataTypes: ['foia_requests', 'public_records'],
        ),
      );
    }
    
    _jurisdictionEndpoints['state_$stateCode'] = endpoints;
  }

  /// Add API endpoints for a city
  void _addCityEndpoints(String cityName, String stateCode, DataAvailability availability) {
    final cityId = 'city_${cityName.toLowerCase().replaceAll(' ', '_')}_$stateCode';
    final endpoints = <ApiEndpointConfig>[];
    
    if (availability == DataAvailability.high) {
      endpoints.addAll([
        ApiEndpointConfig(
          id: '${cityId}_police_api',
          name: '$cityName Police Department API',
          baseUrl: 'https://police.${cityName.toLowerCase().replaceAll(' ', '')}.gov/api',
          apiType: ApiType.rest,
          authType: AuthType.apiKey,
          rateLimitPerMinute: 120,
          dataTypes: ['officer_records', 'complaints', 'incidents'],
        ),
        ApiEndpointConfig(
          id: '${cityId}_open_data',
          name: '$cityName Open Data Portal',
          baseUrl: 'https://data.${cityName.toLowerCase().replaceAll(' ', '')}.gov/api',
          apiType: ApiType.rest,
          authType: AuthType.none,
          rateLimitPerMinute: 200,
          dataTypes: ['public_records', 'statistics'],
        ),
      ]);
    }
    
    _jurisdictionEndpoints[cityId] = endpoints;
  }

  /// Add API endpoints for a county
  void _addCountyEndpoints(String countyName, String stateCode, DataAvailability availability) {
    final countyId = 'county_${countyName.toLowerCase().replaceAll(' ', '_').replaceAll('county', '').trim()}_$stateCode';
    final endpoints = <ApiEndpointConfig>[];
    
    if (availability != DataAvailability.low) {
      endpoints.add(
        ApiEndpointConfig(
          id: '${countyId}_sheriff',
          name: '$countyName Sheriff Department',
          baseUrl: 'https://sheriff.${countyName.toLowerCase().replaceAll(' ', '').replaceAll('county', '')}.${stateCode.toLowerCase()}.gov/api',
          apiType: ApiType.rest,
          authType: AuthType.apiKey,
          rateLimitPerMinute: 60,
          dataTypes: ['officer_records', 'arrests', 'incidents'],
        ),
      );
    }
    
    _jurisdictionEndpoints[countyId] = endpoints;
  }

  /// Find jurisdiction by geographic coordinates
  JurisdictionInfo? findJurisdictionByCoordinates(double latitude, double longitude) {
    // In a real implementation, this would use geographic boundary checking
    // For now, return a placeholder based on rough geographic regions
    
    // This is a simplified implementation - real version would use proper GIS
    if (latitude >= 40.4774 && latitude <= 40.9176 && longitude >= -74.2591 && longitude <= -73.7004) {
      return _jurisdictions['city_new_york_city_NY'];
    } else if (latitude >= 33.7037 && latitude <= 34.3373 && longitude >= -118.6681 && longitude <= -118.1553) {
      return _jurisdictions['city_los_angeles_CA'];
    }
    
    // Fallback to state-level jurisdiction based on rough coordinates
    final stateCode = _getStateCodeFromCoordinates(latitude, longitude);
    return stateCode != null ? _jurisdictions['state_$stateCode'] : null;
  }

  /// Get state code from coordinates (simplified)
  String? _getStateCodeFromCoordinates(double latitude, double longitude) {
    // This is a very simplified implementation
    // Real version would use proper geographic boundary data
    
    if (latitude >= 32.0 && latitude <= 42.0 && longitude >= -124.0 && longitude <= -114.0) {
      return 'CA'; // California (rough bounds)
    } else if (latitude >= 40.0 && latitude <= 45.0 && longitude >= -79.0 && longitude <= -71.0) {
      return 'NY'; // New York (rough bounds)
    } else if (latitude >= 25.0 && latitude <= 31.0 && longitude >= -87.0 && longitude <= -80.0) {
      return 'FL'; // Florida (rough bounds)
    }
    
    return null;
  }

  /// Get all jurisdictions for a state
  List<JurisdictionInfo> getJurisdictionsForState(String stateCode) {
    return _jurisdictions.values
        .where((jurisdiction) => jurisdiction.state == stateCode)
        .toList();
  }

  /// Get API endpoints for a jurisdiction
  List<ApiEndpointConfig> getEndpointsForJurisdiction(String jurisdictionId) {
    return _jurisdictionEndpoints[jurisdictionId] ?? [];
  }

  /// Search jurisdictions by name
  List<JurisdictionInfo> searchJurisdictions(String query) {
    final lowerQuery = query.toLowerCase();
    return _jurisdictions.values
        .where((jurisdiction) => 
            jurisdiction.name.toLowerCase().contains(lowerQuery) ||
            (jurisdiction.city?.toLowerCase().contains(lowerQuery) ?? false) ||
            (jurisdiction.county?.toLowerCase().contains(lowerQuery) ?? false) ||
            (jurisdiction.state?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();
  }

  /// Get jurisdiction by ID
  JurisdictionInfo? getJurisdiction(String id) {
    return _jurisdictions[id];
  }

  /// Get all jurisdictions
  List<JurisdictionInfo> getAllJurisdictions() {
    return _jurisdictions.values.toList();
  }

  /// Get jurisdictions by type
  List<JurisdictionInfo> getJurisdictionsByType(JurisdictionType type) {
    return _jurisdictions.values
        .where((jurisdiction) => jurisdiction.type == type)
        .toList();
  }

  /// Get coverage statistics
  Map<String, dynamic> getCoverageStatistics() {
    final total = _jurisdictions.length;
    final byType = <JurisdictionType, int>{};
    final byAvailability = <DataAvailability, int>{};
    
    for (final jurisdiction in _jurisdictions.values) {
      byType[jurisdiction.type] = (byType[jurisdiction.type] ?? 0) + 1;
      byAvailability[jurisdiction.dataAvailability] = 
          (byAvailability[jurisdiction.dataAvailability] ?? 0) + 1;
    }
    
    return {
      'total_jurisdictions': total,
      'by_type': byType.map((key, value) => MapEntry(key.name, value)),
      'by_availability': byAvailability.map((key, value) => MapEntry(key.name, value)),
      'total_endpoints': _jurisdictionEndpoints.values.fold<int>(
        0, (sum, endpoints) => sum + endpoints.length),
    };
  }
}