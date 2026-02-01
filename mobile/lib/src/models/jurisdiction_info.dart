/// Information about a jurisdiction and its data availability
class JurisdictionInfo {
  final String id;
  final String name;
  final JurisdictionType type;
  final String? state;
  final String? county;
  final String? city;
  final List<GeographicBoundary>? boundaries;
  final DataAvailability dataAvailability;
  final DateTime lastUpdated;

  const JurisdictionInfo({
    required this.id,
    required this.name,
    required this.type,
    this.state,
    this.county,
    this.city,
    this.boundaries,
    required this.dataAvailability,
    required this.lastUpdated,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'state': state,
      'county': county,
      'city': city,
      'boundaries': boundaries?.map((b) => b.toJson()).toList(),
      'data_availability': dataAvailability.name,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  /// Create from JSON
  factory JurisdictionInfo.fromJson(Map<String, dynamic> json) {
    return JurisdictionInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      type: JurisdictionType.values.byName(json['type'] as String),
      state: json['state'] as String?,
      county: json['county'] as String?,
      city: json['city'] as String?,
      boundaries: (json['boundaries'] as List<dynamic>?)
          ?.map((b) => GeographicBoundary.fromJson(b as Map<String, dynamic>))
          .toList(),
      dataAvailability: DataAvailability.values.byName(json['data_availability'] as String),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  /// Get full jurisdiction path (e.g., "Los Angeles, CA, USA")
  String get fullPath {
    final parts = <String>[];
    if (city != null) parts.add(city!);
    if (county != null && city == null) parts.add(county!);
    if (state != null) parts.add(state!);
    parts.add('USA');
    return parts.join(', ');
  }

  /// Check if this jurisdiction contains a point
  bool containsPoint(double latitude, double longitude) {
    if (boundaries == null || boundaries!.isEmpty) return false;
    
    // Simple point-in-polygon check for the first boundary
    return boundaries!.first.containsPoint(latitude, longitude);
  }

  @override
  String toString() {
    return 'JurisdictionInfo(id: $id, name: $name, type: $type)';
  }
}

/// Types of jurisdictions
enum JurisdictionType {
  federal,    // Federal agencies (FBI, DEA, etc.)
  state,      // State police, highway patrol
  county,     // Sheriff departments
  city,       // Municipal police departments
  special,    // Special districts (transit, university, etc.)
}

/// Data availability levels
enum DataAvailability {
  high,       // Comprehensive APIs and real-time data
  medium,     // Some APIs, regular updates
  low,        // Limited data, manual requests only
  none,       // No public data available
}

/// Geographic boundary definition
class GeographicBoundary {
  final String type; // 'polygon', 'circle', etc.
  final List<List<double>> coordinates; // [lat, lng] pairs
  final Map<String, dynamic>? properties;

  const GeographicBoundary({
    required this.type,
    required this.coordinates,
    this.properties,
  });

  /// Convert to JSON (GeoJSON format)
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
      if (properties != null) 'properties': properties,
    };
  }

  /// Create from JSON
  factory GeographicBoundary.fromJson(Map<String, dynamic> json) {
    return GeographicBoundary(
      type: json['type'] as String,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((coord) => (coord as List<dynamic>).cast<double>())
          .toList(),
      properties: json['properties'] as Map<String, dynamic>?,
    );
  }

  /// Simple point-in-polygon check (for polygon type)
  bool containsPoint(double latitude, double longitude) {
    if (type != 'polygon' || coordinates.isEmpty) return false;
    
    // Ray casting algorithm for point-in-polygon
    final polygon = coordinates;
    bool inside = false;
    
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i][1]; // longitude
      final yi = polygon[i][0]; // latitude
      final xj = polygon[j][1]; // longitude
      final yj = polygon[j][0]; // latitude
      
      if (((yi > latitude) != (yj > latitude)) &&
          (longitude < (xj - xi) * (latitude - yi) / (yj - yi) + xi)) {
        inside = !inside;
      }
    }
    
    return inside;
  }
}