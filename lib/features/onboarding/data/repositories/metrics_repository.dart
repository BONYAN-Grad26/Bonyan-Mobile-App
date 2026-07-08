import '../../../../core/network/api_client.dart';
import '../../../../core/network/exceptions.dart';
import '../models/health_metric_model.dart';

class MetricsRepository {
  final ApiClient apiClient;

  MetricsRepository({required this.apiClient});

  Future<HealthMetricModel> addHealthProfile(HealthMetricModel model) async {
    final response = await apiClient.post(
      '/api/health-profile',
      body: model.toJson(),
    );

    if (response == null) {
      return model;
    }

    return HealthMetricModel.fromJson(response as Map<String, dynamic>);
  }

  Future<HealthMetricModel?> getMyHealthProfile() async {
    try {
      final response = await apiClient.get('/api/health-profile/me');
      if (response == null) {
        return null;
      }
      
      if (response is Map<String, dynamic>) {
        return HealthMetricModel.fromJson(response);
      } else if (response is List) {
        if (response.isEmpty) return null;
        return HealthMetricModel.fromJson(response.first as Map<String, dynamic>);
      }
      
      return null;
    } on NotFoundException {
      return null;
    }
  }
}
