import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/models.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class WorkoutsTab extends StatefulWidget {
  const WorkoutsTab({super.key});

  @override
  State<WorkoutsTab> createState() => _WorkoutsTabState();
}

class _WorkoutsTabState extends State<WorkoutsTab> {
  DateTime _selectedDate = DateTime.now();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final workoutProvider = context.read<WorkoutProvider>();
    // Force the fetch regardless of authProvider state
    await workoutProvider.fetchCurrentWorkoutPlan(); 
  }

  Future<void> _generatePlan() async {
    setState(() => _isGenerating = true);
    final success = await context.read<WorkoutProvider>().generateWeeklyPlan();
    
    if (mounted) {
      setState(() => _isGenerating = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout plan generated successfully!')),
        );
        await _loadData();
      } else {
        final wp = context.read<WorkoutProvider>();
        final error = wp.generationError ?? wp.errorMessage ?? 'Failed to generate plan.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
        if (wp.generationError != null) {
          _loadData();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final workoutProvider = context.watch<WorkoutProvider>();
    final progressProvider = context.watch<ProgressProvider>();

    if (workoutProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (workoutProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(workoutProvider.errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final currentPlan = workoutProvider.currentPlan;
    final weeklySchedule = currentPlan?.weeklySchedule ?? {};

    String getWeekday(DateTime d) {
      return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][d.weekday - 1];
    }
    String getShortWeekday(DateTime d) {
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];
    }

    final selectedWeekday = getWeekday(_selectedDate);
    final selectedWorkoutDay = weeklySchedule[selectedWeekday];
    
    final displayWorkouts = <WorkoutDay>[];
    if (selectedWorkoutDay != null && selectedWorkoutDay.exercises != null && selectedWorkoutDay.exercises!.isNotEmpty) {
      displayWorkouts.add(selectedWorkoutDay);
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workout Plans',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your AI-powered personalized training program',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.70),
                            ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
            const SizedBox(height: 24),
            Text(
              'This Week’s Split',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < 7; i++)
                    Builder(builder: (context) {
                      // Generate the dates for the current week starting from Monday
                      final currentDay = DateTime.now();
                      final startOfWeek = currentDay.subtract(Duration(days: currentDay.weekday - 1));
                      final dayDate = startOfWeek.add(Duration(days: i));
                      final dayName = getWeekday(dayDate);
                      final dayShortName = getShortWeekday(dayDate);
                      
                      final wDay = weeklySchedule[dayName];
                      final isRest = wDay == null || wDay.exercises == null || wDay.exercises!.isEmpty;
                      final isSelected = dayDate.year == _selectedDate.year && dayDate.month == _selectedDate.month && dayDate.day == _selectedDate.day;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = dayDate;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Container(
                            width: 92,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primary.withValues(alpha: 0.12)
                                  : colorScheme.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.outline.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  dayShortName,
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isRest || (wDay != null && progressProvider.isWorkoutCompleted((wDay.session ?? 'Workout').hashCode))) ...[
                                      Icon(Icons.check_circle, size: 14, color: colorScheme.primary),
                                      const SizedBox(width: 4),
                                    ],
                                    Flexible(
                                      child: Text(
                                        isRest ? 'Rest' : (wDay!.session?.split(' ').first ?? 'Workout'),
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurface,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Workouts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            if (displayWorkouts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.16)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fitness_center, size: 64, color: colorScheme.primary.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text(
                      currentPlan == null ? 'No Workouts Scheduled' : 'Rest Day',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentPlan == null 
                        ? 'Generate your AI-powered weekly workout plan to see your personalized schedule for today.'
                        : 'Take a well-deserved rest today. Your body needs it to recover and build muscle!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.70),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (currentPlan == null)
                      ElevatedButton.icon(
                        onPressed: _isGenerating ? null : _generatePlan,
                        icon: _isGenerating 
                            ? SizedBox(
                                width: 18, height: 18, 
                                child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary)
                              )
                            : const Icon(Icons.auto_awesome),
                        label: const Text('Generate AI Plan', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              Column(
                children: displayWorkouts.map((workout) {
                  // Workout is a WorkoutDay
                  final name = workout.session ?? 'Workout Session';
                  final type = 'Daily Session';
                  final exercisesCount = workout.exercises?.length ?? 0;
                  final duration = '${exercisesCount * 5 + 10} min'; // Est: 5m per exercise + 10m warmup
                  final scheduled = _selectedDate.toIso8601String().split('T')[0];
                  
                  final focusAreas = <String>[];
                  if (workout.focus != null) {
                    focusAreas.addAll(workout.focus!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty));
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.16)),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.fitness_center, color: colorScheme.primary, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          type,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: colorScheme.onSurface.withValues(alpha: 0.65),
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      name,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.schedule, size: 16, color: colorScheme.onSurface.withValues(alpha: 0.65)),
                                        const SizedBox(width: 6),
                                        Text(
                                          scheduled,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: colorScheme.onSurface.withValues(alpha: 0.65),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Checkbox(
                                value: progressProvider.isWorkoutCompleted(name.hashCode),
                                onChanged: (val) => progressProvider.toggleWorkout(name.hashCode, val ?? false),
                              ),

                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildWorkoutStat(context, 'Duration', duration),
                              const SizedBox(width: 8),
                              _buildWorkoutStat(context, 'Exercises', '$exercisesCount'),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Focus Areas',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: colorScheme.onSurface.withOpacity(0.65),
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (focusAreas.isNotEmpty)
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: focusAreas
                                            .map((area) => Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: colorScheme.primary.withOpacity(0.12),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    area,
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                          color: colorScheme.primary,
                                                        ),
                                                  ),
                                                ))
                                            .toList(),
                                      )
                                    else
                                      Text(
                                        'N/A',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: colorScheme.onSurface.withOpacity(0.65),
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                int totalWorkouts = 0;
                int totalDuration = 0;
                if (workoutProvider.currentPlan?.weeklySchedule != null) {
                  workoutProvider.currentPlan!.weeklySchedule!.forEach((day, workout) {
                    if (workout.session != null && !workout.session!.toLowerCase().contains('rest')) {
                      totalWorkouts++;
                      totalDuration += 45; // Default to 45 mins per workout
                    }
                  });
                }
                if (totalWorkouts == 0) {
                  totalWorkouts = 5;
                  totalDuration = 5 * 45;
                }

                int completedWorkouts = progressProvider.completedWorkoutsCount;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colorScheme.outline.withOpacity(0.16)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Week’s Stats',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatsRow(context, 'Completed', '$completedWorkouts / $totalWorkouts', completedWorkouts / totalWorkouts, colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Total Duration',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.65),
                            ),
                      ),
                      Text(
                        '${(totalDuration / 60).toStringAsFixed(1)} hrs',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Est. Calories Burned',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.65),
                            ),
                      ),
                      Text(
                        '${(totalDuration * 8)}', // 8 calories per minute average
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                );
              }
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutStat(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.65),
                  ),
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, String label, String value, double progress, Color accent) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.65),
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 8,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: colorScheme.outline.withOpacity(0.18),
            borderRadius: BorderRadius.circular(99),
          ),
          child: FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      ],
    );
  }
}