import 'package:flutter/foundation.dart';

import '../../../../core/utils/secure_storage_service.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/token_storage_impl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
}

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    AuthRepository? authRepository,
    SecureStorageService? secureStorage,
    TokenStorage? tokenStorage,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _secureStorage = secureStorage ?? SecureStorageService(),
        _tokenStorage = tokenStorage ?? SharedPreferencesTokenStorage() {
    checkAuthStatus();
  }

  final AuthRepository _authRepository;
  final SecureStorageService _secureStorage;
  final TokenStorage _tokenStorage;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      String? accessToken = await _secureStorage.readAccessToken().timeout(
        const Duration(milliseconds: 800),
        onTimeout: () => null,
      );

      if (accessToken == null || accessToken.isEmpty) {
        accessToken = await _tokenStorage.getAccessToken();
      }

      if (accessToken != null && accessToken.isNotEmpty) {
        await _tokenStorage.saveAccessToken(accessToken);
        // Restore user from SharedPreferences if available
        final prefs = await SharedPreferences.getInstance();
        final userJsonStr = prefs.getString('cached_current_user');
        if (userJsonStr != null) {
          try {
            _currentUser = UserModel.fromJson(jsonDecode(userJsonStr));
          } catch (e) {
            // ignore JSON decode error
          }
        }
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    // --- START OF MOCK LOGIN BYPASS ---
    if (email == "test@test.com" && password == "password123") {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      _currentUser = const UserModel(
        id: 1,
        email: "test@test.com",
        firstName: "Test",
        lastName: "User",
      );
      await _tokenStorage.saveAccessToken("mock_token");
      await _secureStorage.saveAccessToken("mock_token");
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    }
    try {
      _currentUser = await _authRepository.login(email: email, password: password);
      // Fallback: If backend doesn't return user details, create a minimal one with email
      if (_currentUser == null) {
        _currentUser = UserModel(email: email, firstName: '', lastName: '');
      }

      if (_currentUser != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_current_user', jsonEncode(_currentUser!.toJson()));
      }

      String? accessToken = await _secureStorage.readAccessToken().timeout(
        const Duration(milliseconds: 800),
        onTimeout: () => null,
      );

      if (accessToken == null || accessToken.isEmpty) {
        accessToken = await _tokenStorage.getAccessToken();
      }

      if (accessToken != null && accessToken.isNotEmpty) {
        await _tokenStorage.saveAccessToken(accessToken);
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }

      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Login succeeded but access token was not saved.';
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      // Fallback: If backend doesn't return user details, create a minimal one
      if (_currentUser == null) {
        _currentUser = UserModel(email: email, firstName: firstName, lastName: lastName);
      }

      if (_currentUser != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_current_user', jsonEncode(_currentUser!.toJson()));
      }

      // Registration may require email confirmation before authentication.
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirmEmail({required String email, required String otp}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.confirmEmail(email: email, otp: otp);
      final accessToken = await _secureStorage.readAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        await _tokenStorage.saveAccessToken(accessToken);
      }
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _secureStorage.clearTokens();
      await _tokenStorage.clearAccessToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_current_user');
    } catch (e) {
      debugPrint('Error clearing tokens during logout: $e');
    } finally {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    }
  }
}
