import 'package:flutter/foundation.dart';

import '../../../../core/utils/secure_storage_service.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/token_storage_impl.dart';

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
      final accessToken = await _secureStorage.readAccessToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        await _tokenStorage.saveAccessToken(accessToken);
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

    try {
      _currentUser = await _authRepository.login(email: email, password: password);

      final accessToken = await _secureStorage.readAccessToken();
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
