import 'package:flutter/foundation.dart';
import 'package:bonyaan_app/core/models/models.dart';
import 'package:bonyaan_app/core/network/exceptions.dart';
import 'package:bonyaan_app/core/repositories/repositories.dart';

class GoalProvider extends ChangeNotifier {
  GoalProvider({required GoalRepository goalRepository})
      : _goalRepository = goalRepository;

  final GoalRepository _goalRepository;

  bool _isLoading = false;
  String? _errorMessage;

  List<ReadGoalDto> _myGoals = [];
  List<GoalSummaryDto> _userGoals = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ReadGoalDto> get myGoals => _myGoals;
  List<GoalSummaryDto> get userGoals => _userGoals;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchMyGoals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myGoals = await _goalRepository.getMyGoals();
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

  Future<void> fetchGoalsByUserId(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userGoals = await _goalRepository.getGoalsByUserId(userId);
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

  Future<bool> addGoal(CreateGoalDto dto) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newGoal = await _goalRepository.addGoal(dto);
      _myGoals.add(newGoal);
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

  Future<bool> updateGoal(int id, UpdateGoalDto dto) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedGoal = await _goalRepository.updateGoal(id, dto);
      final index = _myGoals.indexWhere((element) => element.id == id);
      if (index != -1) {
        _myGoals[index] = updatedGoal;
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

  Future<bool> deleteGoal(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _goalRepository.deleteGoal(id);
      _myGoals.removeWhere((element) => element.id == id);
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
