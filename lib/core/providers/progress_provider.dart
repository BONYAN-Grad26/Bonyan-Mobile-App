import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressProvider extends ChangeNotifier {
  final SharedPreferences prefs;

  ProgressProvider({required this.prefs});

  // Track meal completion: key is 'meal_${mealId}'
  bool isMealCompleted(int mealId) {
    return prefs.getBool('meal_$mealId') ?? false;
  }

  Future<void> toggleMeal(int mealId, bool value) async {
    await prefs.setBool('meal_$mealId', value);
    notifyListeners();
  }

  // Track workout completion: key is 'workout_${workoutId}'
  bool isWorkoutCompleted(int workoutId) {
    return prefs.getBool('workout_$workoutId') ?? false;
  }

  Future<void> toggleWorkout(int workoutId, bool value) async {
    await prefs.setBool('workout_$workoutId', value);
    notifyListeners();
  }

  int get completedMealsCount {
    return prefs.getKeys().where((k) => k.startsWith('meal_') && prefs.getBool(k) == true).length;
  }

  int get completedWorkoutsCount {
    return prefs.getKeys().where((k) => k.startsWith('workout_') && prefs.getBool(k) == true).length;
  }
  
  // Track custom name locally
  String get customFirstName => prefs.getString('custom_first_name') ?? '';
  String get customLastName => prefs.getString('custom_last_name') ?? '';
  
  Future<void> setCustomName(String first, String last) async {
    await prefs.setString('custom_first_name', first);
    await prefs.setString('custom_last_name', last);
    notifyListeners();
  }

  // Clear progress (e.g. on new week)
  Future<void> clearProgress() async {
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith('meal_') || key.startsWith('workout_')) {
        await prefs.remove(key);
      }
    }
    notifyListeners();
  }
}
