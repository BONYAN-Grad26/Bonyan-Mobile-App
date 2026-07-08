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
      ingredientId: _toInt(json['ingredientId']),
      ingredientName: json['ingredientName']?.toString() ?? '',
      quantity: _toDouble(json['quantity']) ?? 0.0,
      measurementUnit: json['measurementUnit']?.toString() ?? '',
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
    final json = jsonMap.containsKey('data') && jsonMap['data'] is Map ? Map<String, dynamic>.from(jsonMap['data'] as Map) : jsonMap;

    return Meal(
      id: _toInt(json['id']),
      name: (json['name'] ?? json['meal_name'])?.toString() ?? '',
      mealType: (json['mealType'] ?? json['meal_type'])?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      preparationTime: _toInt(json['preparationTime'] ?? json['preparation_time']),
      preparationInstructions: (json['preparationInstructions'] ?? json['preparation_instructions'] ?? json['instructions'])?.toString() ?? '',
      order: _toInt(json['order'] ?? json['meal_order']),
      ingredients: (json['ingredients'] as List?)
          ?.where((e) => e != null)
          .map((item) => Ingredient.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList() ?? [],
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
    final json = jsonMap.containsKey('data') && jsonMap['data'] is Map ? Map<String, dynamic>.from(jsonMap['data'] as Map) : jsonMap;

      List<Meal> parsedMeals = [];
      var rawMeals = (json['data'] is Map) ? json['data']['meals'] : (json['meals'] ?? json['meal_plans']);

      if (rawMeals is List) {
        for (int i = 0; i < rawMeals.length; i++) {
          try {
            Map<String, dynamic> mealMap = Map<String, dynamic>.from(rawMeals[i] as Map);
            parsedMeals.add(Meal.fromJson(mealMap));
          } catch (e) {
            // Silently ignore failed meals
          }
        }
      }

      return DayPlan(
        id: _toInt(json['id']),
        date: (json['date'] ?? json['plan_date'])?.toString() ?? '',
        dayOfWeek: _toInt(json['dayOfWeek'] ?? json['day_of_week']),
        targetCalories: _toDouble(json['targetCalories'] ?? json['target_calories'] ?? json['calories']) ?? 0.0,
        targetProtein: _toDouble(json['targetProtein'] ?? json['target_protein'] ?? json['protein']) ?? 0.0,
        targetCarbs: _toDouble(json['targetCarbs'] ?? json['target_carbs'] ?? json['carbs']) ?? 0.0,
        targetFat: _toDouble(json['targetFat'] ?? json['target_fat'] ?? json['fat']) ?? 0.0,
        targetFiber: _toDouble(json['targetFiber'] ?? json['target_fiber'] ?? json['fiber']) ?? 0.0,
        targetSugar: _toDouble(json['targetSugar'] ?? json['target_sugar'] ?? json['sugar']) ?? 0.0,
        waterGoal: _toDouble(json['waterGoal'] ?? json['water_goal']) ?? 0.0,
        aiDailyTips: (json['aiDailyTips'] ?? json['ai_tips'] ?? json['tips'])?.toString() ?? '',
        meals: parsedMeals,
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
    final json = jsonMap.containsKey('data') && jsonMap['data'] is Map ? Map<String, dynamic>.from(jsonMap['data'] as Map) : jsonMap;

    return WeeklyPlan(
      id: _toInt(json['id']),
      weekNumber: _toInt(json['weekNumber'] ?? json['week_number']),
      startDate: (json['startDate'] ?? json['start_date'])?.toString(),
      endDate: (json['endDate'] ?? json['end_date'])?.toString(),
      weeklyCalorieTarget: _toDouble(json['weeklyCalorieTarget'] ?? json['weekly_calorie_target']),
      weeklyProteinTarget: _toDouble(json['weeklyProteinTarget'] ?? json['weekly_protein_target']),
      weeklyCarbTarget: _toDouble(json['weeklyCarbTarget'] ?? json['weekly_carb_target']),
      weeklyFatTarget: _toDouble(json['weeklyFatTarget'] ?? json['weekly_fat_target']),
      weeklyStrategy: (json['weeklyStrategy'] ?? json['weekly_strategy'])?.toString(),
      aiPreparationTips: (json['aiPreparationTips'] ?? json['ai_prep_tips'])?.toString(),
      days: ((json['days'] ?? json['dailyPlans'] ?? json['daily_plans']) as List?)
          ?.where((e) => e != null)
          .map((item) => DayPlan.fromJson(Map<String, dynamic>.from(item as Map)))
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

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
