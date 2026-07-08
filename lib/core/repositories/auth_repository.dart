// Authentication Repository
// Handles user authentication (login, register, email confirmation)
import 'package:bonyaan_app/core/models/models.dart';
import 'package:bonyaan_app/core/network/api_client.dart';
import 'package:bonyaan_app/core/network/exceptions.dart';

/// Repository for authentication operations
class AuthRepository {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

  /// Register a new user account
  /// 
  /// [request] - Registration details (firstName, lastName, email, password)
  /// Returns success message if registration successful
  /// Throws [ApiException] on error
  Future<String> register(RegisterRequest request) async {
    try {
      final response = await apiClient.post(
        '/api/auth/register',
        body: request.toJson(),
      );

      // Handle response - typically returns a string message or Map with message
      if (response is String) {
        return response;
      } else if (response is Map<String, dynamic>) {
        return response['message'] as String? ?? 'Registration successful. Please check your email.';
      }

      return 'Registration successful. Please check your email.';
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiErrorException(
        message: 'Registration failed: ${e.toString()}',
        statusCode: 'UNKNOWN',
        originalError: e,
      );
    }
  }

  /// Authenticate user with email and password
  /// 
  /// [request] - Login credentials (email, password)
  /// Returns [AuthResponse] with access token
  /// Throws [UnauthorizedException] if credentials are invalid
  /// Throws [ApiException] on other errors
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await apiClient.post(
        '/api/auth/login',
        body: request.toJson(),
      );

      if (response == null) {
        throw ApiErrorException(
          message: 'Empty response from login endpoint',
          statusCode: '500',
        );
      }

      final authResponse = AuthResponse.fromJson(response as Map<String, dynamic>);

      // Store the token for future requests
      await apiClient.setAccessToken(authResponse.accessToken);

      return authResponse;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse login response: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Confirm user email with OTP code
  /// 
  /// [request] - Email confirmation details (email, otp)
  /// Returns [AuthResponse] with access token upon successful confirmation
  /// Throws [UnauthorizedException] if OTP is invalid
  /// Throws [ApiException] on other errors
  Future<AuthResponse> confirmEmail(ConfirmEmailRequest request) async {
    try {
      final response = await apiClient.post(
        '/api/auth/confirm-email',
        body: request.toJson(),
      );

      if (response == null) {
        throw ApiErrorException(
          message: 'Empty response from email confirmation endpoint',
          statusCode: '500',
        );
      }

      final authResponse = AuthResponse.fromJson(response as Map<String, dynamic>);

      // Store the token for future requests
      await apiClient.setAccessToken(authResponse.accessToken);

      return authResponse;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse email confirmation response: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Request a new OTP code to be sent to email
  /// 
  /// [email] - Email address to send OTP to
  /// Returns success message
  /// Throws [ApiException] on error
  Future<String> resendOtp(String email) async {
    try {
      final response = await apiClient.post(
        '/api/auth/resend-otp',
        body: {'email': email},
      );

      // Handle response
      if (response is String) {
        return response;
      } else if (response is Map<String, dynamic>) {
        return response['message'] as String? ?? 'OTP sent successfully. Check your email.';
      }

      return 'OTP sent successfully. Check your email.';
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiErrorException(
        message: 'Failed to resend OTP: ${e.toString()}',
        statusCode: 'UNKNOWN',
        originalError: e,
      );
    }
  }

  /// Logout current user by clearing stored token
  /// 
  /// This is a local operation - no API call
  Future<void> logout() async {
    try {
      await apiClient.clearAccessToken();
    } catch (e) {
      throw ApiErrorException(
        message: 'Failed to logout: ${e.toString()}',
        statusCode: 'UNKNOWN',
        originalError: e,
      );
    }
  }

  /// Get currently stored access token
  /// 
  /// Returns the stored JWT token, or null if not authenticated
  Future<String?> getAccessToken() async {
    return apiClient.getAccessToken();
  }

  /// Check if user is currently authenticated
  /// 
  /// Returns true if a valid token is stored, false otherwise
  Future<bool> isAuthenticated() async {
    final token = await apiClient.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
