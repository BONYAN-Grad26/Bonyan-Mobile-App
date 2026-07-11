import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bonyaan_app/core/models/models.dart';
import 'package:bonyaan_app/core/providers/providers.dart';
import '../widgets/machine_classifier_sheet.dart';

class WorkoutsTab extends StatefulWidget {
  const WorkoutsTab({super.key});

  @override
  State<WorkoutsTab> createState() => _WorkoutsTabState();
}

class _WorkoutsTabState extends State<WorkoutsTab> {
  DateTime _selectedDate = DateTime.now();
  bool _isGenerating = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData([bool isRefresh = false]) async {
    final workoutProvider = context.read<WorkoutProvider>();
    
    final futures = <Future<void>>[];
    
    if (isRefresh || workoutProvider.currentPlan == null) {
      futures.add(workoutProvider.fetchCurrentWorkoutPlan());
    }
    
    if (isRefresh || workoutProvider.todayWorkout == null) {
      futures.add(workoutProvider.fetchTodayWorkout());
    }
    
    if (futures.isNotEmpty) {
      await Future.wait(futures.map((f) => f.catchError((e) {
        debugPrint('Workout background load error: $e');
      })));
    }
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final workoutProvider = context.watch<WorkoutProvider>();
    final progressProvider = context.watch<ProgressProvider>();

    // Loading State - Only show full screen if we have no data at all
    if (workoutProvider.isLoading && workoutProvider.currentPlan == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentPlan = workoutProvider.currentPlan;
    final todayWorkout = workoutProvider.todayWorkout;

    // Error State - Only show full error if we have absolutely no data to show
    final hasNoData = currentPlan == null && todayWorkout == null;
    if (workoutProvider.errorMessage != null && hasNoData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Workout API Error',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(workoutProvider.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () => _loadData(true), child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final weeklySchedule = currentPlan?.weeklySchedule ?? {};

    String getWeekdayName(DateTime d) => ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][d.weekday - 1];
    String getShortWeekday(DateTime d) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];

    final selectedWeekday = getWeekdayName(_selectedDate);
    final isSelectedToday = _selectedDate.day == DateTime.now().day && 
                           _selectedDate.month == DateTime.now().month && 
                           _selectedDate.year == DateTime.now().year;

    WorkoutDay? selectedWorkoutDay = weeklySchedule[selectedWeekday];
    
    // Fallback logic: If selected day is today and we have a todayWorkout, use it
    if (isSelectedToday && todayWorkout != null) {
      if (selectedWorkoutDay == null || (selectedWorkoutDay.exercises?.isEmpty ?? true)) {
        selectedWorkoutDay = WorkoutDay(
          session: todayWorkout.session,
          focus: todayWorkout.focus,
          exercises: todayWorkout.exercises,
        );
      }
    }

    final displayWorkouts = <WorkoutDay>[];
    if (selectedWorkoutDay != null && selectedWorkoutDay.exercises != null && selectedWorkoutDay.exercises!.isNotEmpty) {
      displayWorkouts.add(selectedWorkoutDay);
    }

    return RefreshIndicator(
      onRefresh: () => _loadData(true),
      displacement: 40,
      edgeOffset: 20,
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverSafeArea(
            bottom: false,
            sliver: SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 20), // Added whitespace at the top
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(context, colorScheme),
                  const SizedBox(height: 24),
                  _buildScannerButton(context, colorScheme),
                  const SizedBox(height: 24),
                  _buildWeekSplit(context, weeklySchedule, colorScheme, progressProvider, getWeekdayName, getShortWeekday),
                  const SizedBox(height: 24),
                  _buildWorkoutList(context, displayWorkouts, currentPlan, colorScheme, progressProvider),
                  const SizedBox(height: 24),
                  _buildStatsCard(context, displayWorkouts, progressProvider, colorScheme),
                  const SizedBox(height: 120), // Padding for nav bar
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Workout Plans', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          'Your AI-powered personalized training program',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.70),
          ),
        ),
      ],
    );
  }

  Widget _buildScannerButton(BuildContext context, ColorScheme colorScheme) {
    return ElevatedButton.icon(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const MachineClassifierSheet(),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      icon: const Icon(Icons.document_scanner_outlined),
      label: const Text('Identify Gym Machine', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildWeekSplit(BuildContext context, Map<String, WorkoutDay> weeklySchedule, ColorScheme colorScheme, ProgressProvider progressProvider, Function getWeekdayName, Function getShortWeekday) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('This Week’s Split', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          child: Row(
            children: [
              for (var i = 0; i < 7; i++)
                Builder(builder: (context) {
                  final startOfWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
                  final dayDate = startOfWeek.add(Duration(days: i));
                  final dayName = getWeekdayName(dayDate);
                  final isSelected = dayDate.year == _selectedDate.year && dayDate.month == _selectedDate.month && dayDate.day == _selectedDate.day;
                  final wDay = weeklySchedule[dayName];
                  final isRest = wDay == null || wDay.exercises == null || wDay.exercises!.isEmpty;
                  final isDone = isRest || progressProvider.isWorkoutCompleted((wDay.session ?? 'Workout').hashCode);

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = dayDate),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                        width: 92,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected ? colorScheme.primary.withValues(alpha: 0.12) : colorScheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: isSelected ? colorScheme.primary : colorScheme.outline),
                        ),
                        child: Column(
                          children: [
                            Text(getShortWeekday(dayDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Icon(isDone ? Icons.check_circle : Icons.circle_outlined, size: 16, color: colorScheme.primary),
                            Text(isRest ? 'Rest' : 'Workout', style: const TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutList(BuildContext context, List<WorkoutDay> workouts, dynamic currentPlan, ColorScheme colorScheme, ProgressProvider progressProvider) {
    if (workouts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: colorScheme.outline)),
        child: Column(
          children: [
            Icon(Icons.fitness_center, size: 48, color: colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(currentPlan == null ? 'No Schedule' : 'Rest Day', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Text(currentPlan == null ? 'Generate a plan to begin.' : 'Enjoy your recovery day!', textAlign: TextAlign.center),
            if (currentPlan == null) ...[
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _isGenerating ? null : _generatePlan, child: const Text('Generate AI Plan')),
            ]
          ],
        ),
      );
    }

    return Column(
      children: workouts.map((w) {
        final workoutId = (w.session ?? 'Workout').hashCode;
        final exercises = w.exercises ?? [];
        final isWorkoutDone = progressProvider.isWorkoutCompleted(workoutId);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: colorScheme.outline)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(w.session ?? 'Workout', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                  Checkbox(
                    value: isWorkoutDone,
                    onChanged: (v) async {
                      final newValue = v ?? false;
                      await progressProvider.toggleWorkout(workoutId, newValue);
                      // Toggle all exercises in this workout
                      for (var e in exercises) {
                        await progressProvider.toggleExercise(workoutId, e.name ?? '', newValue);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Focus: ${w.focus ?? 'General'}', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)),
              const Divider(height: 32),
              ... exercises.map((e) {
                final exerciseName = e.name ?? 'Exercise';
                final isExerciseDone = progressProvider.isExerciseCompleted(workoutId, exerciseName);
                
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(exerciseName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${e.sets} sets x ${e.reps} reps'),
                  trailing: Checkbox(
                    value: isExerciseDone,
                    onChanged: (v) async {
                      final newValue = v ?? false;
                      await progressProvider.toggleExercise(workoutId, exerciseName, newValue);
                      
                      // Update main workout checkbox based on all exercises
                      final allExercisesDone = exercises.every((ex) => progressProvider.isExerciseCompleted(workoutId, ex.name ?? ''));
                      if (allExercisesDone != isWorkoutDone) {
                        await progressProvider.toggleWorkout(workoutId, allExercisesDone);
                      }
                    },
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsCard(BuildContext context, List<WorkoutDay> displayWorkouts, ProgressProvider progress, ColorScheme colorScheme) {
    if (displayWorkouts.isEmpty) return const SizedBox.shrink();

    int totalTasks = 0;
    int completedTasks = 0;

    for (var w in displayWorkouts) {
      final workoutId = (w.session ?? 'Workout').hashCode;
      final exercises = w.exercises ?? [];
      for (var e in exercises) {
        totalTasks++;
        if (progress.isExerciseCompleted(workoutId, e.name ?? '')) {
          completedTasks++;
        }
      }
    }

    if (totalTasks == 0) return const SizedBox.shrink();

    final progressValue = completedTasks / totalTasks;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: colorScheme.outline)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today’s Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tasks Completed'),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: completedTasks.toDouble()),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, animValue, child) {
                  return Text(
                    '${animValue.toInt()} / $totalTasks',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progressValue.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                color: colorScheme.primary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(9),
              );
            },
          ),
        ],
      ),
    );
  }
}
