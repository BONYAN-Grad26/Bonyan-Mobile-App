import 'package:bonyaan_app/core/models/models.dart';
import 'package:bonyaan_app/core/network/api_client.dart';
import 'package:bonyaan_app/core/network/exceptions.dart';

class GoalRepository {
  final ApiClient apiClient;

  GoalRepository({required this.apiClient});

  Future<List<ReadGoalDto>> getMyGoals() async {
    try {
      final response = await apiClient.get('/api/goal/me');

      final jsonMap = response as Map<String, dynamic>;
      final data = jsonMap['data'] as List<dynamic>?;
      if (data == null) return [];

      return data.map((e) => ReadGoalDto.fromJson(e as Map<String, dynamic>)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to parse my goals: ${e.toString()}', originalError: e);
    }
  }

  Future<List<GoalSummaryDto>> getGoalsByUserId(int userId) async {
    try {
      final response = await apiClient.get('/api/goal/user/$userId');

      final jsonMap = response as Map<String, dynamic>;
      final data = jsonMap['data'] as List<dynamic>?;
      if (data == null) return [];

      return data.map((e) => GoalSummaryDto.fromJson(e as Map<String, dynamic>)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to parse user goals: ${e.toString()}', originalError: e);
    }
  }

  Future<ReadGoalDto> addGoal(CreateGoalDto dto) async {
    try {
      final response = await apiClient.post('/api/goal', body: dto.toJson());
      return ReadGoalDto.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to parse added goal: ${e.toString()}', originalError: e);
    }
  }

  Future<ReadGoalDto> updateGoal(int id, UpdateGoalDto dto) async {
    try {
      final response = await apiClient.put('/api/goal/$id', body: dto.toJson());
      return ReadGoalDto.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to parse updated goal: ${e.toString()}', originalError: e);
    }
  }

  Future<String> deleteGoal(int id) async {
    try {
      final response = await apiClient.delete('/api/goal/$id');
      if (response is Map<String, dynamic>) {
        return response['data'] as String? ?? 'Deleted successfully';
      }
      return 'Deleted successfully';
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to delete goal: ${e.toString()}', originalError: e);
    }
  }
}
