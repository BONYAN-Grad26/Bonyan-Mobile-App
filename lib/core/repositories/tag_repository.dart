import 'package:bonyaan_app/core/models/models.dart';
import 'package:bonyaan_app/core/network/api_client.dart';
import 'package:bonyaan_app/core/network/exceptions.dart';

class TagRepository {
  final ApiClient apiClient;

  TagRepository({required this.apiClient});

  Future<List<DietaryTagDto>> getAllTags({int pageIdx = 1}) async {
    try {
      final response = await apiClient.get('/api/tags', queryParameters: {'pageIdx': pageIdx.toString()});

      final jsonMap = response as Map<String, dynamic>;
      final data = jsonMap['data'] as List<dynamic>?;
      if (data == null) return [];

      return data.map((e) => DietaryTagDto.fromJson(e as Map<String, dynamic>)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse tags: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<ReadDietaryTagDto> getTagById(int id) async {
    try {
      final response = await apiClient.get('/api/tags/$id');
      return ReadDietaryTagDto.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to parse tag: ${e.toString()}', originalError: e);
    }
  }

  Future<ReadDietaryTagDto> createTag(CreateDietaryTagDto dto) async {
    try {
      final response = await apiClient.post('/api/tags', body: dto.toJson());
      return ReadDietaryTagDto.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to parse created tag: ${e.toString()}', originalError: e);
    }
  }

  Future<ReadDietaryTagDto> updateTag(int id, UpdateDietaryTagDto dto) async {
    try {
      final response = await apiClient.put('/api/tags/$id', body: dto.toJson());
      return ReadDietaryTagDto.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to parse updated tag: ${e.toString()}', originalError: e);
    }
  }

  Future<String> deleteTag(int id) async {
    try {
      final response = await apiClient.delete('/api/tags/$id');
      if (response is Map<String, dynamic>) {
        return response['data'] as String? ?? 'Deleted successfully';
      }
      return 'Deleted successfully';
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to delete tag: ${e.toString()}', originalError: e);
    }
  }
}
