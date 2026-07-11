import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressProvider extends ChangeNotifier {
  final SharedPreferences prefs;

  ProgressProvider({required this.prefs});

  int? currentUserId;

  void updateUserId(int? userId) {
    if (currentUserId != userId) {
      currentUserId = userId;
      notifyListeners();
    }
  }

  String _getKey(String baseKey) {
    if (currentUserId == null) return baseKey;
    return '${currentUserId}_$baseKey';
  }

  // Track meal completion: key is 'meal_${mealId}'
  bool isMealCompleted(int mealId) {
    return prefs.getBool(_getKey('meal_$mealId')) ?? false;
  }

  Future<void> toggleMeal(int mealId, bool value) async {
    await prefs.setBool(_getKey('meal_$mealId'), value);
    notifyListeners();
  }

  // Track workout completion: key is 'workout_${workoutId}'
  bool isWorkoutCompleted(int workoutId) {
    return prefs.getBool(_getKey('workout_$workoutId')) ?? false;
  }

  Future<void> toggleWorkout(int workoutId, bool value) async {
    await prefs.setBool(_getKey('workout_$workoutId'), value);
    notifyListeners();
  }

  // Track individual exercise completion: key is 'exercise_${workoutId}_${exerciseName}'
  bool isExerciseCompleted(int workoutId, String exerciseName) {
    return prefs.getBool(_getKey('exercise_${workoutId}_$exerciseName')) ?? false;
  }

  Future<void> toggleExercise(int workoutId, String exerciseName, bool value) async {
    await prefs.setBool(_getKey('exercise_${workoutId}_$exerciseName'), value);
    notifyListeners();
  }

  int get completedMealsCount {
    final prefix = currentUserId == null ? 'meal_' : '${currentUserId}_meal_';
    return prefs.getKeys().where((k) => k.startsWith(prefix) && prefs.getBool(k) == true).length;
  }

  int get completedWorkoutsCount {
    final prefix = currentUserId == null ? 'workout_' : '${currentUserId}_workout_';
    return prefs.getKeys().where((k) => k.startsWith(prefix) && prefs.getBool(k) == true).length;
  }
  
  // Track custom name locally
  String get customFirstName => prefs.getString(_getKey('custom_first_name')) ?? '';
  String get customLastName => prefs.getString(_getKey('custom_last_name')) ?? '';
  
  Future<void> setCustomName(String first, String last) async {
    await prefs.setString(_getKey('custom_first_name'), first);
    await prefs.setString(_getKey('custom_last_name'), last);
    notifyListeners();
  }

  // Clear progress (e.g. on new week)
  Future<void> clearProgress() async {
    final keys = prefs.getKeys();
    final mealPrefix = currentUserId == null ? 'meal_' : '${currentUserId}_meal_';
    final workoutPrefix = currentUserId == null ? 'workout_' : '${currentUserId}_workout_';
    final exercisePrefix = currentUserId == null ? 'exercise_' : '${currentUserId}_exercise_';

    for (String key in keys) {
      if (key.startsWith(mealPrefix) || key.startsWith(workoutPrefix) || key.startsWith(exercisePrefix)) {
        await prefs.remove(key);
      }
    }
    notifyListeners();
  }
}
