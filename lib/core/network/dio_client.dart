import 'package:dio/dio.dart';

import '../utils/secure_storage_service.dart';
import 'auth_interceptor.dart';

class DioClient {
  DioClient._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'ttps://phosphate-support-duration.ngrok-free.dev',
      ),
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 90),
      receiveTimeout: const Duration(seconds: 90),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'BonyaanApp/1.0',
        'Bypass-Tunnel-Reminder': 'true',
        'X-Tunnel-Skip-GUI': 'true',
      },
    ),
  );

  static bool _isInitialized = false;

  static Dio get instance {
    if (!_isInitialized) {
      final storage = SecureStorageService();
      _dio.interceptors.add(AuthInterceptor(dio: _dio, secureStorage: storage));

      // THIS IS THE NEW LOGGER
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));

      _isInitialized = true;
    }
    return _dio;
  }
}
