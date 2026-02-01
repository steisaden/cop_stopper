/// Rate limiting information for API clients
class RateLimitInfo {
  final int limit;
  final int remaining;
  final DateTime resetTime;
  final Duration retryAfter;

  const RateLimitInfo({
    required this.limit,
    required this.remaining,
    required this.resetTime,
    required this.retryAfter,
  });

  /// Create from HTTP response headers
  factory RateLimitInfo.fromHeaders(Map<String, String> headers) {
    final limit = int.tryParse(headers['x-ratelimit-limit'] ?? '0') ?? 0;
    final remaining = int.tryParse(headers['x-ratelimit-remaining'] ?? '0') ?? 0;
    final resetTimestamp = int.tryParse(headers['x-ratelimit-reset'] ?? '0') ?? 0;
    final retryAfterSeconds = int.tryParse(headers['retry-after'] ?? '0') ?? 0;

    return RateLimitInfo(
      limit: limit,
      remaining: remaining,
      resetTime: DateTime.fromMillisecondsSinceEpoch(resetTimestamp * 1000),
      retryAfter: Duration(seconds: retryAfterSeconds),
    );
  }

  /// Check if we're currently rate limited
  bool get isLimited => remaining <= 0 && DateTime.now().isBefore(resetTime);

  /// Get time until rate limit resets
  Duration get timeUntilReset {
    final now = DateTime.now();
    return resetTime.isAfter(now) ? resetTime.difference(now) : Duration.zero;
  }

  @override
  String toString() {
    return 'RateLimitInfo(limit: $limit, remaining: $remaining, resetTime: $resetTime)';
  }
}