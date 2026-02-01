class CommunityRating {
  final String officerId;
  final double averageRating;
  final int totalRatings;
  final Map<String, int> ratingBreakdown;
  final List<String> recentComments;

  CommunityRating({
    required this.officerId,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingBreakdown,
    required this.recentComments,
  });

  factory CommunityRating.fromJson(Map<String, dynamic> json) {
    return CommunityRating(
      officerId: json['officerId'] as String,
      averageRating: (json['averageRating'] as num).toDouble(),
      totalRatings: json['totalRatings'] as int,
      ratingBreakdown: Map<String, int>.from(json['ratingBreakdown'] as Map),
      recentComments: List<String>.from(json['recentComments'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'officerId': officerId,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'ratingBreakdown': ratingBreakdown,
      'recentComments': recentComments,
    };
  }
}