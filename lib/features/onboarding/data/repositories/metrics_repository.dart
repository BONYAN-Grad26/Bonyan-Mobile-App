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
    
    final map = response as Map<String, dynamic>;
    final data = map['data'] ?? map;

    return HealthMetricModel.fromJson(data as Map<String, dynamic>);
  }

  Future<HealthMetricModel?> getMyHealthProfile() async {
    try {
      final response = await apiClient.get('/api/health-profile/me');
      if (response == null) {
        return null;
      }
      final map = response as Map<String, dynamic>;
      final data = map['data'] ?? map;
      return HealthMetricModel.fromJson(data as Map<String, dynamic>);
    } on NotFoundException {
      return null;
    }
  }
}
