import 'dart:async';

import 'package:dio/dio.dart';

import '../utils/secure_storage_service.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({required Dio dio, required SecureStorageService secureStorage})
      : _dio = dio,
        _secureStorage = secureStorage,
        _refreshDio = Dio(
          BaseOptions(
            baseUrl: dio.options.baseUrl,
            connectTimeout: dio.options.connectTimeout,
            sendTimeout: dio.options.sendTimeout,
            receiveTimeout: dio.options.receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

  final Dio _dio;
  final Dio _refreshDio;
  final SecureStorageService _secureStorage;

  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isRefreshing && !_isAuthPath(options.path)) {
      await _refreshCompleter?.future;
    }

    if (_isAuthPath(options.path)) {
      handler.next(options);
      return;
    }

    final accessToken = await _secureStorage.readAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final path = _normalizedPath(response.requestOptions.path);

    if (path == '/api/auth/login' || path == '/api/auth/refresh-token') {
      await _persistTokensFromResponse(response);
    }

    handler.next(response);
  }

  @override
  Future<void> onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    if (!_shouldRefresh(err)) {
      handler.next(err);
      return;
    }

    try {
      if (_isRefreshing) {
        await _refreshCompleter?.future;
      } else {
        _isRefreshing = true;
        _refreshCompleter = Completer<void>();

        // THIS IS THE NEW LINE THAT PREVENTS THE CRASH
        _refreshCompleter?.future.catchError((_) {});

        await _refreshTokens();

        _refreshCompleter?.complete();
        _isRefreshing = false;
      }

      final retryResponse = await _retryRequest(err.requestOptions);
      handler.resolve(retryResponse);
    } catch (refreshError) {
      if (_refreshCompleter != null && !(_refreshCompleter?.isCompleted ?? true)) {
        _refreshCompleter?.completeError(refreshError);
      }
      _isRefreshing = false;

      await _secureStorage.clearTokens();
      handler.next(err);
    }
  }

  bool _shouldRefresh(DioException err) {
    final statusCode = err.response?.statusCode;
    if (statusCode != 401) {
      return false;
    }

    final path = _normalizedPath(err.requestOptions.path);
    if (path.startsWith('/api/auth/refresh-token')) {
      return false;
    }

    final alreadyRetried = err.requestOptions.extra['retried'] == true;
    return !alreadyRetried;
  }

  Future<void> _refreshTokens() async {
    final refreshToken = await _secureStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw StateError('No refresh token available in secure storage.');
    }

    final response = await _refreshDio.post<dynamic>(
      '/api/auth/refresh-token',
      options: Options(
        headers: {
          'Cookie': 'refreshToken=$refreshToken',
        },
      ),
    );

    await _persistTokensFromResponse(response);

    final accessToken = await _secureStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw StateError('Refresh endpoint did not return a valid access token.');
    }
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final accessToken = await _secureStorage.readAccessToken();
    final headers = Map<String, dynamic>.from(requestOptions.headers);

    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      cancelToken: requestOptions.cancelToken,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
      options: Options(
        method: requestOptions.method,
        headers: headers,
        responseType: requestOptions.responseType,
        contentType: requestOptions.contentType,
        sendTimeout: requestOptions.sendTimeout,
        receiveTimeout: requestOptions.receiveTimeout,
        extra: {
          ...requestOptions.extra,
          'retried': true,
        },
      ),
    );
  }

  Future<void> _persistTokensFromResponse(Response<dynamic> response) async {
    final responseBody = response.data;

    // 1. Check if the response is a JSON Map
    if (responseBody is Map<String, dynamic>) {

      // 2. Open the Spring Boot envelope to get the inner 'data' object
      final nestedData = responseBody['data'];

      // 3. Extract the accessToken from inside the envelope
      if (nestedData is Map<String, dynamic>) {
        final accessToken = nestedData['accessToken'];

        if (accessToken is String && accessToken.isNotEmpty) {
          await _secureStorage.saveAccessToken(accessToken);
          print("ACCESS TOKEN SAVED SUCCESSFULLY!"); // Added a print to confirm!
        }
      }
    }

    // 4. The refresh token is in the headers, so your original logic for this is perfect!
    final cookieRefreshToken = _extractRefreshTokenFromSetCookie(response);
    if (cookieRefreshToken != null && cookieRefreshToken.isNotEmpty) {
      await _secureStorage.saveRefreshToken(cookieRefreshToken);
      print("REFRESH TOKEN SAVED SUCCESSFULLY!");
    }
  }

  String? _extractRefreshTokenFromSetCookie(Response<dynamic> response) {
    final setCookieHeaders = response.headers.map['set-cookie'];
    if (setCookieHeaders == null || setCookieHeaders.isEmpty) {
      return null;
    }

    for (final headerValue in setCookieHeaders) {
      final firstCookiePair = headerValue.split(';').first.trim();
      const prefix = 'refreshToken=';

      if (firstCookiePair.startsWith(prefix)) {
        final rawValue = firstCookiePair.substring(prefix.length);
        return Uri.decodeComponent(rawValue);
      }
    }

    return null;
  }

  bool _isAuthPath(String rawPath) {
    return _normalizedPath(rawPath).startsWith('/api/auth/');
  }

  String _normalizedPath(String rawPath) {
    final uri = Uri.tryParse(rawPath);

    String path;
    if (uri != null && uri.hasScheme) {
      path = uri.path;
    } else {
      path = rawPath;
    }

    if (!path.startsWith('/')) {
      return '/$path';
    }

    return path;
  }
}
