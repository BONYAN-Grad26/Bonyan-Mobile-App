import 'package:flutter/foundation.dart';
import 'package:bonyaan_app/core/models/models.dart';
import 'package:bonyaan_app/core/network/exceptions.dart';
import 'package:bonyaan_app/core/repositories/repositories.dart';

class AllergyProvider extends ChangeNotifier {
  AllergyProvider({required AllergyRepository allergyRepository})
      : _allergyRepository = allergyRepository;

  final AllergyRepository _allergyRepository;

  bool _isLoading = false;
  String? _errorMessage;

  List<ReadAllergyDto> _allergies = [];
  ReadAllergyDto? _currentAllergy;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ReadAllergyDto> get allergies => _allergies;
  ReadAllergyDto? get currentAllergy => _currentAllergy;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchMyAllergies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allergies = await _allergyRepository.getMyAllergies();
      _isLoading = false;
      notifyListeners();
    } on NotFoundException {
      _allergies = [];
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

  Future<void> fetchAllergiesByUserId(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allergies = await _allergyRepository.getAllergiesByUserId(userId);
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

  Future<void> fetchAllergyById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentAllergy = await _allergyRepository.getAllergyById(id);
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

  Future<bool> addAllergy(CreateAllergyDto dto) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentAllergy = await _allergyRepository.addAllergy(dto);
      _allergies.add(_currentAllergy!);
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

  Future<bool> updateAllergy(int id, UpdateAllergyDto dto) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentAllergy = await _allergyRepository.updateAllergy(id, dto);
      final index = _allergies.indexWhere((element) => element.id == id);
      if (index != -1 && _currentAllergy != null) {
        _allergies[index] = _currentAllergy!;
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

  Future<bool> deleteAllergy(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _allergyRepository.deleteAllergy(id);
      _allergies.removeWhere((element) => element.id == id);
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
