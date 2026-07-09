class ReadGoalDto {
  final int? id;
  final String? goalType;
  final String? description;
  final int? userId;
  final double? targetWeight;
  final double? targetBodyFat;
  final double? targetCalories;
  final String? startDate;
  final String? targetDate;
  final String? status;
  final int? totalDietPlans;
  final int? completedDietPlans;
  final List<int>? dietPlanIds;

  ReadGoalDto({
    this.id,
    this.goalType,
    this.description,
    this.userId,
    this.targetWeight,
    this.targetBodyFat,
    this.targetCalories,
    this.startDate,
    this.targetDate,
    this.status,
    this.totalDietPlans,
    this.completedDietPlans,
    this.dietPlanIds,
  });

  factory ReadGoalDto.fromJson(Map<String, dynamic> jsonMap) {
    final data = jsonMap.containsKey('data') && jsonMap['data'] is Map<String, dynamic>
        ? jsonMap['data'] as Map<String, dynamic>
        : jsonMap;

    return ReadGoalDto(
      id: data['id'] as int?,
      goalType: data['goalType'] as String?,
      description: data['description'] as String?,
      userId: data['userId'] as int?,
      targetWeight: (data['targetWeight'] as num?)?.toDouble(),
      targetBodyFat: (data['targetBodyFat'] as num?)?.toDouble(),
      targetCalories: (data['targetCalories'] as num?)?.toDouble(),
      startDate: data['startDate'] as String?,
      targetDate: data['targetDate'] as String?,
      status: data['status'] as String?,
      totalDietPlans: data['totalDietPlans'] as int?,
      completedDietPlans: data['completedDietPlans'] as int?,
      dietPlanIds: (data['dietPlanIds'] as List<dynamic>?)?.map((e) => e as int).toList(),
    );
  }
}

class GoalSummaryDto {
  final int? id;
  final String? title;
  final double? progressPercentage;
  final String? status;
  final int? daysRemaining;
  final String? type;

  GoalSummaryDto({
    this.id,
    this.title,
    this.progressPercentage,
    this.status,
    this.daysRemaining,
    this.type,
  });

  factory GoalSummaryDto.fromJson(Map<String, dynamic> jsonMap) {
    final data = jsonMap.containsKey('data') && jsonMap['data'] is Map<String, dynamic>
        ? jsonMap['data'] as Map<String, dynamic>
        : jsonMap;

    return GoalSummaryDto(
      id: data['id'] as int?,
      title: data['title'] as String?,
      progressPercentage: (data['progressPercentage'] as num?)?.toDouble(),
      status: data['status'] as String?,
      daysRemaining: data['daysRemaining'] as int?,
      type: data['type'] as String?,
    );
  }
}

class CreateGoalDto {
  final String? goalType;
  final String? description;
  final double? targetWeight;
  final double? targetBodyFat;
  final String? startDate;
  final String? targetDate;

  CreateGoalDto({
    this.goalType,
    this.description,
    this.targetWeight,
    this.targetBodyFat,
    this.startDate,
    this.targetDate,
  });

  Map<String, dynamic> toJson() {
    return {
      if (goalType != null) 'goalType': goalType,
      if (description != null) 'description': description,
      if (targetWeight != null) 'targetWeight': targetWeight,
      if (targetBodyFat != null) 'targetBodyFat': targetBodyFat,
      if (startDate != null) 'startDate': startDate,
      if (targetDate != null) 'targetDate': targetDate,
    };
  }
}

class UpdateGoalDto {
  final String? goalType;
  final String? description;
  final double? targetWeight;
  final double? targetBodyFat;
  final String? startDate;
  final String? targetDate;

  UpdateGoalDto({
    this.goalType,
    this.description,
    this.targetWeight,
    this.targetBodyFat,
    this.startDate,
    this.targetDate,
  });

  Map<String, dynamic> toJson() {
    return {
      if (goalType != null) 'goalType': goalType,
      if (description != null) 'description': description,
      if (targetWeight != null) 'targetWeight': targetWeight,
      if (targetBodyFat != null) 'targetBodyFat': targetBodyFat,
      if (startDate != null) 'startDate': startDate,
      if (targetDate != null) 'targetDate': targetDate,
    };
  }
}
