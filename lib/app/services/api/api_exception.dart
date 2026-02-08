/// API Exception
/// Custom exception class for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    required this.statusCode,
    this.errors,
  });

  @override
  String toString() {
    if (errors != null) {
      return 'ApiException: $message (Status: $statusCode)\nErrors: $errors';
    }
    return 'ApiException: $message (Status: $statusCode)';
  }

  /// Check if error is network related
  bool get isNetworkError => statusCode == 0;

  /// Check if error is authentication related
  bool get isAuthError => statusCode == 401;

  /// Check if error is authorization related
  bool get isForbiddenError => statusCode == 403;

  /// Check if error is not found
  bool get isNotFoundError => statusCode == 404;

  /// Check if error is validation related
  bool get isValidationError => statusCode == 422;

  /// Check if error is server related
  bool get isServerError => statusCode >= 500;
}
