// Workout Plan and Exercise models

/// Represents a single exercise
class Exercise {
  final String? name;
  final int? sets;
  final String? reps; // e.g., "8-10", "5", "AMRAP"
  final int? restSeconds;
  final String? notes;

  Exercise({
    this.name,
    this.sets,
    this.reps,
    this.restSeconds,
    this.notes,
  });

  factory Exercise.fromJson(Map<String, dynamic> jsonMap) {
    final json = jsonMap.containsKey('data') && jsonMap['data'] is Map<String, dynamic>
        ? jsonMap['data'] as Map<String, dynamic>
        : jsonMap;

    return Exercise(
      name: (json['name'] ?? json['exerciseName'])?.toString(),
      sets: (json['sets'] ?? json['setCount']) != null ? int.tryParse((json['sets'] ?? json['setCount']).toString()) : null,
      reps: (json['reps'] ?? json['repCount'])?.toString(),
      restSeconds: (json['rest_seconds'] ?? json['restSeconds']) != null ? int.tryParse((json['rest_seconds'] ?? json['restSeconds']).toString()) : null,
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (sets != null) 'sets': sets,
      if (reps != null) 'reps': reps,
      if (restSeconds != null) 'rest_seconds': restSeconds,
      if (notes != null) 'notes': notes,
    };
  }

  @override
  String toString() => 'Exercise(name: $name, sets: $sets x $reps)';
}

/// Represents a single workout day/session
class WorkoutDay {
  final String? dayName;
  final String? session; // e.g., "Upper Body A", "Lower Body B"
  final String? focus; // e.g., "Chest, Back, Shoulders"
  final List<Exercise>? exercises;

  WorkoutDay({
    this.dayName,
    this.session,
    this.focus,
    this.exercises,
  });

  factory WorkoutDay.fromJson(Map<String, dynamic> jsonMap) {
    final json = jsonMap.containsKey('data') && jsonMap['data'] is Map<String, dynamic>
        ? jsonMap['data'] as Map<String, dynamic>
        : jsonMap;

    return WorkoutDay(
      dayName: json['day_name']?.toString() ?? json['dayName']?.toString(),
      session: json['session']?.toString(),
      focus: json['focus']?.toString(),
      // BUG FIX: Loosened the List check and safely cast the Maps
      exercises: (json['exercises'] as List?)
          ?.where((e) => e != null)
          .map((e) => Exercise.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (session != null) 'session': session,
      if (focus != null) 'focus': focus,
      if (exercises != null) 'exercises': exercises!.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() => 'WorkoutDay(session: $session, exercises: ${exercises?.length})';
}

/// Represents a complete weekly workout plan
class WorkoutPlan {
  final String? planName; // e.g., "Push/Pull/Legs"
  final String? splitType; // e.g., "PPL", "Upper/Lower", "FullBody"
  final String? splitReasoning; // Why this split was chosen
  final Map<String, WorkoutDay>? weeklySchedule; // Keys: "Monday", "Tuesday", etc.

  WorkoutPlan({
    this.planName,
    this.splitType,
    this.splitReasoning,
    this.weeklySchedule,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> jsonMap) {
    final json = jsonMap.containsKey('data') && jsonMap['data'] is Map<String, dynamic>
        ? jsonMap['data'] as Map<String, dynamic>
        : jsonMap;

    List<WorkoutDay> parsedDays = [];
    final scheduleMap = json['weekly_schedule'] ?? json['weeklySchedule'];

    if (scheduleMap != null && scheduleMap is Map) {
      scheduleMap.forEach((dayName, dayData) {
        // BUG FIX: Removed the strict <String, dynamic> check here!
        if (dayData != null && dayData is Map) {
          // This safely forces the dynamic map into the exact type we need
          final Map<String, dynamic> mutableDayData = Map<String, dynamic>.from(dayData);
          mutableDayData['day_name'] = dayName.toString();
          parsedDays.add(WorkoutDay.fromJson(mutableDayData));
        }
      });
    }

    final weeklyMap = {
      for (var day in parsedDays)
        if (day.dayName != null) day.dayName!: day
    };

    return WorkoutPlan(
      planName: (json['plan_name'] ?? json['planName'])?.toString(),
      splitType: (json['split_type'] ?? json['splitType'])?.toString(),
      splitReasoning: (json['split_reasoning'] ?? json['splitReasoning'])?.toString(),
      weeklySchedule: weeklyMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (planName != null) 'plan_name': planName,
      if (splitType != null) 'split_type': splitType,
      if (splitReasoning != null) 'split_reasoning': splitReasoning,
      if (weeklySchedule != null)
        'weekly_schedule': weeklySchedule!.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  @override
  String toString() => 'WorkoutPlan(name: $planName, type: $splitType, days: ${weeklySchedule?.length})';
}

/// Represents today's workout session
class TodayWorkout {
  final String? session;
  final String? focus;
  final List<Exercise>? exercises;
  final DateTime? date;

  TodayWorkout({
    this.session,
    this.focus,
    this.exercises,
    this.date,
  });

  factory TodayWorkout.fromJson(Map<String, dynamic> jsonMap) {
    final json = jsonMap.containsKey('data') && jsonMap['data'] is Map<String, dynamic>
        ? jsonMap['data'] as Map<String, dynamic>
        : jsonMap;

    return TodayWorkout(
      session: json['session'] as String?,
      focus: json['focus'] as String?,
      exercises: (json['exercises'] as List?)
          ?.map((item) => Exercise.fromJson(item as Map<String, dynamic>))
          .toList(),
      date: json['date'] != null ? DateTime.tryParse(json['date'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (session != null) 'session': session,
      if (focus != null) 'focus': focus,
      if (exercises != null) 'exercises': exercises!.map((e) => e.toJson()).toList(),
      if (date != null) 'date': date!.toIso8601String(),
    };
  }

  @override
  String toString() => 'TodayWorkout(session: $session, exercises: ${exercises?.length})';
}
