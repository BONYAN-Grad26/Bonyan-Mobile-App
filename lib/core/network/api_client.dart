/// Core HTTP API Client with JWT token management and error handling
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'exceptions.dart';

/// Abstract class for token storage - implementations can use SharedPreferences or SecureStorage
abstract class TokenStorage {
  Future<String?> getAccessToken();
  Future<void> saveAccessToken(String token);
  Future<void> clearAccessToken();
}

/// Core HTTP client that wraps the `http` package
/// Automatically injects JWT Bearer tokens and handles standard API errors
class ApiClient {
  final String baseUrl;
  final TokenStorage tokenStorage;
  final http.Client httpClient;
  final Duration timeout;
  final void Function()? onUnauthorized;

  /// Constructor
  /// [baseUrl] - Base URL for API (e.g., http://192.168.1.100:8080)
  /// [tokenStorage] - Implementation for storing/retrieving JWT tokens
  /// [httpClient] - HTTP client (default: http.Client())
  /// [timeout] - Request timeout duration (default: 30 seconds)
  ApiClient({
    required this.baseUrl,
    required this.tokenStorage,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 90),
    this.onUnauthorized,
  }) : httpClient = httpClient ?? http.Client();

  /// Constructs full URL from endpoint
  String _buildUrl(String endpoint) {
    final cleanBase = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return '$cleanBase$cleanEndpoint';
  }

  /// Gets authorization headers with JWT token
  Future<Map<String, String>> _getHeaders({Map<String, String>? additionalHeaders}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    print('--- ApiClient Request Headers ---');
    print('Authorization: ${headers['Authorization'] ?? 'NONE'}');
    print('---------------------------------');

    return headers;
  }

  /// Handles HTTP response and throws appropriate exceptions
  dynamic _handleResponse(http.Response response) {
    try {
      final statusCode = response.statusCode;

      print('--- ApiClient Response ---');
      print('URL: ${response.request?.url}');
      print('Status Code: $statusCode');
      print('--------------------------');

      // Success response
      if (statusCode >= 200 && statusCode < 300) {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      }

      // Unauthorized - clear token and redirect to login
      if (statusCode == 401) {
        tokenStorage.clearAccessToken();
        onUnauthorized?.call();
        throw UnauthorizedException();
      }

      // Not found
      if (statusCode == 404) {
        throw NotFoundException(
          message: 'Resource not found.',
          originalError: response.body,
        );
      }

      // Validation error
      if (statusCode == 422 || statusCode == 400) {
        var errorData = <String, dynamic>{};
        try {
          errorData = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {}

        throw ValidationException(
          message: errorData['message'] as String? ?? 'Validation failed.',
          errors: errorData['errors'] as Map<String, dynamic>?,
          originalError: response.body,
        );
      }

      // Server error
      if (statusCode >= 500) {
        throw ServerException(
          message: 'Server error occurred.',
          statusCode: statusCode.toString(),
          originalError: response.body,
        );
      }

      // Other errors
      throw ApiErrorException(
        message: 'Unexpected error occurred.',
        statusCode: statusCode.toString(),
        originalError: response.body,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse server response.',
        originalError: e,
      );
    }
  }

  /// Performs GET request
  /// Returns parsed JSON response
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final url = Uri.parse(_buildUrl(endpoint)).replace(queryParameters: queryParameters);
      final headers = await _getHeaders(additionalHeaders: additionalHeaders);

      final response = await httpClient
          .get(url, headers: headers)
          .timeout(timeout, onTimeout: () => throw TimeoutException('Request timeout'));

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      throw NetworkException(originalError: e);
    } on TimeoutException catch (e) {
      throw NetworkException(
        message: 'Request timeout. Please check your connection.',
        originalError: e,
      );
    } catch (e) {
      throw NetworkException(originalError: e);
    }
  }

  /// Performs POST request
  /// [endpoint] - API endpoint path
  /// [body] - Request body (will be JSON encoded)
  /// Returns parsed JSON response
  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParameters,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final url = Uri.parse(_buildUrl(endpoint)).replace(queryParameters: queryParameters);
      final headers = await _getHeaders(additionalHeaders: additionalHeaders);

      String? bodyString;
      if (body != null) {
        if (body is String) {
          bodyString = body;
        } else {
          bodyString = jsonEncode(body);
        }
      }

      final response = await httpClient
          .post(url, headers: headers, body: bodyString)
          .timeout(timeout, onTimeout: () => throw TimeoutException('Request timeout'));

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      throw NetworkException(originalError: e);
    } on TimeoutException catch (e) {
      throw NetworkException(
        message: 'Request timeout. Please check your connection.',
        originalError: e,
      );
    } catch (e) {
      throw NetworkException(originalError: e);
    }
  }

  /// Performs PUT request
  /// [endpoint] - API endpoint path
  /// [body] - Request body (will be JSON encoded)
  /// Returns parsed JSON response
  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParameters,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final url = Uri.parse(_buildUrl(endpoint)).replace(queryParameters: queryParameters);
      final headers = await _getHeaders(additionalHeaders: additionalHeaders);

      String? bodyString;
      if (body != null) {
        if (body is String) {
          bodyString = body;
        } else {
          bodyString = jsonEncode(body);
        }
      }

      final response = await httpClient
          .put(url, headers: headers, body: bodyString)
          .timeout(timeout, onTimeout: () => throw TimeoutException('Request timeout'));

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      throw NetworkException(originalError: e);
    } on TimeoutException catch (e) {
      throw NetworkException(
        message: 'Request timeout. Please check your connection.',
        originalError: e,
      );
    } catch (e) {
      throw NetworkException(originalError: e);
    }
  }

  /// Performs DELETE request
  /// [endpoint] - API endpoint path
  /// Returns parsed JSON response
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final url = Uri.parse(_buildUrl(endpoint)).replace(queryParameters: queryParameters);
      final headers = await _getHeaders(additionalHeaders: additionalHeaders);

      final response = await httpClient
          .delete(url, headers: headers)
          .timeout(timeout, onTimeout: () => throw TimeoutException('Request timeout'));

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      throw NetworkException(originalError: e);
    } on TimeoutException catch (e) {
      throw NetworkException(
        message: 'Request timeout. Please check your connection.',
        originalError: e,
      );
    } catch (e) {
      throw NetworkException(originalError: e);
    }
  }

  /// Saves access token for subsequent requests
  Future<void> setAccessToken(String token) async {
    await tokenStorage.saveAccessToken(token);
  }

  /// Clears stored access token (e.g., on logout)
  Future<void> clearAccessToken() async {
    await tokenStorage.clearAccessToken();
  }

  /// Gets currently stored access token
  Future<String?> getAccessToken() async {
    return tokenStorage.getAccessToken();
  }
}
