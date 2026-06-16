class HealthMetricModel {
  const HealthMetricModel({
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.gender,
    required this.activityLevel,
    required this.dietGoal,
    required this.unit,
    this.fatPercentage,
    this.muscleMassKg,
    this.medicalNotes,
    this.dietType,
    this.targetWeightKg,
    this.dailyCalorieTarget,
  });

  final int age;
  final double weightKg;
  final double heightCm;
  final String gender;
  final String activityLevel;
  final String dietGoal;
  final String unit;
  final double? fatPercentage;
  final double? muscleMassKg;
  final String? medicalNotes;
  final String? dietType;
  final double? targetWeightKg;
  final int? dailyCalorieTarget;

  factory HealthMetricModel.fromJson(Map<String, dynamic> json) {
    return HealthMetricModel(
      age: _toInt(json['age']) ?? 0,
      weightKg: _toDouble(json['weightKg']) ?? 0,
      heightCm: _toDouble(json['heightCm']) ?? 0,
      gender: (json['gender'] as String?) ?? '',
      activityLevel: (json['activityLevel'] as String?) ?? '',
      dietGoal: (json['dietGoal'] as String?) ?? '',
      unit: (json['unit'] as String?) ?? '', // <-- FIXED: Added the missing unit here
      fatPercentage: _toDouble(json['fatPercentage']),
      muscleMassKg: _toDouble(json['muscleMassKg']),
      medicalNotes: json['medicalNotes'] as String?,
      dietType: json['dietType'] as String?,
      targetWeightKg: _toDouble(json['targetWeightKg']),
      dailyCalorieTarget: _toInt(json['dailyCalorieTarget']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'gender': gender,
      'activityLevel': activityLevel,
      'dietGoal': dietGoal,
      'unit': unit, // <-- FIXED: Added unit to the JSON map so it saves correctly
      'fatPercentage': fatPercentage,
      'muscleMassKg': muscleMassKg,
      'medicalNotes': medicalNotes,
      'dietType': dietType,
      'targetWeightKg': targetWeightKg,
      'dailyCalorieTarget': dailyCalorieTarget,
    };
  }

  static int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}