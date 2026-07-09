// Health Profile and Metrics models

enum Gender { male, female, other }

enum ActivityLevel { sedentary, light, moderate, active, veryActive }

enum DietGoal { loseFat, gainMuscle, maintain, bulkUp }

enum DietType { balanced, lowCarb, highProtein, keto, vegan, vegetarian }

/// Extended health metrics/profile data
class HealthMetrics {
  final int? id;
  final int? age;
  final double? weightKg;
  final double? heightCm;
  final double? muscleMassKg;
  final double? fatPercentage;
  final Gender? gender;
  final ActivityLevel? activityLevel;
  final String? medicalNotes;
  final DietType? dietType;
  final DietGoal? dietGoal;
  final double? bmi;
  final String? bmiCategory;
  final int? tdee;
  final double? fatMass;
  final double? leanMass;
  final String? bodyFatCategory;
  final double? targetWeightKg;
  final int? dailyCalorieTarget;

  HealthMetrics({
    this.id,
    this.age,
    this.weightKg,
    this.heightCm,
    this.muscleMassKg,
    this.fatPercentage,
    this.gender,
    this.activityLevel,
    this.medicalNotes,
    this.dietType,
    this.dietGoal,
    this.bmi,
    this.bmiCategory,
    this.tdee,
    this.fatMass,
    this.leanMass,
    this.bodyFatCategory,
    this.targetWeightKg,
    this.dailyCalorieTarget,
  });

  factory HealthMetrics.fromJson(Map<String, dynamic> json) {
    // Safely unwrap 'data' key if it exists
    final data = json.containsKey('data') && json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : json;

    return HealthMetrics(
      id: _toInt(data['id']),
      age: _toInt(data['age']),
      weightKg: _toDouble(data['weightKg'] ?? data['weight_kg']),
      heightCm: _toDouble(data['heightCm'] ?? data['height_cm']),
      muscleMassKg: _toDouble(data['muscleMassKg'] ?? data['muscle_mass_kg']),
      fatPercentage: _toDouble(data['fatPercentage'] ?? data['fat_percentage']),
      gender: _parseGender(data['gender']),
      activityLevel: _parseActivityLevel(data['activityLevel'] ?? data['activity_level']),
      medicalNotes: (data['medicalNotes'] ?? data['medical_notes'])?.toString(),
      dietType: _parseDietType(data['dietType'] ?? data['diet_type']),
      dietGoal: _parseDietGoal(data['dietGoal'] ?? data['diet_goal']),
      bmi: _toDouble(data['bmi']),
      bmiCategory: (data['bmiCategory'] ?? data['bmi_category'])?.toString(),
      tdee: _toInt(data['tdee']),
      fatMass: _toDouble(data['fatMass'] ?? data['fat_mass']),
      leanMass: _toDouble(data['leanMass'] ?? data['lean_mass']),
      bodyFatCategory: (data['bodyFatCategory'] ?? data['body_fat_category'])?.toString(),
      targetWeightKg: _toDouble(data['targetWeightKg'] ?? data['target_weight_kg']),
      dailyCalorieTarget: _toInt(data['dailyCalorieTarget'] ?? data['daily_calorie_target']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (age != null) 'age': age,
      if (weightKg != null) 'weightKg': weightKg,
      if (heightCm != null) 'heightCm': heightCm,
      if (muscleMassKg != null) 'muscleMassKg': muscleMassKg,
      if (fatPercentage != null) 'fatPercentage': fatPercentage,
      if (gender != null) 'gender': _genderToString(gender!),
      if (activityLevel != null) 'activityLevel': _activityLevelToString(activityLevel!),
      if (medicalNotes != null) 'medicalNotes': medicalNotes,
      if (dietType != null) 'dietType': _dietTypeToString(dietType!),
      if (dietGoal != null) 'dietGoal': _dietGoalToString(dietGoal!),
      if (bmi != null) 'bmi': bmi,
      if (bmiCategory != null) 'bmiCategory': bmiCategory,
      if (tdee != null) 'tdee': tdee,
      if (fatMass != null) 'fatMass': fatMass,
      if (leanMass != null) 'leanMass': leanMass,
      if (bodyFatCategory != null) 'bodyFatCategory': bodyFatCategory,
      if (targetWeightKg != null) 'targetWeightKg': targetWeightKg,
      if (dailyCalorieTarget != null) 'dailyCalorieTarget': dailyCalorieTarget,
    };
  }

  @override
  String toString() => 'HealthMetrics(age: $age, weightKg: $weightKg, heightCm: $heightCm, bmi: $bmi)';
}

/// Helper functions for enum parsing
Gender? _parseGender(dynamic value) {
  if (value == null || value is! String) return null;
  switch (value.toUpperCase()) {
    case 'MALE':
      return Gender.male;
    case 'FEMALE':
      return Gender.female;
    case 'OTHER':
      return Gender.other;
    default:
      return Gender.other;
  }
}

String _genderToString(Gender gender) {
  switch (gender) {
    case Gender.male:
      return 'MALE';
    case Gender.female:
      return 'FEMALE';
    case Gender.other:
      return 'OTHER';
  }
}

ActivityLevel? _parseActivityLevel(dynamic value) {
  if (value == null || value is! String) return null;
  switch (value.toUpperCase()) {
    case 'SEDENTARY':
      return ActivityLevel.sedentary;
    case 'LIGHT':
      return ActivityLevel.light;
    case 'MODERATE':
      return ActivityLevel.moderate;
    case 'ACTIVE':
      return ActivityLevel.active;
    case 'VERY_ACTIVE':
    case 'VERYACTIVE':
      return ActivityLevel.veryActive;
    default:
      return ActivityLevel.moderate;
  }
}

String _activityLevelToString(ActivityLevel level) {
  switch (level) {
    case ActivityLevel.sedentary:
      return 'SEDENTARY';
    case ActivityLevel.light:
      return 'LIGHT';
    case ActivityLevel.moderate:
      return 'MODERATE';
    case ActivityLevel.active:
      return 'ACTIVE';
    case ActivityLevel.veryActive:
      return 'VERY_ACTIVE';
  }
}

DietType? _parseDietType(dynamic value) {
  if (value == null || value is! String) return null;
  switch (value.toUpperCase()) {
    case 'BALANCED':
      return DietType.balanced;
    case 'LOWCARB':
    case 'LOW_CARB':
      return DietType.lowCarb;
    case 'HIGHPROTEIN':
    case 'HIGH_PROTEIN':
      return DietType.highProtein;
    case 'KETO':
      return DietType.keto;
    case 'VEGAN':
      return DietType.vegan;
    case 'VEGETARIAN':
      return DietType.vegetarian;
    default:
      return DietType.balanced;
  }
}

String _dietTypeToString(DietType type) {
  switch (type) {
    case DietType.balanced:
      return 'BALANCED';
    case DietType.lowCarb:
      return 'LOW_CARB';
    case DietType.highProtein:
      return 'HIGH_PROTEIN';
    case DietType.keto:
      return 'KETO';
    case DietType.vegan:
      return 'VEGAN';
    case DietType.vegetarian:
      return 'VEGETARIAN';
  }
}

DietGoal? _parseDietGoal(dynamic value) {
  if (value == null || value is! String) return null;
  switch (value.toUpperCase()) {
    case 'LOSE_FAT':
    case 'LOSEFAT':
      return DietGoal.loseFat;
    case 'GAIN_MUSCLE':
    case 'GAINMUSCLE':
      return DietGoal.gainMuscle;
    case 'MAINTAIN':
      return DietGoal.maintain;
    case 'BULK_UP':
    case 'BULKUP':
      return DietGoal.bulkUp;
    default:
      return DietGoal.maintain;
  }
}

String _dietGoalToString(DietGoal goal) {
  switch (goal) {
    case DietGoal.loseFat:
      return 'LOSE_FAT';
    case DietGoal.gainMuscle:
      return 'GAIN_MUSCLE';
    case DietGoal.maintain:
      return 'MAINTAIN';
    case DietGoal.bulkUp:
      return 'BULK_UP';
  }
}
