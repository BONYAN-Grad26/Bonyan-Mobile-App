import 'package:flutter/foundation.dart';

import 'package:bonyaan_app/core/models/models.dart';
import 'package:bonyaan_app/core/network/exceptions.dart';
import 'package:bonyaan_app/core/repositories/repositories.dart';

/// Provider for diet plan state management
/// Bridges DietPlanRepository to the UI layer
class DietPlanProvider extends ChangeNotifier {
  DietPlanProvider({required DietPlanRepository dietPlanRepository})
      : _dietPlanRepository = dietPlanRepository;

  final DietPlanRepository _dietPlanRepository;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  bool _isLoading = false;
  String? _errorMessage;
  String? _generationError;

  List<WeeklyPlan> _weeklyPlans = [];
  WeeklyPlan? _currentPlan;
  DayPlan? _todayPlan;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get generationError => _generationError;
  List<WeeklyPlan> get weeklyPlans => _weeklyPlans;
  WeeklyPlan? get currentPlan => _currentPlan;
  DayPlan? get todayPlan => _todayPlan;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Clears any previous error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Generate a new AI-powered weekly diet plan
  Future<bool> generateWeeklyPlan({
    required String startDate,
    int weekNumber = 1,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _generationError = null;
    notifyListeners();

    try {
      final plan = await _dietPlanRepository.generateWeeklyPlan(
        startDate: startDate,
        weekNumber: weekNumber,
      );
      _currentPlan = plan;
      // Prepend the newly generated plan to the cached list
      _weeklyPlans = [plan, ..._weeklyPlans];
      
      // Update todayPlan so the UI immediately reflects the new meals
      if (plan.days != null && plan.days!.isNotEmpty) {
        _todayPlan = plan.days!.first;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
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

  /// Fetch all weekly diet plans for the authenticated user
  Future<void> fetchWeeklyPlans() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _weeklyPlans = await _dietPlanRepository.getWeeklyPlans();
      if (_weeklyPlans.isNotEmpty && _weeklyPlans.first.id != null) {
        // Fetch the full plan by ID to get the populated 'days' list
        _currentPlan = await _dietPlanRepository.getPlanById(_weeklyPlans.first.id!);
      } else {
        _currentPlan = null;
      }
      _isLoading = false;
      notifyListeners();
    } on NotFoundException {
      _weeklyPlans = [];
      _currentPlan = null;
      _isLoading = false;
      _errorMessage = null;
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

  /// Fetch today's daily diet plan (using local timezone)
  Future<void> fetchTodayPlan() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _todayPlan = await _dietPlanRepository.getTodayPlan();
      _isLoading = false;
      notifyListeners();
    } on NotFoundException {
      _todayPlan = null;
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

  /// Fetch a specific weekly plan by its ID and set it as the current plan
  Future<void> fetchPlanById(int planId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPlan = await _dietPlanRepository.getPlanById(planId);
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

  /// Fetch a daily plan by ID (returns parent weekly context)
  Future<void> fetchDailyPlanById(int planId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPlan = await _dietPlanRepository.getDailyPlanById(planId);
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

  /// Update an existing weekly diet plan
  Future<bool> updatePlan(int planId, WeeklyPlan updatedPlan) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final plan = await _dietPlanRepository.updatePlan(planId, updatedPlan);
      _currentPlan = plan;
      // Replace the updated plan in the cached list
      _weeklyPlans = _weeklyPlans.map((p) {
        return p.id == planId ? plan : p;
      }).toList();
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

  /// Delete a weekly diet plan
  Future<bool> deletePlan(int planId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dietPlanRepository.deletePlan(planId);
      // Remove from cached list
      _weeklyPlans = _weeklyPlans.where((p) => p.id != planId).toList();
      // Clear current plan if it was deleted
      if (_currentPlan?.id == planId) {
        _currentPlan = null;
      }
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
