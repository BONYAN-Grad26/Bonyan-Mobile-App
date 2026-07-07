import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SuggestedMeal {
  final List<String> detectedIngredients;
  final String name;
  final String description;
  final List<String> ingredientsUsed;
  final List<String> steps;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  SuggestedMeal({
    required this.detectedIngredients,
    required this.name,
    required this.description,
    required this.ingredientsUsed,
    required this.steps,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory SuggestedMeal.fromJson(Map<String, dynamic> json) {
    final detected = List<String>.from(json['detected_ingredients'] ?? []);
    final meal = json['meal'] ?? {};
    final macros = meal['macros'] ?? {};
    
    return SuggestedMeal(
      detectedIngredients: detected,
      name: meal['name'] ?? '',
      description: meal['description'] ?? '',
      ingredientsUsed: List<String>.from(meal['ingredients_used'] ?? []),
      steps: List<String>.from(meal['steps'] ?? []),
      calories: meal['calories'] ?? 0,
      protein: (macros['protein_g'] ?? 0).toDouble(),
      carbs: (macros['carbs_g'] ?? 0).toDouble(),
      fat: (macros['fat_g'] ?? 0).toDouble(),
    );
  }
}

class MealSuggesterProvider extends ChangeNotifier {
  bool _isLoading = false;
  SuggestedMeal? _suggestedMeal;
  String? _error;

  bool get isLoading => _isLoading;
  SuggestedMeal? get suggestedMeal => _suggestedMeal;
  String? get error => _error;

  final String _baseUrl = 'https://m0hamed-tarek-ingredients-detector-and-meal-suggester.hf.space';

  void clearSuggestion() {
    _suggestedMeal = null;
    _error = null;
    notifyListeners();
  }

  Future<void> suggestMeal(File image, String cuisine, String mealType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/detect-and-suggest/image'));
      
      // Attach the image file
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
      
      // Add form fields based on API specs
      request.fields['cuisine'] = cuisine;
      request.fields['meal_type'] = mealType;
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _suggestedMeal = SuggestedMeal.fromJson(data);
        } else {
          _error = 'Failed to get a meal suggestion.';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
