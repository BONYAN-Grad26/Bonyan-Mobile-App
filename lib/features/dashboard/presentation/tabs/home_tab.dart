import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bonyaan_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bonyaan_app/core/providers/providers.dart';
import 'package:bonyaan_app/core/models/models.dart';
import 'package:bonyaan_app/core/utils/ui_helpers.dart';
import '../widgets/metric_card.dart';

class HomeTab extends StatefulWidget {
  final void Function(int)? onNavigate;
  final void Function(int)? onJump;

  const HomeTab({super.key, this.onNavigate, this.onJump});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _randomGreeting = 'Hello';

  @override
  void initState() {
    super.initState();
    _pickRandomGreeting();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _pickRandomGreeting() {
    const greetings = ['Hello', 'Hi', 'Hey', 'Welcome', 'Greetings', 'Stay active', 'Welcome back'];
    _randomGreeting = greetings[Random().nextInt(greetings.length)];
  }

  Future<void> _loadData([bool isRefresh = false]) async {
    if (isRefresh) {
      setState(() {
        _pickRandomGreeting();
      });
    }
    final profileProvider = context.read<ProfileProvider>();
    final dietProvider = context.read<DietPlanProvider>();
    final workoutProvider = context.read<WorkoutProvider>();

    // Load weekly plans first as it's the most reliable and provides fallback for today
    if (isRefresh || dietProvider.currentPlan == null) {
      await dietProvider.fetchWeeklyPlans();
    }
    
    final futures = <Future<void>>[];
    
    if (isRefresh || profileProvider.healthMetrics == null) {
      futures.add(profileProvider.fetchMyHealthProfile());
    }
    
    // These might fail but we can fall back to data from fetchWeeklyPlans
    if (isRefresh || dietProvider.todayPlan == null) {
      futures.add(dietProvider.fetchTodayPlan());
    }
    if (isRefresh || workoutProvider.currentPlan == null) {
      futures.add(workoutProvider.fetchCurrentWorkoutPlan());
    }
    
    if (futures.isNotEmpty) {
      await Future.wait(futures.map((f) => f.catchError((_) {})));
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

    // Error State - Only show if we have no data at all to display
    final hasNoData = profileProvider.healthMetrics == null && 
                      dietProvider.currentPlan == null && 
                      workoutProvider.currentPlan == null;

    if (hasNoData && (profileProvider.errorMessage != null || 
        dietProvider.errorMessage != null || 
        workoutProvider.errorMessage != null)) {
      final error = profileProvider.errorMessage ?? 
                    dietProvider.errorMessage ?? 
                    workoutProvider.errorMessage;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'API Error',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(error ?? 'An error occurred', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _loadData(true),
                child: const Text('Retry'),
              ),
              TextButton(
                onPressed: () {
                  widget.onNavigate?.call(5); // Navigate to Settings
                },
                child: const Text('Check Backend URL in Settings'),
              ),
            ],
          ),
        ),
      );
    }

    final userName = authProvider.currentUser?.firstName?.split(' ').first;
    final greetingName = (progressProvider.customFirstName.isNotEmpty 
        ? progressProvider.customFirstName.split(' ').first
        : ((userName == null || userName.isEmpty) ? 'User' : userName)).replaceAll('!', '');

    final metrics = profileProvider.healthMetrics;
    
    final todayWeekday = DateTime.now().weekday;
    final todayWeekdayName = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][todayWeekday - 1];

    DayPlan? activeTodayPlan = dietProvider.todayPlan;
    if (dietProvider.currentPlan != null && (dietProvider.currentPlan!.days?.isNotEmpty ?? false)) {
      final idx = dietProvider.currentPlan!.days!.indexWhere((dp) => dp.dayOfWeek == todayWeekday);
      if (idx != -1) {
        activeTodayPlan = dietProvider.currentPlan!.days![idx];
      }
    }

    WorkoutDay? activeTodayWorkout = workoutProvider.todayWorkout != null ? WorkoutDay(
      session: workoutProvider.todayWorkout!.session,
      focus: workoutProvider.todayWorkout!.focus,
      exercises: workoutProvider.todayWorkout!.exercises,
    ) : null;

    if (activeTodayWorkout == null && workoutProvider.currentPlan?.weeklySchedule != null) {
      activeTodayWorkout = workoutProvider.currentPlan!.weeklySchedule![todayWeekdayName];
    }
    
    final bool isRestDay = activeTodayWorkout == null || (activeTodayWorkout.exercises == null || activeTodayWorkout.exercises!.isEmpty);

    // Goals from health profile and diet plan
    final int caloriesGoal = activeTodayPlan?.targetCalories?.toInt() ?? metrics?.dailyCalorieTarget ?? 2200;
    final int proteinGoal = activeTodayPlan?.targetProtein?.toInt() ?? (metrics?.weightKg != null ? (metrics!.weightKg! * 2).round() : 150);
    
    // Current progress
    int caloriesCurrent = 0;
    int proteinCurrent = 0;

    if (activeTodayPlan != null && activeTodayPlan.meals != null && activeTodayPlan.meals!.isNotEmpty) {
      final mealsList = activeTodayPlan.meals!;
      int mealCount = mealsList.length;
      for (final meal in mealsList) {
        final d = activeTodayPlan.dayOfWeek ?? 0;
        final mId = meal.id ?? meal.name.hashCode;
        final uniqueId = d * 100000 + (mId.abs() % 100000);
        if (progressProvider.isMealCompleted(uniqueId)) {
          caloriesCurrent += (caloriesGoal / mealCount).round();
          proteinCurrent += (proteinGoal / mealCount).round();
        }
      }
    }

    final hour = DateTime.now().hour;
    final String timeGreeting;
    final IconData greetingIcon;

    if (hour < 12) {
      timeGreeting = 'Good Morning';
      greetingIcon = Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      timeGreeting = 'Good Afternoon';
      greetingIcon = Icons.wb_cloudy_rounded;
    } else {
      timeGreeting = 'Good Evening';
      greetingIcon = Icons.nights_stay_rounded;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBarBlue = const Color(0xFF268FB1);
    
    // Dimmed colors for dark mode
    final caloriesColor = isDark ? const Color(0xFFB36B26) : const Color(0xFFF09033);
    final proteinColor = isDark ? colorScheme.tertiary.withValues(alpha: 0.7) : colorScheme.tertiary;

    return RefreshIndicator(
      onRefresh: () => _loadData(true),
      color: navBarBlue,
      backgroundColor: colorScheme.surface,
      displacement: 40,
      strokeWidth: 3,
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverSafeArea(
            bottom: false,
            sliver: SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 24), // Increased top padding
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: navBarBlue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(greetingIcon, size: 14, color: navBarBlue),
                              const SizedBox(width: 6),
                              Text(
                                timeGreeting.toUpperCase(),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: navBarBlue,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 10), // Aligns "Hello" with the pill's icon/text start
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$_randomGreeting, ',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                TextSpan(
                                  text: greetingName,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: navBarBlue,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        if (widget.onJump != null) {
                          widget.onJump!(3);
                        } else {
                          widget.onNavigate?.call(3);
                        }
                      }, // 3 is the index of ChatPage in _tabs
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: navBarBlue, // Matches Nav Bar color
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.black, width: 0.5), // Subtle border for the icon as well
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 24),
                            SizedBox(width: 6),
                            Text(
                              'AI Chat',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                    customColor: caloriesColor,
                  ),
                  MetricCard(
                    title: 'Protein',
                    value: '$proteinCurrent',
                    unit: 'g',
                    icon: Icons.restaurant,
                    variant: MetricVariant.health,
                    progress: proteinCurrent / proteinGoal * 100,
                    customColor: proteinColor,
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _buildHealthScoreCard(context, 'Overall Health Score', (profileProvider.healthMetrics?.bmi != null ? (100 - (profileProvider.healthMetrics!.bmi! - 22).abs() * 2).toInt() : 85), colorScheme),
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
                  const SizedBox(height: 16), // Added whitespace under the title
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
                    if (totalMeals == 0) totalMeals = 0;

                    int totalWorkouts = 0;
                    if (workoutProvider.currentPlan?.weeklySchedule != null) {
                      for (final day in workoutProvider.currentPlan!.weeklySchedule!.values) {
                        if (day.exercises != null && day.exercises!.isNotEmpty) {
                          totalWorkouts++;
                        }
                      }
                    }
                    if (totalWorkouts == 0) totalWorkouts = 0;

                    int completedWorkouts = 0;
                    if (workoutProvider.currentPlan?.weeklySchedule != null) {
                      workoutProvider.currentPlan!.weeklySchedule!.values.forEach((workout) {
                        final sessionName = workout.session ?? 'Workout';
                        final isRestDay = sessionName.toLowerCase().contains('rest') || (workout.exercises == null || workout.exercises!.isEmpty);
                        if (!isRestDay && progressProvider.isWorkoutCompleted(sessionName.hashCode)) {
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
                  (() {
                    String workoutTitle = 'Rest Day';
                    String workoutSubtitle = 'No workout today';

                    if (!isRestDay) {
                      final sessionName = activeTodayWorkout?.session ?? 'Workout Session';
                      if (progressProvider.isWorkoutCompleted(sessionName.hashCode)) {
                        workoutTitle = 'Workout Complete!';
                        workoutSubtitle = 'Great job today';
                      } else {
                        workoutTitle = sessionName;
                        workoutSubtitle = 'Today\'s Session';
                      }
                    }

                    // Find the next uncompleted meal
                    String mealTitle = 'No Meals Planned';
                    String mealSubtitle = '';
                    if (activeTodayPlan != null && activeTodayPlan.meals != null && activeTodayPlan.meals!.isNotEmpty) {
                      Meal? nextMeal;
                      for (final meal in activeTodayPlan.meals!) {
                        final d = activeTodayPlan.dayOfWeek ?? 0;
                        final mId = meal.id ?? meal.name.hashCode;
                        final uniqueId = d * 100000 + (mId.abs() % 100000);
                        if (!progressProvider.isMealCompleted(uniqueId)) {
                          nextMeal = meal;
                          break;
                        }
                      }
                      if (nextMeal != null) {
                        mealTitle = nextMeal.name ?? 'Unnamed Meal';
                        mealSubtitle = 'Upcoming • ${nextMeal.mealType ?? 'Meal'}';
                      } else {
                        mealTitle = 'All Meals Completed!';
                        mealSubtitle = 'Great job today';
                      }
                    }

                    return Column(
                      children: [
                        _buildUpcomingCard(
                          context,
                          workoutTitle,
                          workoutSubtitle,
                          colorScheme.primary,
                          navigateIndex: 2,
                        ),
                        const SizedBox(height: 12),
                        _buildUpcomingCard(
                          context,
                          mealTitle,
                          mealSubtitle,
                          colorScheme.secondary,
                          navigateIndex: 1,
                        ),
                      ],
                    );
                  })(),
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
        color: Theme.of(context).brightness == Brightness.dark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: current),
        duration: const Duration(milliseconds: 800),
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
                      color: colorScheme.onSurface.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.75 : 0.90),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: current),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, animValue, child) {
                      return Text(
                        '${animValue.toInt()} / ${target.toInt()}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.5 : 0.70),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 12,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.12)
                      : Colors.black.withOpacity(0.08), // Grey visible track
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
    
    void handleTap() {
      if (navigateIndex != null) {
        if (widget.onJump != null) {
          widget.onJump!(navigateIndex);
        } else {
          widget.onNavigate?.call(navigateIndex);
        }
      } else {
        showComingSoonSheet(context, title);
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: handleTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? colorScheme.surfaceContainerHighest
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.5),
              width: 1.0,
            ),
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
                  onPressed: handleTap,
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
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard(BuildContext context, String title, int score, ColorScheme colorScheme) {
    String status;
    IconData statusIcon;
    
    if (score >= 90) {
      status = 'Excellent';
      statusIcon = Icons.stars_rounded;
    } else if (score >= 70) {
      status = 'Good';
      statusIcon = Icons.check_circle_rounded;
    } else {
      status = 'Needs Focus';
      statusIcon = Icons.info_outline_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(statusIcon, color: Colors.white.withOpacity(0.9), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        status,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: score.toDouble()),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Text(
                      '${value.toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Unique horizontal health bar
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2), // Visible grey background
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: score / 100),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
