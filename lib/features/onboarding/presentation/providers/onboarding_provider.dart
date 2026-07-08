import 'package:flutter/material.dart';

import '../../../onboarding/data/models/health_metric_model.dart';
import '../../../onboarding/data/repositories/metrics_repository.dart';

enum OnboardingSubmissionStatus { initial, loading, success, error }

class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider({required this.metricsRepository});

  final MetricsRepository metricsRepository;

  int? age;
  String? gender;
  double? heightCm;
  double? weightKg;
  double? muscleMassKg;
  double? fatPercentage;
  String? activityLevel;
  String? dietGoal;
  String? dietType;
  double? targetWeightKg;
  String? medicalNotes;

  bool isCheckingExistingProfile = false;
  bool hasCheckedExistingProfile = false;
  OnboardingSubmissionStatus submissionStatus = OnboardingSubmissionStatus.initial;
  HealthMetricModel? savedProfile;
  String? errorMessage;

  int? get dailyCalorieTarget {
    if (savedProfile?.dailyCalorieTarget != null) {
      return savedProfile!.dailyCalorieTarget;
    }
    if (age != null && weightKg != null && heightCm != null && gender != null) {
      return _estimateDailyCalories();
    }
    return null;
  }

  void updateAge(int? value) {
    age = value;
    notifyListeners();
  }

  void updateGender(String? value) {
    gender = value;
    notifyListeners();
  }

  void updateHeightCm(double? value) {
    heightCm = value;
    notifyListeners();
  }

  void updateWeightKg(double? value) {
    weightKg = value;
    notifyListeners();
  }

  void updateMuscleMassKg(double? value) {
    muscleMassKg = value;
    notifyListeners();
  }

  void updateFatPercentage(double? value) {
    fatPercentage = value;
    notifyListeners();
  }

  void updateActivityLevel(String? value) {
    activityLevel = value;
    notifyListeners();
  }

  void updateDietGoal(String? value) {
    dietGoal = value;
    notifyListeners();
  }

  void updateDietType(String? value) {
    dietType = value;
    notifyListeners();
  }

  void updateTargetWeightKg(double? value) {
    targetWeightKg = value;
    notifyListeners();
  }

  void updateMedicalNotes(String? value) {
    medicalNotes = value;
    notifyListeners();
  }

  Future<void> loadExistingProfileIfNeeded() async {
    if (hasCheckedExistingProfile || isCheckingExistingProfile) {
      return;
    }

    isCheckingExistingProfile = true;
    notifyListeners();

    try {
      final profile = await metricsRepository.getMyHealthProfile();
      savedProfile = profile;
      if (profile != null) {
        age = profile.age;
        gender = profile.gender;
        heightCm = profile.heightCm;
        weightKg = profile.weightKg;
        muscleMassKg = profile.muscleMassKg;
        fatPercentage = profile.fatPercentage;
        activityLevel = profile.activityLevel;
        dietGoal = profile.dietGoal;
        dietType = profile.dietType;
        targetWeightKg = profile.targetWeightKg;
        medicalNotes = profile.medicalNotes;
      }
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isCheckingExistingProfile = false;
      hasCheckedExistingProfile = true;
      notifyListeners();
    }
  }

  Future<bool> submitProfile() async {
    if (submissionStatus == OnboardingSubmissionStatus.loading) {
      return false;
    }

    submissionStatus = OnboardingSubmissionStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final model = HealthMetricModel(
        age: age ?? 0,
        weightKg: weightKg ?? 0,
        heightCm: heightCm ?? 0,
        gender: gender ?? '',
        activityLevel: activityLevel ?? '',
        dietGoal: dietGoal ?? '',
        unit: 'metric',
        fatPercentage: fatPercentage,
        muscleMassKg: muscleMassKg,
        medicalNotes: medicalNotes,
        dietType: dietType,
        targetWeightKg: targetWeightKg,
        dailyCalorieTarget: _estimateDailyCalories(),
      );

      savedProfile = await metricsRepository.addHealthProfile(model);
      submissionStatus = OnboardingSubmissionStatus.success;
      notifyListeners();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      submissionStatus = OnboardingSubmissionStatus.error;
      notifyListeners();
      return false;
    }
  }

  void retrySubmission() {
    if (submissionStatus == OnboardingSubmissionStatus.error) {
      submissionStatus = OnboardingSubmissionStatus.initial;
      notifyListeners();
    }
  }

  int _estimateDailyCalories() {
    if (weightKg == null || heightCm == null || age == null || gender == null) {
      return 2000;
    }

    final weight = weightKg!;
    final height = heightCm!;
    final ageValue = age!;
    final genderValue = gender!.toLowerCase();

    final bmr = genderValue == 'female'
        ? 655 + (9.6 * weight) + (1.8 * height) - (4.7 * ageValue)
        : 66 + (13.7 * weight) + (5 * height) - (6.8 * ageValue);

    final activityFactor = switch (activityLevel?.toUpperCase()) {
      'SEDENTARY' => 1.2,
      'LIGHTLY_ACTIVE' => 1.375,
      'MODERATELY_ACTIVE' => 1.55,
      'VERY_ACTIVE' => 1.725,
      _ => 1.3,
    };

    return (bmr * activityFactor).round();
  }
}
