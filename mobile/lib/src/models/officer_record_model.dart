class OfficerRecord {
  final String id;
  final String badgeNumber;
  final String name;
  final String department;
  final String rank;
  final int yearsOfService;
  final List<ComplaintRecord> complaints;
  final List<CommendationRecord> commendations;
  final String? imageUrl;
  final DateTime lastUpdated;
  final String dataSource;
  final double reliability;

  OfficerRecord({
    required this.id,
    required this.badgeNumber,
    required this.name,
    required this.department,
    this.rank = '',
    this.yearsOfService = 0,
    this.complaints = const [],
    this.commendations = const [],
    this.imageUrl,
    required this.lastUpdated,
    this.dataSource = 'Unknown',
    this.reliability = 0.5,
  });

  /// Legacy agency getter for backward compatibility
  String get agency => department;

  /// Calculate complaint rate per year
  double get complaintRate {
    if (yearsOfService <= 0) return 0.0;
    return complaints.length / yearsOfService;
  }

  /// Get sustained complaints only
  List<ComplaintRecord> get sustainedComplaints {
    return complaints.where((c) => 
        c.status.toLowerCase().contains('sustained') ||
        c.status.toLowerCase().contains('founded')).toList();
  }

  /// Calculate risk score based on complaint history
  double get riskScore {
    double score = 0.0;
    
    // Base score from complaint rate
    score += complaintRate * 10;
    
    // Higher weight for sustained complaints
    score += sustainedComplaints.length * 5;
    
    // Recent complaints are weighted more heavily
    final recentComplaints = complaints.where((c) => 
        c.date != null && 
        DateTime.now().difference(c.date!).inDays < 365).length;
    score += recentComplaints * 3;
    
    // Commendations reduce risk score
    score -= commendations.length * 2;
    
    return score.clamp(0.0, 100.0);
  }

  factory OfficerRecord.fromJson(Map<String, dynamic> json) {
    return OfficerRecord(
      id: json['id'] as String,
      badgeNumber: json['badgeNumber'] as String,
      name: json['name'] as String,
      department: json['department'] ?? json['agency'] as String,
      rank: json['rank'] as String? ?? '',
      yearsOfService: json['yearsOfService'] as int? ?? 0,
      complaints: (json['complaints'] as List<dynamic>?)
          ?.map((c) => ComplaintRecord.fromJson(c as Map<String, dynamic>))
          .toList() ?? [],
      commendations: (json['commendations'] as List<dynamic>?)
          ?.map((c) => CommendationRecord.fromJson(c as Map<String, dynamic>))
          .toList() ?? [],
      imageUrl: json['imageUrl'] as String?,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      dataSource: json['dataSource'] as String? ?? 'Unknown',
      reliability: (json['reliability'] as num?)?.toDouble() ?? 0.5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'badgeNumber': badgeNumber,
      'name': name,
      'department': department,
      'agency': department, // For backward compatibility
      'rank': rank,
      'yearsOfService': yearsOfService,
      'complaints': complaints.map((c) => c.toJson()).toList(),
      'commendations': commendations.map((c) => c.toJson()).toList(),
      'imageUrl': imageUrl,
      'lastUpdated': lastUpdated.toIso8601String(),
      'dataSource': dataSource,
      'reliability': reliability,
    };
  }

  void validate() {
    if (badgeNumber.isEmpty) {
      throw ArgumentError('Badge number cannot be empty');
    }
    if (name.isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }
    if (department.isEmpty) {
      throw ArgumentError('Department cannot be empty');
    }
    if (reliability < 0.0 || reliability > 1.0) {
      throw ArgumentError('Reliability must be between 0.0 and 1.0');
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OfficerRecord &&
        other.badgeNumber == badgeNumber &&
        other.department == department;
  }

  @override
  int get hashCode => badgeNumber.hashCode ^ department.hashCode;
}

class ComplaintRecord {
  final String id;
  final DateTime? date;
  final String type;
  final String description;
  final String status;
  final String outcome;

  ComplaintRecord({
    required this.id,
    this.date,
    required this.type,
    required this.description,
    required this.status,
    required this.outcome,
  });

  factory ComplaintRecord.fromJson(Map<String, dynamic> json) {
    return ComplaintRecord(
      id: json['id'] as String,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      type: json['type'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      outcome: json['outcome'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date?.toIso8601String(),
      'type': type,
      'description': description,
      'status': status,
      'outcome': outcome,
    };
  }
}

class CommendationRecord {
  final String id;
  final DateTime? date;
  final String type;
  final String description;

  CommendationRecord({
    required this.id,
    this.date,
    required this.type,
    required this.description,
  });

  factory CommendationRecord.fromJson(Map<String, dynamic> json) {
    return CommendationRecord(
      id: json['id'] as String,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      type: json['type'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date?.toIso8601String(),
      'type': type,
      'description': description,
    };
  }
}