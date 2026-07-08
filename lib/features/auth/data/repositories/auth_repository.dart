import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  AuthRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return _extractUser(response.data);
    } on DioException catch (e) {
      throw Exception(_mapDioError(e));
    }
  }

  Future<UserModel?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        },
      );

      return _extractUser(response.data);
    } on DioException catch (e) {
      throw Exception(_mapDioError(e));
    }
  }

  Future<void> confirmEmail({
    required String email,
    required String otp,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/api/auth/confirm-email',
        data: {
          'email': email,
          'otp': otp,
        },
      );
    } on DioException catch (e) {
      throw Exception(_mapDioError(e));
    }
  }

  UserModel? _extractUser(Map<String, dynamic>? data) {
    if (data == null) {
      return null;
    }

    final nestedUser = data['user'];
    if (nestedUser is Map<String, dynamic>) {
      return UserModel.fromJson(nestedUser);
    }

    final hasTopLevelFields =
        data.containsKey('email') || data.containsKey('firstName') || data.containsKey('lastName');

    if (hasTopLevelFields) {
      return UserModel.fromJson(data);
    }

    return null;
  }

  String _mapDioError(DioException error) {
    final data = error.response?.data;
    final url = error.requestOptions.path;
    final statusCode = error.response?.statusCode;

    if (statusCode == 404) {
      return 'Endpoint not found (404): $url. Please check your backend URL and paths.';
    }

    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'] ?? data['details'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    if (error.message != null && error.message!.trim().isNotEmpty) {
      return error.message!;
    }

    return 'Authentication request failed. Please try again.';
  }
}
