import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../core/widgets/bonyaan_logo.dart';
import '../widgets/metric_card.dart';

class HomeTab extends StatefulWidget {
  final void Function(int)? onNavigate;

  const HomeTab({super.key, this.onNavigate});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final profileProvider = context.read<ProfileProvider>();
    final dietProvider = context.read<DietPlanProvider>();
    final workoutProvider = context.read<WorkoutProvider>();

    final futures = <Future<void>>[
      profileProvider.fetchMyHealthProfile(),
      dietProvider.fetchTodayPlan(),
      workoutProvider.fetchCurrentWorkoutPlan(),
    ];
    
    await Future.wait(futures);

    if (dietProvider.currentPlan == null || (dietProvider.currentPlan?.days?.isEmpty ?? true)) {
      await dietProvider.fetchWeeklyPlans();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final dietProvider = context.watch<DietPlanProvider>();
    final workoutProvider = context.watch<WorkoutProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    // Loading State
    if (profileProvider.isLoading || dietProvider.isLoading || workoutProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error State
    if (profileProvider.errorMessage != null || 
        dietProvider.errorMessage != null || 
        workoutProvider.errorMessage != null) {
      final error = profileProvider.errorMessage ?? 
                    dietProvider.errorMessage ?? 
                    workoutProvider.errorMessage;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(error ?? 'An error occurred', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final userName = authProvider.currentUser?.firstName;
    final greetingName = progressProvider.customFirstName.isNotEmpty 
        ? progressProvider.customFirstName 
        : ((userName == null || userName.isEmpty) ? 'User' : userName);

    final metrics = profileProvider.healthMetrics;
    
    // Goals from health profile and diet plan
    final int caloriesGoal = dietProvider.todayPlan?.targetCalories?.toInt() ?? metrics?.dailyCalorieTarget ?? 2200;
    final int proteinGoal = dietProvider.todayPlan?.targetProtein?.toInt() ?? (metrics?.weightKg != null ? (metrics!.weightKg! * 2).round() : 150);
    
    // Current progress
    int caloriesCurrent = 0;
    int proteinCurrent = 0;

    if (dietProvider.todayPlan?.meals != null && dietProvider.todayPlan!.meals!.isNotEmpty) {
      int mealCount = dietProvider.todayPlan!.meals!.length;
      for (final meal in dietProvider.todayPlan!.meals!) {
        final d = dietProvider.todayPlan!.dayOfWeek ?? 0;
        final mId = meal.id ?? meal.name.hashCode;
        final uniqueId = d * 100000 + (mId.abs() % 100000);
        if (progressProvider.isMealCompleted(uniqueId)) {
          caloriesCurrent += (caloriesGoal / mealCount).round();
          proteinCurrent += (proteinGoal / mealCount).round();
        }
      }
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          SliverSafeArea(
            bottom: false,
            sliver: SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Good morning, $greetingName!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const BonyaanLogo.small(),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.02,
              ),
              delegate: SliverChildListDelegate(
                [
                  MetricCard(
                    title: 'Calories',
                    value: '$caloriesCurrent',
                    unit: 'kcal',
                    icon: Icons.local_fire_department,
                    variant: MetricVariant.nutrition,
                    progress: caloriesCurrent / caloriesGoal * 100,
                  ),
                  MetricCard(
                    title: 'Protein',
                    value: '$proteinCurrent',
                    unit: 'g',
                    icon: Icons.restaurant,
                    variant: MetricVariant.health,
                    progress: proteinCurrent / proteinGoal * 100,
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Week’s Progress',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  (() {
                    int totalMeals = 0;
                    int completedMeals = 0;
                    if (dietProvider.currentPlan?.days != null && dietProvider.currentPlan!.days!.isNotEmpty) {
                      for (final day in dietProvider.currentPlan!.days!) {
                        if (day.meals != null) {
                          totalMeals += day.meals!.length;
                          for (final meal in day.meals!) {
                            final d = day.dayOfWeek ?? 0;
                            final mId = meal.id ?? meal.name.hashCode;
                            final uniqueId = d * 100000 + (mId.abs() % 100000);
                            if (progressProvider.isMealCompleted(uniqueId)) {
                              completedMeals++;
                            }
                          }
                        }
                      }
                    }
                    if (totalMeals == 0) totalMeals = 21;
                    
                    int totalWorkouts = 0;
                    if (workoutProvider.currentPlan?.weeklySchedule != null) {
                      for (final day in workoutProvider.currentPlan!.weeklySchedule!.values) {
                        if (day.exercises != null && day.exercises!.isNotEmpty) {
                          totalWorkouts++;
                        }
                      }
                    }
                    if (totalWorkouts == 0) totalWorkouts = 4;

                    int completedWorkouts = 0;
                    if (workoutProvider.currentPlan?.weeklySchedule != null) {
                      workoutProvider.currentPlan!.weeklySchedule!.values.forEach((workout) {
                        final name = workout.session ?? 'Rest Day';
                        final isRestDay = name.toLowerCase().contains('rest') || (workout.exercises == null || workout.exercises!.isEmpty);
                        if (!isRestDay && progressProvider.isWorkoutCompleted(name.hashCode)) {
                          completedWorkouts++;
                        }
                      });
                    }

                    return Column(
                      children: [
                        _buildProgressPanel(context, 'Workouts Completed', completedWorkouts.toDouble(), totalWorkouts.toDouble(), colorScheme.primary),
                        const SizedBox(height: 12),
                        _buildProgressPanel(context, 'Meals Logged', completedMeals.toDouble(), totalMeals.toDouble(), colorScheme.secondary),
                      ],
                    );
                  })(),

                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 24),
                  Text(
                    'Next Up',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildUpcomingCard(
                    context, 
                    workoutProvider.todayWorkout?.exercises?.firstOrNull?.name ?? 'Rest Day', 
                    workoutProvider.todayWorkout != null ? 'Today' : 'No workout today', 
                    colorScheme.primary,
                    navigateIndex: 2,
                  ),
                  const SizedBox(height: 12),
                  _buildUpcomingCard(
                    context, 
                    dietProvider.todayPlan?.meals?.firstOrNull?.name ?? 'No Meals Planned', 
                    dietProvider.todayPlan != null ? 'Upcoming' : '', 
                    colorScheme.secondary,
                    navigateIndex: 1,
                  ),
                  const SizedBox(height: 24),
                  _buildHealthScoreCard(context, 'Overall Health Score', (profileProvider.healthMetrics?.bmi != null ? (100 - (profileProvider.healthMetrics!.bmi! - 22).abs() * 2).toInt() : 85), colorScheme),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressPanel(BuildContext context, String label, double current, double target, Color accent) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.16)),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: current),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, animValue, child) {
          final currentProgress = target > 0 ? (animValue / target) : 0.0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.75),
                    ),
                  ),
                  Text(
                    '${animValue.toInt()} / ${target.toInt()}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 10,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: FractionallySizedBox(
                  widthFactor: currentProgress.clamp(0.0, 1.0),
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
        },
      ),
    );
  }


  Widget _buildUpcomingCard(BuildContext context, String title, String subtitle, Color accent, {int? navigateIndex}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: colorScheme.onSurface.withOpacity(0.65)),
              const SizedBox(width: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.72),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (navigateIndex != null) {
                  widget.onNavigate?.call(navigateIndex);
                } else {
                  showComingSoonSheet(context, title);
                }
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('View'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard(BuildContext context, String title, int score, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 18),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: score / 100,
                  color: colorScheme.primary,
                  backgroundColor: colorScheme.outline.withOpacity(0.16),
                  strokeWidth: 12,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Health Score',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.72),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}