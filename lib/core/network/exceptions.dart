/// Custom exceptions for API operations

/// Base exception for all API-related errors
abstract class ApiException implements Exception {
  final String message;
  final String? statusCode;
  final dynamic originalError;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Thrown when authentication fails (401 Unauthorized)
class UnauthorizedException extends ApiException {
  UnauthorizedException({
    String message = 'Unauthorized. Please login again.',
    dynamic originalError,
  }) : super(
    message: message,
    statusCode: '401',
    originalError: originalError,
  );
}

/// Thrown when resource is not found (404)
class NotFoundException extends ApiException {
  NotFoundException({
    String message = 'Resource not found.',
    dynamic originalError,
  }) : super(
    message: message,
    statusCode: '404',
    originalError: originalError,
  );
}

/// Thrown when server error occurs (5xx)
class ServerException extends ApiException {
  ServerException({
    String message = 'Server error occurred.',
    String? statusCode,
    dynamic originalError,
  }) : super(
    message: message,
    statusCode: statusCode,
    originalError: originalError,
  );
}

/// Thrown when validation fails (422 or 400 with validation errors)
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException({
    String message = 'Validation failed.',
    this.errors,
    dynamic originalError,
  }) : super(
    message: message,
    statusCode: '422',
    originalError: originalError,
  );
}

/// Thrown when network connection fails
class NetworkException extends ApiException {
  NetworkException({
    String message = 'Network error. Please check your connection.',
    dynamic originalError,
  }) : super(
    message: message,
    statusCode: null,
    originalError: originalError,
  );
}

/// Thrown when response parsing fails
class ParseException extends ApiException {
  ParseException({
    String message = 'Failed to parse server response.',
    dynamic originalError,
  }) : super(
    message: message,
    statusCode: null,
    originalError: originalError,
  );
}

/// Generic API error with status code
class ApiErrorException extends ApiException {
  ApiErrorException({
    required String message,
    required String statusCode,
    dynamic originalError,
  }) : super(
    message: message,
    statusCode: statusCode,
    originalError: originalError,
  );
}
