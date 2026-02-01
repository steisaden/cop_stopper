class PrivacySettings {
  final bool anonymizeParticipants;
  final bool restrictToProAccounts;
  final bool audienceAssistEnabled;
  final double? spectatorRadius; // in miles
  final int? maxSpectators;
  final bool allowRecordingAccess;
  final bool requireApprovalForSpectators;

  const PrivacySettings({
    required this.anonymizeParticipants,
    required this.restrictToProAccounts,
    this.audienceAssistEnabled = false,
    this.spectatorRadius,
    this.maxSpectators,
    this.allowRecordingAccess = false,
    this.requireApprovalForSpectators = true,
  });

  factory PrivacySettings.defaultSettings() {
    return const PrivacySettings(
      anonymizeParticipants: true,
      restrictToProAccounts: true,
      audienceAssistEnabled: false,
      spectatorRadius: 5.0,
      maxSpectators: 50,
      allowRecordingAccess: false,
      requireApprovalForSpectators: true,
    );
  }

  factory PrivacySettings.privateGroupOnly() {
    return const PrivacySettings(
      anonymizeParticipants: false,
      restrictToProAccounts: true,
      audienceAssistEnabled: false,
      allowRecordingAccess: true,
      requireApprovalForSpectators: false,
    );
  }

  factory PrivacySettings.publicSpectator() {
    return const PrivacySettings(
      anonymizeParticipants: true,
      restrictToProAccounts: true,
      audienceAssistEnabled: true,
      spectatorRadius: 10.0,
      maxSpectators: 100,
      allowRecordingAccess: false,
      requireApprovalForSpectators: false,
    );
  }

  PrivacySettings copyWith({
    bool? anonymizeParticipants,
    bool? restrictToProAccounts,
    bool? audienceAssistEnabled,
    double? spectatorRadius,
    int? maxSpectators,
    bool? allowRecordingAccess,
    bool? requireApprovalForSpectators,
  }) {
    return PrivacySettings(
      anonymizeParticipants: anonymizeParticipants ?? this.anonymizeParticipants,
      restrictToProAccounts: restrictToProAccounts ?? this.restrictToProAccounts,
      audienceAssistEnabled: audienceAssistEnabled ?? this.audienceAssistEnabled,
      spectatorRadius: spectatorRadius ?? this.spectatorRadius,
      maxSpectators: maxSpectators ?? this.maxSpectators,
      allowRecordingAccess: allowRecordingAccess ?? this.allowRecordingAccess,
      requireApprovalForSpectators: requireApprovalForSpectators ?? this.requireApprovalForSpectators,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'anonymizeParticipants': anonymizeParticipants,
      'restrictToProAccounts': restrictToProAccounts,
      'audienceAssistEnabled': audienceAssistEnabled,
      'spectatorRadius': spectatorRadius,
      'maxSpectators': maxSpectators,
      'allowRecordingAccess': allowRecordingAccess,
      'requireApprovalForSpectators': requireApprovalForSpectators,
    };
  }

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      anonymizeParticipants: json['anonymizeParticipants'] as bool? ?? true,
      restrictToProAccounts: json['restrictToProAccounts'] as bool? ?? true,
      audienceAssistEnabled: json['audienceAssistEnabled'] as bool? ?? false,
      spectatorRadius: json['spectatorRadius'] as double?,
      maxSpectators: json['maxSpectators'] as int?,
      allowRecordingAccess: json['allowRecordingAccess'] as bool? ?? false,
      requireApprovalForSpectators: json['requireApprovalForSpectators'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrivacySettings &&
        other.anonymizeParticipants == anonymizeParticipants &&
        other.restrictToProAccounts == restrictToProAccounts &&
        other.audienceAssistEnabled == audienceAssistEnabled &&
        other.spectatorRadius == spectatorRadius &&
        other.maxSpectators == maxSpectators &&
        other.allowRecordingAccess == allowRecordingAccess &&
        other.requireApprovalForSpectators == requireApprovalForSpectators;
  }

  @override
  int get hashCode {
    return Object.hash(
      anonymizeParticipants,
      restrictToProAccounts,
      audienceAssistEnabled,
      spectatorRadius,
      maxSpectators,
      allowRecordingAccess,
      requireApprovalForSpectators,
    );
  }

  @override
  String toString() {
    return 'PrivacySettings(audienceAssist: $audienceAssistEnabled, radius: $spectatorRadius, maxSpectators: $maxSpectators)';
  }
}
