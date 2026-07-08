// User Repository
// Handles user profile operations
import 'package:bonyaan_app/core/models/models.dart';
import 'package:bonyaan_app/core/network/api_client.dart';
import 'package:bonyaan_app/core/network/exceptions.dart';

/// Repository for user profile operations
class UserRepository {
  final ApiClient apiClient;

  UserRepository({required this.apiClient});

  /// Get a user profile by ID
  ///
  /// [userId] - User ID to fetch the profile for
  /// Returns [UserProfile] for the specified user
  /// Throws [NotFoundException] if user not found
  /// Throws [ApiException] on error
  Future<UserProfile> getUserProfile(int userId) async {
    try {
      final response = await apiClient.get('/api/user/$userId');

      if (response == null) {
        throw ApiErrorException(
          message: 'Empty response from user profile endpoint',
          statusCode: '500',
        );
      }

      return UserProfile.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse user profile: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
