import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _unitKey = 'measurement_units';
  static const String _mealRemindersKey = 'meal_reminders';
  static const String _workoutAlertsKey = 'workout_alerts';
  static const String _progressUpdatesKey = 'progress_updates';
  static const String _languageKey = 'language';
  
  ThemeMode _themeMode = ThemeMode.dark;
  String _measurementUnit = 'Metric (kg, cm)';
  bool _mealReminders = true;
  bool _workoutAlerts = true;
  bool _progressUpdates = true;
  String _language = 'English (US)';

  SettingsProvider() {
    _loadSettings();
  }

  ThemeMode get themeMode => _themeMode;
  String get measurementUnit => _measurementUnit;
  bool get mealReminders => _mealReminders;
  bool get workoutAlerts => _workoutAlerts;
  bool get progressUpdates => _progressUpdates;
  String get language => _language;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load theme
    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.dark.index;
    _themeMode = ThemeMode.values[themeIndex];
    
    // Load units
    _measurementUnit = prefs.getString(_unitKey) ?? 'Metric (kg, cm)';
    
    // Load toggles
    _mealReminders = prefs.getBool(_mealRemindersKey) ?? true;
    _workoutAlerts = prefs.getBool(_workoutAlertsKey) ?? true;
    _progressUpdates = prefs.getBool(_progressUpdatesKey) ?? true;
    
    // Load language
    _language = prefs.getString(_languageKey) ?? 'English (US)';
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  Future<void> setMeasurementUnit(String unit) async {
    if (_measurementUnit == unit) return;
    _measurementUnit = unit;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_unitKey, unit);
  }

  Future<void> setMealReminders(bool value) async {
    if (_mealReminders == value) return;
    _mealReminders = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mealRemindersKey, value);
  }

  Future<void> setWorkoutAlerts(bool value) async {
    if (_workoutAlerts == value) return;
    _workoutAlerts = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_workoutAlertsKey, value);
  }

  Future<void> setProgressUpdates(bool value) async {
    if (_progressUpdates == value) return;
    _progressUpdates = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_progressUpdatesKey, value);
  }

  Future<void> setLanguage(String value) async {
    if (_language == value) return;
    _language = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, value);
  }
}
