import 'package:bonyaan_app/core/models/models.dart';
import 'package:bonyaan_app/core/network/api_client.dart';
import 'package:bonyaan_app/core/network/exceptions.dart';

class AllergyRepository {
  final ApiClient apiClient;

  AllergyRepository({required this.apiClient});

  Future<ReadAllergyDto> getAllergyById(int id) async {
    try {
      final response = await apiClient.get('/api/allergy/$id');
      return ReadAllergyDto.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to parse allergy: ${e.toString()}', originalError: e);
    }
  }

  Future<List<ReadAllergyDto>> getAllergiesByUserId(int userId) async {
    try {
      final response = await apiClient.get('/api/allergy/user/$userId');

      final jsonMap = response as Map<String, dynamic>;
      final data = jsonMap['data'] as List<dynamic>?;
      if (data == null) return [];

      return data.map((e) => ReadAllergyDto.fromJson(e as Map<String, dynamic>)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to parse user allergies: ${e.toString()}', originalError: e);
    }
  }

  Future<List<ReadAllergyDto>> getMyAllergies() async {
    try {
      final response = await apiClient.get('/api/allergy/me');

      final jsonMap = response as Map<String, dynamic>;
      final data = jsonMap['data'] as List<dynamic>?;
      if (data == null) return [];

      return data.map((e) => ReadAllergyDto.fromJson(e as Map<String, dynamic>)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to parse my allergies: ${e.toString()}', originalError: e);
    }
  }

  Future<ReadAllergyDto> addAllergy(CreateAllergyDto dto) async {
    try {
      final response = await apiClient.post('/api/allergy', body: dto.toJson());
      return ReadAllergyDto.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to parse added allergy: ${e.toString()}', originalError: e);
    }
  }

  Future<ReadAllergyDto> updateAllergy(int id, UpdateAllergyDto dto) async {
    try {
      final response = await apiClient.put('/api/allergy/$id', body: dto.toJson());
      return ReadAllergyDto.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to parse updated allergy: ${e.toString()}', originalError: e);
    }
  }

  Future<String> deleteAllergy(int id) async {
    try {
      final response = await apiClient.delete('/api/allergy/$id');
      if (response is Map<String, dynamic>) {
        return response['data'] as String? ?? 'Deleted successfully';
      }
      return 'Deleted successfully';
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to delete allergy: ${e.toString()}', originalError: e);
    }
  }
}
