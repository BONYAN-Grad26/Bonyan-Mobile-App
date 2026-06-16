import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/health_metric_model.dart';

class MetricsRepository {
  MetricsRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  Future<HealthMetricModel> addHealthProfile(HealthMetricModel model) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/health-profile',
      data: model.toJson(),
    );

    final data = response.data;
    if (data == null) {
      return model;
    }

    return HealthMetricModel.fromJson(data);
  }

  Future<HealthMetricModel?> getMyHealthProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/health-profile/me');
    final data = response.data;

    if (data == null) {
      return null;
    }

    return HealthMetricModel.fromJson(data);
  }
}
