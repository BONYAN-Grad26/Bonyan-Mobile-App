import 'package:flutter/foundation.dart';
import 'package:bonyaan_app/core/models/models.dart';
import 'package:bonyaan_app/core/network/exceptions.dart';
import 'package:bonyaan_app/core/repositories/repositories.dart';

class TagProvider extends ChangeNotifier {
  TagProvider({required TagRepository tagRepository})
      : _tagRepository = tagRepository;

  final TagRepository _tagRepository;

  bool _isLoading = false;
  String? _errorMessage;

  List<DietaryTagDto> _tags = [];
  ReadDietaryTagDto? _currentTag;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<DietaryTagDto> get tags => _tags;
  ReadDietaryTagDto? get currentTag => _currentTag;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchAllTags({int pageIdx = 1}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tags = await _tagRepository.getAllTags(pageIdx: pageIdx);
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

  Future<void> fetchTagById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentTag = await _tagRepository.getTagById(id);
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

  Future<bool> createTag(CreateDietaryTagDto dto) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentTag = await _tagRepository.createTag(dto);
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

  Future<bool> updateTag(int id, UpdateDietaryTagDto dto) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentTag = await _tagRepository.updateTag(id, dto);
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

  Future<bool> deleteTag(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _tagRepository.deleteTag(id);
      _tags.removeWhere((element) => element.id == id);
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
