// Diet Plan, Meals, and Ingredient models

/// Represents an ingredient in a meal
class Ingredient {
  final int? ingredientId;
  final String? ingredientName;
  final double? quantity;
  final String? measurementUnit;

  Ingredient({
    this.ingredientId,
    this.ingredientName,
    this.quantity,
    this.measurementUnit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      ingredientId: json['ingredientId'] as int?,
      ingredientName: json['ingredientName'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      measurementUnit: json['measurementUnit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (ingredientId != null) 'ingredientId': ingredientId,
      if (ingredientName != null) 'ingredientName': ingredientName,
      if (quantity != null) 'quantity': quantity,
      if (measurementUnit != null) 'measurementUnit': measurementUnit,
    };
  }

  @override
  String toString() => 'Ingredient(name: $ingredientName, qty: $quantity $measurementUnit)';
}

/// Represents a single meal
class Meal {
  final int? id;
  final String? name;
  final String? mealType; // Breakfast, Lunch, Dinner, Snack
  final String? description;
  final int? preparationTime;
  final String? preparationInstructions;
  final int? order;
  final List<Ingredient>? ingredients;

  Meal({
    this.id,
    this.name,
    this.mealType,
    this.description,
    this.preparationTime,
    this.preparationInstructions,
    this.order,
    this.ingredients,
  });

  factory Meal.fromJson(Map<String, dynamic> jsonMap) {
    final json = jsonMap.containsKey('data') && jsonMap['data'] is Map<String, dynamic>
        ? jsonMap['data'] as Map<String, dynamic>
        : jsonMap;

    return Meal(
      id: json['id'] as int?,
      name: json['name'] as String?,
      mealType: json['mealType'] as String?,
      description: json['description'] as String?,
      preparationTime: json['preparationTime'] as int?,
      preparationInstructions: json['preparationInstructions'] as String?,
      order: json['order'] as int?,
      ingredients: (json['ingredients'] as List?)
          ?.map((item) => Ingredient.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (mealType != null) 'mealType': mealType,
      if (description != null) 'description': description,
      if (preparationTime != null) 'preparationTime': preparationTime,
      if (preparationInstructions != null) 'preparationInstructions': preparationInstructions,
      if (order != null) 'order': order,
      if (ingredients != null) 'ingredients': ingredients!.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() => 'Meal(name: $name, type: $mealType, ingredients: ${ingredients?.length})';
}

/// Represents a single day's meal plan
class DayPlan {
  final int? id;
  final String? date;
  final int? dayOfWeek; // 1-7 (Monday-Sunday)
  final double? targetCalories;
  final double? targetProtein;
  final double? targetCarbs;
  final double? targetFat;
  final double? targetFiber;
  final double? targetSugar;
  final double? waterGoal;
  final String? aiDailyTips;
  final List<Meal>? meals;

  DayPlan({
    this.id,
    this.date,
    this.dayOfWeek,
    this.targetCalories,
    this.targetProtein,
    this.targetCarbs,
    this.targetFat,
    this.targetFiber,
    this.targetSugar,
    this.waterGoal,
    this.aiDailyTips,
    this.meals,
  });

  factory DayPlan.fromJson(Map<String, dynamic> jsonMap) {
    final json = jsonMap.containsKey('data') && jsonMap['data'] is Map<String, dynamic>
        ? jsonMap['data'] as Map<String, dynamic>
        : jsonMap;

    return DayPlan(
      id: json['id'] as int?,
      date: json['date'] as String?,
      dayOfWeek: json['dayOfWeek'] as int?,
      targetCalories: (json['targetCalories'] as num?)?.toDouble(),
      targetProtein: (json['targetProtein'] as num?)?.toDouble(),
      targetCarbs: (json['targetCarbs'] as num?)?.toDouble(),
      targetFat: (json['targetFat'] as num?)?.toDouble(),
      targetFiber: (json['targetFiber'] as num?)?.toDouble(),
      targetSugar: (json['targetSugar'] as num?)?.toDouble(),
      waterGoal: (json['waterGoal'] as num?)?.toDouble(),
      aiDailyTips: json['aiDailyTips'] as String?,
      meals: (json['meals'] as List?)
          ?.map((item) => Meal.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (dayOfWeek != null) 'dayOfWeek': dayOfWeek,
      if (targetCalories != null) 'targetCalories': targetCalories,
      if (targetProtein != null) 'targetProtein': targetProtein,
      if (targetCarbs != null) 'targetCarbs': targetCarbs,
      if (targetFat != null) 'targetFat': targetFat,
      if (targetFiber != null) 'targetFiber': targetFiber,
      if (targetSugar != null) 'targetSugar': targetSugar,
      if (waterGoal != null) 'waterGoal': waterGoal,
      if (aiDailyTips != null) 'aiDailyTips': aiDailyTips,
      if (meals != null) 'meals': meals!.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() => 'DayPlan(date: $date, meals: ${meals?.length}, calories: $targetCalories)';
}

/// Represents a weekly meal plan
class WeeklyPlan {
  final int? id;
  final int? weekNumber;
  final String? startDate;
  final String? endDate;
  final double? weeklyCalorieTarget;
  final double? weeklyProteinTarget;
  final double? weeklyCarbTarget;
  final double? weeklyFatTarget;
  final String? weeklyStrategy;
  final String? aiPreparationTips;
  final List<DayPlan>? days;

  WeeklyPlan({
    this.id,
    this.weekNumber,
    this.startDate,
    this.endDate,
    this.weeklyCalorieTarget,
    this.weeklyProteinTarget,
    this.weeklyCarbTarget,
    this.weeklyFatTarget,
    this.weeklyStrategy,
    this.aiPreparationTips,
    this.days,
  });

  factory WeeklyPlan.fromJson(Map<String, dynamic> jsonMap) {
    final json = jsonMap.containsKey('data') && jsonMap['data'] is Map<String, dynamic>
        ? jsonMap['data'] as Map<String, dynamic>
        : jsonMap;

    return WeeklyPlan(
      id: json['id'] as int?,
      weekNumber: json['weekNumber'] as int?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      weeklyCalorieTarget: (json['weeklyCalorieTarget'] as num?)?.toDouble(),
      weeklyProteinTarget: (json['weeklyProteinTarget'] as num?)?.toDouble(),
      weeklyCarbTarget: (json['weeklyCarbTarget'] as num?)?.toDouble(),
      weeklyFatTarget: (json['weeklyFatTarget'] as num?)?.toDouble(),
      weeklyStrategy: json['weeklyStrategy'] as String?,
      aiPreparationTips: json['aiPreparationTips'] as String?,
      days: ((json['days'] ?? json['dailyPlans']) as List?)
          ?.map((item) => DayPlan.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (weekNumber != null) 'weekNumber': weekNumber,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      if (weeklyCalorieTarget != null) 'weeklyCalorieTarget': weeklyCalorieTarget,
      if (weeklyProteinTarget != null) 'weeklyProteinTarget': weeklyProteinTarget,
      if (weeklyCarbTarget != null) 'weeklyCarbTarget': weeklyCarbTarget,
      if (weeklyFatTarget != null) 'weeklyFatTarget': weeklyFatTarget,
      if (weeklyStrategy != null) 'weeklyStrategy': weeklyStrategy,
      if (aiPreparationTips != null) 'aiPreparationTips': aiPreparationTips,
      if (days != null) 'days': days!.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() =>
      'WeeklyPlan(week: $weekNumber, start: $startDate, days: ${days?.length}, calories: $weeklyCalorieTarget)';
}
