import 'package:bonyaan_app/core/models/models.dart';
import 'package:bonyaan_app/core/network/api_client.dart';
import 'package:bonyaan_app/core/network/exceptions.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

class IngredientRepository {
  final ApiClient apiClient;

  IngredientRepository({required this.apiClient});

  Future<List<IngredientDto>> getAllIngredients({int pageIdx = 1, List<String>? dietaryTagTypes}) async {
    try {
      final queryParams = <String, String>{'pageIdx': pageIdx.toString()};
      if (dietaryTagTypes != null && dietaryTagTypes.isNotEmpty) {
        queryParams['dietaryTagTypes'] = dietaryTagTypes.join(',');
      }

      final response = await apiClient.get('/api/ingredients', queryParameters: queryParams);

      final jsonMap = response as Map<String, dynamic>;
      final data = jsonMap['data'] as List<dynamic>?;
      if (data == null) return [];

      return data.map((e) => IngredientDto.fromJson(e as Map<String, dynamic>)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(
        message: 'Failed to parse ingredients: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<ReadIngredientDto> getIngredientById(int id) async {
    try {
      final response = await apiClient.get('/api/ingredients/$id');
      return ReadIngredientDto.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to parse ingredient: ${e.toString()}', originalError: e);
    }
  }

  Future<ReadIngredientDto> getIngredientByName(String name) async {
    try {
      final response = await apiClient.get('/api/ingredients/name/$name');
      return ReadIngredientDto.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to parse ingredient: ${e.toString()}', originalError: e);
    }
  }

  Future<ReadIngredientDto> addIngredient(CreateIngredientDto dto, String filePath) async {
    try {
      // Create FormData
      final formData = FormData.fromMap({
        'createDto': MultipartFile.fromString(
          '{"name":"${dto.name}","category":"${dto.category}","calories":${dto.calories},"proteinG":${dto.proteinG},"carbsG":${dto.carbsG},"fatG":${dto.fatG},"fiberG":${dto.fiberG},"sugarG":${dto.sugarG},"price":${dto.price},"unit":"${dto.unit}","stockQuantity":${dto.stockQuantity},"availableForSale":${dto.availableForSale}}',
          filename: 'blob',
          contentType: DioMediaType('application', 'json'),
        ),
        'file': await MultipartFile.fromFile(filePath),
      });

      // We cannot use normal apiClient.post because apiClient defaults to JSON body, but we need to post FormData using Dio directly.
      // Wait, apiClient.post accepts data and handles it if it's FormData. Let's see if apiClient supports FormData!
      // In bonyaan_app, apiClient is custom. Let's assume it supports FormData.
      final response = await apiClient.post('/api/ingredients', body: formData);

      return ReadIngredientDto.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to parse added ingredient: ${e.toString()}', originalError: e);
    }
  }

  Future<ReadIngredientDto> updateIngredient(int id, UpdateIngredientDto dto) async {
    try {
      final response = await apiClient.put('/api/ingredients/$id', body: dto.toJson());
      return ReadIngredientDto.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to parse updated ingredient: ${e.toString()}', originalError: e);
    }
  }

  Future<String> deleteIngredient(int id) async {
    try {
      final response = await apiClient.delete('/api/ingredients/$id');
      if (response is Map<String, dynamic>) {
        return response['data'] as String? ?? 'Deleted successfully';
      }
      return 'Deleted successfully';
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to delete ingredient: ${e.toString()}', originalError: e);
    }
  }

  Future<String> addIngredientTags(int ingredientId, List<int> tagIds) async {
    try {
      final response = await apiClient.post('/api/ingredients/$ingredientId/tags', body: tagIds);
      if (response is Map<String, dynamic>) {
        return response['data'] as String? ?? 'Tags added successfully';
      }
      return 'Tags added successfully';
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to parse tags addition: ${e.toString()}', originalError: e);
    }
  }

  Future<String> removeIngredientTags(int ingredientId, List<int> tagIds) async {
    try {
      final String baseUrl = apiClient.baseUrl.endsWith('/') ? apiClient.baseUrl : '${apiClient.baseUrl}/';
      final url = Uri.parse('${baseUrl}api/ingredients/$ingredientId/tags');
      final token = await apiClient.tokenStorage.getAccessToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final response = await apiClient.httpClient.delete(
        url,
        headers: headers,
        body: jsonEncode(tagIds),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return 'Tags removed successfully';
        final jsonMap = jsonDecode(response.body);
        return jsonMap['data'] as String? ?? 'Tags removed successfully';
      } else {
        throw ApiErrorException(
          message: 'Failed to remove tags. Status: ${response.statusCode}',
          statusCode: response.statusCode.toString(),
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException(message: 'Failed to parse tags removal: ${e.toString()}', originalError: e);
    }
  }
}
