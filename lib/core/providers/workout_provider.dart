import 'package:flutter/foundation.dart';

import 'package:bonyaan_app/core/models/models.dart';
import 'package:bonyaan_app/core/network/exceptions.dart';
import 'package:bonyaan_app/core/repositories/repositories.dart';

/// Provider for workout plan state management
/// Bridges WorkoutRepository to the UI layer
class WorkoutProvider extends ChangeNotifier {
  WorkoutProvider({required WorkoutRepository workoutRepository})
      : _workoutRepository = workoutRepository;

  final WorkoutRepository _workoutRepository;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  bool _isLoading = false;
  String? _errorMessage;
  String? _generationError;

  List<WorkoutPlan> _userWorkouts = [];
  WorkoutPlan? _currentPlan;
  TodayWorkout? _todayWorkout;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get generationError => _generationError;
  List<WorkoutPlan> get userWorkouts => _userWorkouts;
  WorkoutPlan? get currentPlan => _currentPlan;
  TodayWorkout? get todayWorkout => _todayWorkout;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Clears any previous error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Generate a new AI-powered weekly workout plan
  Future<bool> generateWeeklyPlan() async {
    _isLoading = true;
    _errorMessage = null;
    _generationError = null;
    notifyListeners();

    try {
      final plan = await _workoutRepository.generateWeeklyPlan();
      _currentPlan = plan;
      _userWorkouts = [plan, ..._userWorkouts];
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e, stackTrace) {
      print('================ API EXCEPTION ================');
      print(e);
      print(stackTrace);
      print('=============================================');
      
      if (e.statusCode == '400' || e.message.contains('Validation') || e.message.contains('ongoing')) {
        _generationError = 'You already have an active plan for this week!';
        _isLoading = false;
        notifyListeners();
        return false;
      } else if (e.statusCode == '500' || e.statusCode == '429' || e.message.contains('429') || e.message.contains('Quota')) {
        _errorMessage = 'AI generation is currently busy. Please wait 30 seconds and try again.';
      } else {
        _errorMessage = e.message;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('429') || errorStr.contains('Quota')) {
        _errorMessage = 'AI generation is currently busy. Please wait 30 seconds and try again.';
      } else {
        _errorMessage = errorStr.replaceFirst('Exception: ', '');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Fetch a specific workout plan by its ID
  Future<void> fetchPlanById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPlan = await _workoutRepository.getById(id);
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

  /// Fetch all workout plans for a specific user
  Future<void> fetchUserWorkouts(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userWorkouts = await _workoutRepository.getUserWorkouts(userId);
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

  /// Fetch the current weekly workout plan (bypassing today endpoint)
  Future<void> fetchCurrentWorkoutPlan() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final myWorkout = await _workoutRepository.getMyWorkout();
      
      _currentPlan = myWorkout;
      _userWorkouts = [myWorkout];

      _isLoading = false;
      notifyListeners();
    } on NotFoundException {
      _currentPlan = null;
      _todayWorkout = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      print('🔥 WORKOUT FETCH ERROR: $e');
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      print('🔥 WORKOUT FETCH ERROR: $e');
      print('🔥 STACK: $stackTrace');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a workout plan
  Future<bool> deleteWorkout(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _workoutRepository.deleteWorkout(id);
      _userWorkouts = _userWorkouts.where((p) => p.planName != id.toString() /* Adjust logic if id is mapped to a field in plan */).toList();
      // If we had an id on the WorkoutPlan model we could check it here. 
      // For now, if the current plan is deleted, the caller should handle clearing it.
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
}
