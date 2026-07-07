import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class MachinePrediction {
  final String label;
  final double confidence;
  final String? videoUrl;

  MachinePrediction({
    required this.label,
    required this.confidence,
    this.videoUrl,
  });

  factory MachinePrediction.fromJson(Map<String, dynamic> json) {
    return MachinePrediction(
      label: json['label'] ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      videoUrl: json['video_url'],
    );
  }
}

class MachineClassifierProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  MachinePrediction? _prediction;
  MachinePrediction? get prediction => _prediction;

  void clearPrediction() {
    _prediction = null;
    _error = null;
    notifyListeners();
  }

  Future<void> classifyMachine(File imageFile) async {
    _isLoading = true;
    _error = null;
    _prediction = null;
    notifyListeners();

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        'https://fitness-part.onrender.com/predict',
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        _prediction = MachinePrediction.fromJson(response.data);
      } else {
        _error = 'Failed to classify the image. Please try again.';
      }
    } catch (e) {
      if (e is DioException) {
        _error = 'Network error: ${e.message}';
      } else {
        _error = 'An unexpected error occurred.';
      }
      debugPrint('Error in classifyMachine: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
