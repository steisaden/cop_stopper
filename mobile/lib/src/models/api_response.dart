/// Generic API response wrapper with error handling
class ApiResponse<T> {
  final T? data;
  final String? error;
  final int? statusCode;
  final bool isSuccess;
  final DateTime timestamp;

  const ApiResponse._({
    this.data,
    this.error,
    this.statusCode,
    required this.isSuccess,
    required this.timestamp,
  });

  /// Create a successful response
  factory ApiResponse.success(T data) {
    return ApiResponse._(
      data: data,
      isSuccess: true,
      timestamp: DateTime.now(),
    );
  }

  /// Create an error response
  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse._(
      error: error,
      statusCode: statusCode,
      isSuccess: false,
      timestamp: DateTime.now(),
    );
  }

  /// Check if the response indicates a rate limit error
  bool get isRateLimited => statusCode == 429;

  /// Check if the response indicates an authentication error
  bool get isAuthError => statusCode == 401 || statusCode == 403;

  /// Check if the response indicates a server error
  bool get isServerError => statusCode != null && statusCode! >= 500;

  @override
  String toString() {
    if (isSuccess) {
      return 'ApiResponse.success(data: $data)';
    } else {
      return 'ApiResponse.error(error: $error, statusCode: $statusCode)';
    }
  }
}