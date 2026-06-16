import 'package:flutter/foundation.dart';

import '../../../../core/utils/secure_storage_service.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

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
  })  : _authRepository = authRepository ?? AuthRepository(),
        _secureStorage = secureStorage ?? SecureStorageService() {
    checkAuthStatus();
  }

  final AuthRepository _authRepository;
  final SecureStorageService _secureStorage;

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

    final accessToken = await _secureStorage.readAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.login(email: email, password: password);

      final accessToken = await _secureStorage.readAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
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
    await _secureStorage.clearTokens();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }
}
