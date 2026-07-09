// Health Profile Repository
// Handles health metrics CRUD operations
import 'package:bonyaan_app/core/models/models.dart';
import 'package:bonyaan_app/core/network/api_client.dart';
import 'package:bonyaan_app/core/network/exceptions.dart';

/// Repository for health profile and metrics operations
class HealthProfileRepository {
  final ApiClient apiClient;

  HealthProfileRepository({required this.apiClient});

  /// Get current user's health profile and metrics
  /// 
  /// Returns [HealthMetrics] for authenticated user
  /// Throws [UnauthorizedException] if not authenticated
  /// Throws [ApiException] on error
  Future<HealthMetrics> getMyHealthProfile() async {
    try {
      final response = await apiClient.get('/api/health-profile/me');

      if (response == null) {
        throw ApiErrorException(
          message: 'Empty response from health profile endpoint',
          statusCode: '500',
        );
      }

      if (response is Map<String, dynamic>) {
        return HealthMetrics.fromJson(response);
      } else if (response is List) {
        if (response.isEmpty) throw NotFoundException(message: 'Health profile not found');
        return HealthMetrics.fromJson(Map<String, dynamic>.from(response.first as Map));
      }

      throw ParseException(message: 'Unexpected response format for health profile');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse health profile: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get health profile by ID
  /// 
  /// [id] - Health profile ID
  /// Returns [HealthMetrics] for specified ID
  /// Throws [NotFoundException] if profile not found
  /// Throws [ApiException] on error
  Future<HealthMetrics> getHealthProfileById(int id) async {
    try {
      final response = await apiClient.get('/api/health-profile/$id');

      if (response == null) {
        throw ApiErrorException(
          message: 'Empty response from health profile endpoint',
          statusCode: '500',
        );
      }

      return HealthMetrics.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse health profile: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Create a new health profile for authenticated user
  /// 
  /// [metrics] - Health metrics to create
  /// Returns newly created [HealthMetrics]
  /// Throws [ValidationException] if data is invalid
  /// Throws [ApiException] on error
  Future<HealthMetrics> createHealthProfile(HealthMetrics metrics) async {
    try {
      final response = await apiClient.post(
        '/api/health-profile',
        body: metrics.toJson(),
      );

      if (response == null) {
        throw ApiErrorException(
          message: 'Empty response from create health profile endpoint',
          statusCode: '500',
        );
      }

      return HealthMetrics.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse created health profile: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Update existing health profile
  /// 
  /// [id] - Health profile ID
  /// [metrics] - Updated metrics
  /// Returns updated [HealthMetrics]
  /// Throws [NotFoundException] if profile not found
  /// Throws [ValidationException] if data is invalid
  /// Throws [ApiException] on error
  Future<HealthMetrics> updateHealthProfile(int id, HealthMetrics metrics) async {
    try {
      final response = await apiClient.put(
        '/api/health-profile/$id',
        body: metrics.toJson(),
      );

      if (response == null) {
        throw ApiErrorException(
          message: 'Empty response from update health profile endpoint',
          statusCode: '500',
        );
      }

      return HealthMetrics.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse updated health profile: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Delete health profile
  /// 
  /// [id] - Health profile ID
  /// Returns success message
  /// Throws [NotFoundException] if profile not found
  /// Throws [ApiException] on error
  Future<String> deleteHealthProfile(int id) async {
    try {
      final response = await apiClient.delete('/api/health-profile/$id');

      // Handle response - typically returns a string message or Map with message
      if (response is String) {
        return response;
      } else if (response is Map<String, dynamic>) {
        return response['message'] as String? ?? 'Health profile deleted successfully.';
      }

      return 'Health profile deleted successfully.';
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiErrorException(
        message: 'Failed to delete health profile: ${e.toString()}',
        statusCode: 'UNKNOWN',
        originalError: e,
      );
    }
  }

  /// Calculate metrics from basic health data
  /// 
  /// This is a helper method that uses the backend's calculated fields
  /// Returns [HealthMetrics] with all calculated values (bmi, tdee, etc.)
  HealthMetrics calculateMetrics(HealthMetrics base) {
    // This method demonstrates how to work with calculated fields
    // In practice, these are calculated by the backend
    return base;
  }

  /// Check if user has completed health profile setup
  /// 
  /// Returns true if profile exists and has critical data
  Future<bool> hasCompletedHealthSetup() async {
    try {
      final profile = await getMyHealthProfile();
      return profile.age != null &&
          profile.weightKg != null &&
          profile.heightCm != null &&
          profile.gender != null &&
          profile.dietGoal != null;
    } on UnauthorizedException {
      return false;
    } on NotFoundException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
