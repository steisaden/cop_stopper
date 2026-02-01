import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/rate_limit_info.dart';

/// Rate limiter to prevent API abuse and respect service limits
class RateLimiter {
  final String serviceName;
  final int maxRequestsPerMinute;
  final int maxRequestsPerHour;
  final Duration backoffMultiplier;

  final List<DateTime> _requestTimes = [];
  RateLimitInfo? _currentLimitInfo;
  DateTime? _lastRateLimitHit;
  int _consecutiveRateLimits = 0;

  RateLimiter({
    required this.serviceName,
    this.maxRequestsPerMinute = 60,
    this.maxRequestsPerHour = 1000,
    this.backoffMultiplier = const Duration(seconds: 1),
  });

  /// Wait until a request can be made without violating rate limits
  Future<void> waitForAvailability() async {
    await _cleanupOldRequests();
    
    // Check if we're currently rate limited by the server
    if (_currentLimitInfo?.isLimited == true) {
      final waitTime = _currentLimitInfo!.timeUntilReset;
      if (waitTime > Duration.zero) {
        print('Rate limited by server, waiting ${waitTime.inSeconds}s');
        await Future.delayed(waitTime);
      }
    }

    // Check our local rate limits
    final now = DateTime.now();
    final requestsInLastMinute = _getRequestsInWindow(Duration(minutes: 1));
    final requestsInLastHour = _getRequestsInWindow(Duration(hours: 1));

    Duration? waitTime;

    // Check minute limit
    if (requestsInLastMinute >= maxRequestsPerMinute) {
      final oldestInMinute = _requestTimes
          .where((time) => now.difference(time) <= Duration(minutes: 1))
          .reduce((a, b) => a.isBefore(b) ? a : b);
      waitTime = Duration(minutes: 1) - now.difference(oldestInMinute);
    }

    // Check hour limit
    if (requestsInLastHour >= maxRequestsPerHour) {
      final oldestInHour = _requestTimes
          .where((time) => now.difference(time) <= Duration(hours: 1))
          .reduce((a, b) => a.isBefore(b) ? a : b);
      final hourWait = Duration(hours: 1) - now.difference(oldestInHour);
      waitTime = waitTime == null || hourWait > waitTime ? hourWait : waitTime;
    }

    // Apply exponential backoff if we've hit rate limits recently
    if (_consecutiveRateLimits > 0) {
      final backoffTime = Duration(
        milliseconds: backoffMultiplier.inMilliseconds * 
                     (1 << _consecutiveRateLimits.clamp(0, 10)),
      );
      waitTime = waitTime == null || backoffTime > waitTime ? backoffTime : waitTime;
    }

    if (waitTime != null && waitTime > Duration.zero) {
      print('Local rate limit reached, waiting ${waitTime.inSeconds}s');
      await Future.delayed(waitTime);
    }

    // Record this request
    _requestTimes.add(DateTime.now());
  }

  /// Update rate limit information from API response
  void updateFromResponse(http.Response response) {
    // Update rate limit info from headers
    _currentLimitInfo = RateLimitInfo.fromHeaders(response.headers);

    // Track rate limit hits
    if (response.statusCode == 429) {
      _lastRateLimitHit = DateTime.now();
      _consecutiveRateLimits++;
      print('Rate limit hit for $serviceName (consecutive: $_consecutiveRateLimits)');
    } else {
      // Reset consecutive counter on successful request
      if (_consecutiveRateLimits > 0) {
        print('Rate limit recovered for $serviceName');
        _consecutiveRateLimits = 0;
      }
    }
  }

  /// Get number of requests made in the specified time window
  int _getRequestsInWindow(Duration window) {
    final cutoff = DateTime.now().subtract(window);
    return _requestTimes.where((time) => time.isAfter(cutoff)).length;
  }

  /// Clean up old request timestamps to prevent memory leaks
  Future<void> _cleanupOldRequests() async {
    final cutoff = DateTime.now().subtract(Duration(hours: 2));
    _requestTimes.removeWhere((time) => time.isBefore(cutoff));
  }

  /// Get current rate limit status
  Map<String, dynamic> getStatus() {
    final now = DateTime.now();
    return {
      'service': serviceName,
      'requests_last_minute': _getRequestsInWindow(Duration(minutes: 1)),
      'requests_last_hour': _getRequestsInWindow(Duration(hours: 1)),
      'max_per_minute': maxRequestsPerMinute,
      'max_per_hour': maxRequestsPerHour,
      'consecutive_rate_limits': _consecutiveRateLimits,
      'last_rate_limit': _lastRateLimitHit?.toIso8601String(),
      'server_limit_info': _currentLimitInfo?.toString(),
    };
  }

  /// Reset rate limiter state
  void reset() {
    _requestTimes.clear();
    _currentLimitInfo = null;
    _lastRateLimitHit = null;
    _consecutiveRateLimits = 0;
  }
}

/// Factory for managing rate limiters for different services
class RateLimiterFactory {
  static final Map<String, RateLimiter> _limiters = {};

  static RateLimiter getLimiter(
    String serviceName, {
    int? maxRequestsPerMinute,
    int? maxRequestsPerHour,
  }) {
    return _limiters.putIfAbsent(
      serviceName,
      () => RateLimiter(
        serviceName: serviceName,
        maxRequestsPerMinute: maxRequestsPerMinute ?? 60,
        maxRequestsPerHour: maxRequestsPerHour ?? 1000,
      ),
    );
  }

  /// Get status of all rate limiters
  static Map<String, Map<String, dynamic>> getAllStatus() {
    return Map.fromEntries(
      _limiters.entries.map(
        (entry) => MapEntry(entry.key, entry.value.getStatus()),
      ),
    );
  }

  /// Reset all rate limiters
  static void resetAll() {
    for (final limiter in _limiters.values) {
      limiter.reset();
    }
  }
}