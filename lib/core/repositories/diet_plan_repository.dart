// Diet Plan Repository
// Handles weekly/daily diet plan CRUD operations and AI generation
import 'package:bonyaan_app/core/models/models.dart';
import 'package:bonyaan_app/core/network/api_client.dart';
import 'package:bonyaan_app/core/network/exceptions.dart';

/// Repository for diet plan operations
class DietPlanRepository {
  final ApiClient apiClient;

  DietPlanRepository({required this.apiClient});

  /// Generate a new AI-powered weekly diet plan
  ///
  /// [startDate] - Start date for the plan (ISO format, e.g. "2025-01-20")
  /// [weekNumber] - Week number (defaults to 1)
  /// Returns generated [WeeklyPlan]
  /// Throws [ApiException] on error
  Future<WeeklyPlan> generateWeeklyPlan({
    required String startDate,
    int weekNumber = 1,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/diet-plan/generate-weekly',
        queryParameters: {
          'startDate': startDate,
          'weekNumber': weekNumber.toString(),
        },
      );

      if (response == null) {
        throw ApiErrorException(
          message: 'Empty response from generate weekly plan endpoint',
          statusCode: '500',
        );
      }

      return WeeklyPlan.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse generated weekly plan: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get all weekly diet plans for the authenticated user
  ///
  /// Returns list of [WeeklyPlan]
  /// Throws [UnauthorizedException] if not authenticated
  /// Throws [ApiException] on error
  Future<List<WeeklyPlan>> getWeeklyPlans() async {
    try {
      final response = await apiClient.get('/api/diet-plan/weekly');

      if (response == null) {
        throw ApiErrorException(
          message: 'Empty response from weekly plans endpoint',
          statusCode: '500',
        );
      }

      // Robustly handle both List and Map (with or without 'data' wrapper)
      if (response is List) {
        return response
            .map((item) => WeeklyPlan.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }

      if (response is Map<String, dynamic>) {
        final data = response['data'];

        if (data is List) {
          return data
              .map((item) => WeeklyPlan.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
        } else if (data is Map<String, dynamic>) {
          final plan = WeeklyPlan.fromJson(data);
          if (plan.id != null) return [plan];
        } else if (data == null) {
          // No 'data' key, treat the whole response as the plan object
          final plan = WeeklyPlan.fromJson(response);
          if (plan.id != null) return [plan];
        }
      }
      
      return [];
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse weekly plans: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get today's daily diet plan for the authenticated user
  ///
  /// Returns [DayPlan] for the current day
  /// Throws [NotFoundException] if no plan exists for today
  /// Throws [ApiException] on error
  Future<DayPlan> getTodayPlan() async {
    try {
      final response = await apiClient.get('/api/diet-plan/today');

      if (response == null) {
        throw ApiErrorException(
          message: 'Empty response from today plan endpoint',
          statusCode: '500',
        );
      }
      
      if (response is Map<String, dynamic>) {
        return DayPlan.fromJson(response);
      } else if (response is List) {
        if (response.isEmpty) throw NotFoundException(message: 'No diet plan for today.');
        return DayPlan.fromJson(Map<String, dynamic>.from(response.first as Map));
      }

      throw ParseException(message: 'Unexpected response format for today plan');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse today plan: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get a specific weekly diet plan by ID
  ///
  /// [planId] - ID of the weekly plan
  /// Returns [WeeklyPlan] for the specified ID
  /// Throws [NotFoundException] if plan not found
  /// Throws [ApiException] on error
  Future<WeeklyPlan> getPlanById(int planId) async {
    try {
      final response = await apiClient.get('/api/diet-plan/$planId');

      if (response == null) {
        throw ApiErrorException(
          message: 'Empty response from get plan endpoint',
          statusCode: '500',
        );
      }

      return WeeklyPlan.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse weekly plan: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get a specific daily plan by ID (returns parent weekly context)
  ///
  /// [planId] - ID of the daily plan
  /// Returns [WeeklyPlan] containing the daily plan
  /// Throws [NotFoundException] if plan not found
  /// Throws [ApiException] on error
  Future<WeeklyPlan> getDailyPlanById(int planId) async {
    try {
      final response = await apiClient.get('/api/diet-plan/daily/$planId');

      if (response == null) {
        throw ApiErrorException(
          message: 'Empty response from get daily plan endpoint',
          statusCode: '500',
        );
      }

      return WeeklyPlan.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse daily plan: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Update an existing weekly diet plan
  ///
  /// [planId] - ID of the weekly plan to update
  /// [updatedPlan] - Updated plan data
  /// Returns updated [WeeklyPlan]
  /// Throws [NotFoundException] if plan not found
  /// Throws [ValidationException] if data is invalid
  /// Throws [ApiException] on error
  Future<WeeklyPlan> updatePlan(int planId, WeeklyPlan updatedPlan) async {
    try {
      final response = await apiClient.put(
        '/api/diet-plan/$planId',
        body: updatedPlan.toJson(),
      );

      if (response == null) {
        throw ApiErrorException(
          message: 'Empty response from update plan endpoint',
          statusCode: '500',
        );
      }

      return WeeklyPlan.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse updated plan: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Delete a weekly diet plan
  ///
  /// [planId] - ID of the weekly plan to delete
  /// Returns success message
  /// Throws [NotFoundException] if plan not found
  /// Throws [ApiException] on error
  Future<String> deletePlan(int planId) async {
    try {
      final response = await apiClient.delete('/api/diet-plan/$planId');

      // Handle response - typically returns a string message or Map with message
      if (response is String) {
        return response;
      } else if (response is Map<String, dynamic>) {
        return response['message'] as String? ?? 'Diet plan deleted successfully.';
      }

      return 'Diet plan deleted successfully.';
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiErrorException(
        message: 'Failed to delete diet plan: ${e.toString()}',
        statusCode: 'UNKNOWN',
        originalError: e,
      );
    }
  }
}
