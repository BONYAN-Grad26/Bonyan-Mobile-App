import 'package:flutter/foundation.dart';

import 'package:bonyaan_app/core/models/models.dart';
import 'package:bonyaan_app/core/network/exceptions.dart';
import 'package:bonyaan_app/core/repositories/repositories.dart';

/// Provider for user profile and health metrics state management
/// Bridges UserRepository and HealthProfileRepository to the UI layer
class ProfileProvider extends ChangeNotifier {
  ProfileProvider({
    required UserRepository userRepository,
    required HealthProfileRepository healthProfileRepository,
  })  : _userRepository = userRepository,
        _healthProfileRepository = healthProfileRepository;

  final UserRepository _userRepository;
  final HealthProfileRepository _healthProfileRepository;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? _userProfile;
  HealthMetrics? _healthMetrics;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserProfile? get userProfile => _userProfile;
  HealthMetrics? get healthMetrics => _healthMetrics;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Clears any previous error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Fetch user profile by user ID
  Future<void> fetchUserProfile(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userProfile = await _userRepository.getUserProfile(userId);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch current user's health profile and metrics
  Future<void> fetchMyHealthProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _healthMetrics = await _healthProfileRepository.getMyHealthProfile();
      _isLoading = false;
      notifyListeners();
    } on NotFoundException {
      _healthMetrics = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch health profile by ID
  Future<void> fetchHealthProfileById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _healthMetrics = await _healthProfileRepository.getHealthProfileById(id);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new health profile for authenticated user
  Future<bool> createHealthProfile(HealthMetrics metrics) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _healthMetrics = await _healthProfileRepository.createHealthProfile(metrics);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update existing health profile
  Future<bool> updateHealthProfile(int id, HealthMetrics metrics) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _healthMetrics = await _healthProfileRepository.updateHealthProfile(id, metrics);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete health profile
  Future<bool> deleteHealthProfile(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _healthProfileRepository.deleteHealthProfile(id);
      _healthMetrics = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  void reset() {
    _userProfile = null;
    _healthMetrics = null;
    _errorMessage = null;
    notifyListeners();
  }
}
