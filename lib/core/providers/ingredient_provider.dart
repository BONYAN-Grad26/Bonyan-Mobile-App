import 'package:flutter/foundation.dart';
import 'package:bonyaan_app/core/models/models.dart';
import 'package:bonyaan_app/core/network/exceptions.dart';
import 'package:bonyaan_app/core/repositories/repositories.dart';

class IngredientProvider extends ChangeNotifier {
  IngredientProvider({required IngredientRepository ingredientRepository})
      : _ingredientRepository = ingredientRepository;

  final IngredientRepository _ingredientRepository;

  bool _isLoading = false;
  String? _errorMessage;

  List<IngredientDto> _ingredients = [];
  ReadIngredientDto? _currentIngredient;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<IngredientDto> get ingredients => _ingredients;
  ReadIngredientDto? get currentIngredient => _currentIngredient;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchAllIngredients({int pageIdx = 1, List<String>? dietaryTagTypes}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _ingredients = await _ingredientRepository.getAllIngredients(
        pageIdx: pageIdx,
        dietaryTagTypes: dietaryTagTypes,
      );
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

  Future<void> fetchIngredientById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentIngredient = await _ingredientRepository.getIngredientById(id);
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

  Future<void> fetchIngredientByName(String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentIngredient = await _ingredientRepository.getIngredientByName(name);
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

  Future<bool> addIngredient(CreateIngredientDto dto, String filePath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentIngredient = await _ingredientRepository.addIngredient(dto, filePath);
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

  Future<bool> updateIngredient(int id, UpdateIngredientDto dto) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentIngredient = await _ingredientRepository.updateIngredient(id, dto);
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

  Future<bool> deleteIngredient(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _ingredientRepository.deleteIngredient(id);
      _ingredients.removeWhere((element) => element.id == id);
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

  Future<bool> addIngredientTags(int ingredientId, List<int> tagIds) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _ingredientRepository.addIngredientTags(ingredientId, tagIds);
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

  Future<bool> removeIngredientTags(int ingredientId, List<int> tagIds) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _ingredientRepository.removeIngredientTags(ingredientId, tagIds);
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
