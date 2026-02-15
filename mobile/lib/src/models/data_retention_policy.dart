/// Data retention policy for compliance with privacy regulations
class DataRetentionPolicy {
  final Duration defaultRetentionPeriod;
  final Map<String, Duration> dataTypeRetentionPeriods;
  final bool autoDeleteEnabled;
  final Duration warningPeriodBeforeDeletion;

  const DataRetentionPolicy({
    required this.defaultRetentionPeriod,
    required this.dataTypeRetentionPeriods,
    this.autoDeleteEnabled = true,
    this.warningPeriodBeforeDeletion = const Duration(days: 7),
  });

  /// Default policy for public records (longer retention allowed)
  factory DataRetentionPolicy.publicRecordsDefault() {
    return const DataRetentionPolicy(
      defaultRetentionPeriod: Duration(days: 365 * 2), // 2 years
      dataTypeRetentionPeriods: {
        'officer_public_records': const Duration(days: 365 * 3), // 3 years
        'court_records': const Duration(days: 365 * 5), // 5 years
        'public_complaints': const Duration(days: 365 * 3), // 3 years
        'disciplinary_actions': const Duration(days: 365 * 5), // 5 years
        'search_logs': const Duration(days: 90), // 90 days
        'audit_logs': const Duration(days: 365 * 7), // 7 years (compliance requirement)
      },
      autoDeleteEnabled: true,
      warningPeriodBeforeDeletion: Duration(days: 30),
    );
  }

  /// Strict policy for personal data (shorter retention)
  factory DataRetentionPolicy.personalDataStrict() {
    return const DataRetentionPolicy(
      defaultRetentionPeriod: Duration(days: 30),
      dataTypeRetentionPeriods: {
        'user_searches': const Duration(days: 7),
        'user_preferences': const Duration(days: 90),
        'session_data': const Duration(hours: 24),
        'temporary_cache': const Duration(hours: 1),
      },
      autoDeleteEnabled: true,
      warningPeriodBeforeDeletion: Duration(days: 3),
    );
  }

  /// Get retention period for specific data type
  Duration getRetentionPeriod(String dataType) {
    return dataTypeRetentionPeriods[dataType] ?? defaultRetentionPeriod;
  }

  /// Check if data should be deleted based on age
  bool shouldDelete(String dataType, DateTime createdAt) {
    final retentionPeriod = getRetentionPeriod(dataType);
    final expiryDate = createdAt.add(retentionPeriod);
    return DateTime.now().isAfter(expiryDate);
  }

  /// Check if data is approaching deletion (within warning period)
  bool isApproachingDeletion(String dataType, DateTime createdAt) {
    final retentionPeriod = getRetentionPeriod(dataType);
    final expiryDate = createdAt.add(retentionPeriod);
    final warningDate = expiryDate.subtract(warningPeriodBeforeDeletion);
    final now = DateTime.now();
    return now.isAfter(warningDate) && now.isBefore(expiryDate);
  }

  /// Get days until deletion for specific data
  int getDaysUntilDeletion(String dataType, DateTime createdAt) {
    final retentionPeriod = getRetentionPeriod(dataType);
    final expiryDate = createdAt.add(retentionPeriod);
    final daysUntil = expiryDate.difference(DateTime.now()).inDays;
    return daysUntil.clamp(0, double.infinity).toInt();
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'default_retention_days': defaultRetentionPeriod.inDays,
      'data_type_retention_days': dataTypeRetentionPeriods.map(
        (key, value) => MapEntry(key, value.inDays),
      ),
      'auto_delete_enabled': autoDeleteEnabled,
      'warning_period_days': warningPeriodBeforeDeletion.inDays,
    };
  }

  /// Create from JSON
  factory DataRetentionPolicy.fromJson(Map<String, dynamic> json) {
    final dataTypeRetention = <String, Duration>{};
    final dataTypeMap = json['data_type_retention_days'] as Map<String, dynamic>;
    
    for (final entry in dataTypeMap.entries) {
      dataTypeRetention[entry.key] = Duration(days: entry.value as int);
    }

    return DataRetentionPolicy(
      defaultRetentionPeriod: Duration(days: json['default_retention_days'] as int),
      dataTypeRetentionPeriods: dataTypeRetention,
      autoDeleteEnabled: json['auto_delete_enabled'] as bool? ?? true,
      warningPeriodBeforeDeletion: Duration(days: json['warning_period_days'] as int? ?? 7),
    );
  }

  @override
  String toString() {
    return 'DataRetentionPolicy(default: ${defaultRetentionPeriod.inDays} days, types: ${dataTypeRetentionPeriods.length})';
  }
}