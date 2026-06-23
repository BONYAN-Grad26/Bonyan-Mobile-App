/// Workout Plan Repository
/// Handles workout plan CRUD operations and AI generation
import 'package:bonyaan_app/core/models/models.dart';
import 'package:bonyaan_app/core/network/api_client.dart';
import 'package:bonyaan_app/core/network/exceptions.dart';

/// Repository for workout plan operations
class WorkoutRepository {
  final ApiClient apiClient;

  WorkoutRepository({required this.apiClient});

  /// Generate a new AI-powered weekly workout plan
  ///
  /// Returns generated [WorkoutPlan]
  /// Throws [ApiException] on error
  Future<WorkoutPlan> generateWeeklyPlan() async {
    try {
      final response = await apiClient.post('/workout-plan/generate-weekly');

      if (response == null) {
        throw ApiErrorException(
          message: 'Empty response from generate workout plan endpoint',
          statusCode: '500',
        );
      }

      return WorkoutPlan.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e, stackTrace) {
      print('================ JSON PARSING ERROR ================');
      print(e);
      print(stackTrace);
      print('===================================================');
      throw ParseException(
        message: 'Failed to parse generated workout plan: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get a specific workout plan by ID
  ///
  /// [id] - Workout plan ID
  /// Returns [WorkoutPlan] for the specified ID
  /// Throws [NotFoundException] if plan not found
  /// Throws [ApiException] on error
  Future<WorkoutPlan> getById(int id) async {
    try {
      final response = await apiClient.get('/workout-plan/$id');

      if (response == null) {
        throw ApiErrorException(
          message: 'Empty response from get workout plan endpoint',
          statusCode: '500',
        );
      }

      return WorkoutPlan.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse workout plan: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get all workout plans for a specific user
  ///
  /// [userId] - User ID to fetch workout plans for
  /// Returns list of [WorkoutPlan]
  /// Throws [NotFoundException] if user not found
  /// Throws [ApiException] on error
  Future<List<WorkoutPlan>> getUserWorkouts(int userId) async {
    try {
      final response = await apiClient.get('/workout-plan/user/$userId');

      if (response == null) {
        throw ApiErrorException(
          message: 'Empty response from user workouts endpoint',
          statusCode: '500',
        );
      }

      final jsonMap = response as Map<String, dynamic>;
      final data = jsonMap['data'] ?? jsonMap;

      if (data is List) {
        return data
            .map((item) => WorkoutPlan.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic>) {
        return [WorkoutPlan.fromJson(data)];
      }

      return [];
    } on ApiException catch (e) {
      print('🔥 WORKOUT FETCH ERROR: $e');
      rethrow;
    } catch (e, stackTrace) {
      print('🔥 WORKOUT FETCH ERROR: $e');
      print('🔥 STACK: $stackTrace');
      throw ParseException(
        message: 'Failed to parse user workouts: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get the current workout plan for the authenticated user
  ///
  /// Returns [WorkoutPlan] for the current user
  /// Throws [ApiException] on error
  Future<WorkoutPlan> getMyWorkout() async {
    try {
      final response = await apiClient.get('/workout-plan/user/me');

      if (response == null) {
        throw ApiErrorException(
          message: 'Empty response from getMyWorkout endpoint',
          statusCode: '500',
        );
      }

      final jsonMap = response as Map<String, dynamic>;
      final data = jsonMap['data'] ?? jsonMap;
      
      print('🔥 RAW WORKOUT JSON: $data');
      return WorkoutPlan.fromJson(data as Map<String, dynamic>);
    } on ApiException catch (e) {
      print('🔥 WORKOUT FETCH ERROR: $e');
      rethrow;
    } catch (e, stackTrace) {
      print('🔥 WORKOUT FETCH ERROR: $e');
      print('🔥 STACK: $stackTrace');
      throw ParseException(
        message: 'Failed to parse my workout: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get today's workout for the authenticated user
  ///
  /// Returns [TodayWorkout] for the current day
  /// Throws [NotFoundException] if no workout exists for today
  /// Throws [ApiException] on error
  Future<TodayWorkout> getTodayWorkout() async {
    try {
      final response = await apiClient.get('/workout-plan/today');

      if (response == null) {
        throw ApiErrorException(
          message: 'Empty response from today workout endpoint',
          statusCode: '500',
        );
      }

      return TodayWorkout.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse today workout: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Delete a workout plan
  ///
  /// [id] - Workout plan ID to delete
  /// Returns success message
  /// Throws [NotFoundException] if plan not found
  /// Throws [ApiException] on error
  Future<String> deleteWorkout(int id) async {
    try {
      final response = await apiClient.delete('/workout-plan/$id');

      // Handle response - typically returns a string message or Map with message
      if (response is String) {
        return response;
      } else if (response is Map<String, dynamic>) {
        return response['message'] as String? ?? 'Workout plan deleted successfully.';
      }

      return 'Workout plan deleted successfully.';
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiErrorException(
        message: 'Failed to delete workout plan: ${e.toString()}',
        statusCode: 'UNKNOWN',
        originalError: e,
      );
    }
  }
}
