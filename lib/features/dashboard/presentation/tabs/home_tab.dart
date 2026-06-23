import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../widgets/metric_card.dart';

class HomeTab extends StatefulWidget {
  final void Function(int)? onNavigate;

  const HomeTab({super.key, this.onNavigate});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _isGenerating = false;
  String _generationStep = '';

  Future<void> _generatePlans() async {
    setState(() {
      _isGenerating = true;
      _generationStep = 'Generating Diet Plan (1/2)...';
    });

    try {
      final dietProvider = context.read<DietPlanProvider>();
      final workoutProvider = context.read<WorkoutProvider>();
      
      final todayStr = DateTime.now().toIso8601String().split('T')[0];

      final dietResult = await dietProvider.generateWeeklyPlan(startDate: todayStr, weekNumber: 1);
      
      if (!dietResult) {
        if (mounted) {
          final error = dietProvider.generationError ?? dietProvider.errorMessage ?? 'Failed to generate diet plan.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
          if (dietProvider.generationError != null) {
            _loadData();
          }
        }
        return;
      }

      if (mounted) {
        setState(() {
          _generationStep = 'Generating Workout Plan (2/2)...';
        });
      }

      final workoutResult = await workoutProvider.generateWeeklyPlan();

      if (mounted) {
        if (!workoutResult) {
          final error = workoutProvider.generationError ?? workoutProvider.errorMessage ?? 'Failed to generate workout plan.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
          if (workoutProvider.generationError != null) {
            await _loadData();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Weekly plan generated successfully!')),
          );
          await _loadData();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating plans: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _generationStep = '';
        });
      }
    }
  }

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
    final authProvider = context.read<AuthProvider>();

    final futures = <Future<void>>[
      profileProvider.fetchMyHealthProfile(),
      dietProvider.fetchTodayPlan(),
      workoutProvider.fetchCurrentWorkoutPlan(),
    ];
    
    await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final dietProvider = context.watch<DietPlanProvider>();
    final workoutProvider = context.watch<WorkoutProvider>();

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
    final greetingName = (userName == null || userName.isEmpty) ? 'Alex' : userName;

    final metrics = profileProvider.healthMetrics;
    
    // Goals from health profile
    final int caloriesGoal = metrics?.dailyCalorieTarget ?? 2200;
    final int proteinGoal = metrics?.weightKg != null ? (metrics!.weightKg! * 2).round() : 150;
    const int waterGoal = 8;
    const int stepsGoal = 10000;

    // Current progress (0 for empty states)
    const int caloriesCurrent = 0;
    const int proteinCurrent = 0;
    const int waterCurrent = 0;
    const int stepsCurrent = 0;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 120,
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Text(
                'Good morning, $greetingName!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
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
                    trend: const MetricTrend(value: 5, direction: TrendDirection.down),
                  ),
                  MetricCard(
                    title: 'Protein',
                    value: '$proteinCurrent',
                    unit: 'g',
                    icon: Icons.restaurant,
                    variant: MetricVariant.health,
                    progress: proteinCurrent / proteinGoal * 100,
                    trend: const MetricTrend(value: 3, direction: TrendDirection.up),
                  ),
                  MetricCard(
                    title: 'Water',
                    value: '$waterCurrent',
                    unit: 'cups',
                    icon: Icons.water_drop,
                    variant: MetricVariant.workout,
                    progress: waterCurrent / waterGoal * 100,
                    trend: const MetricTrend(value: 1, direction: TrendDirection.up),
                  ),
                  MetricCard(
                    title: 'Steps',
                    value: stepsCurrent.toString(),
                    unit: 'steps',
                    icon: Icons.trending_up,
                    variant: MetricVariant.defaultVariant,
                    progress: stepsCurrent / stepsGoal * 100,
                    trend: const MetricTrend(value: 12, direction: TrendDirection.up),
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colorScheme.primary.withOpacity(0.12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Weekly Plan is Ready to Generate',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap below to let our AI build your personalized 7-day diet and workout schedule based on your health metrics.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.70),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isGenerating ? null : _generatePlans,
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size.zero,
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _isGenerating
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colorScheme.onPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(_generationStep, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                : const Text('Generate AI Plans', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
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
                  const SizedBox(height: 14),
                  _buildProgressPanel(context, 'Workouts Completed', '2/3', 0.67, colorScheme.primary),
                  const SizedBox(height: 12),
                  _buildProgressPanel(context, 'Meals Logged', '18/21', 0.86, colorScheme.secondary),
                  const SizedBox(height: 12),
                  _buildProgressPanel(context, 'Goal Adherence', '94%', 0.94, colorScheme.tertiary),
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
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildActionButton(context, Icons.restaurant, 'Log Meal'),
                      const SizedBox(width: 12),
                      _buildActionButton(context, Icons.fitness_center, 'Workout'),
                      const SizedBox(width: 12),
                      _buildActionButton(context, Icons.track_changes, 'Goals'),
                    ],
                  ),
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
                    workoutProvider.todayWorkout?.exercises?.firstOrNull?.name ?? 'Upper Body Workout', 
                    'Today at 6:00 PM', 
                    colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  _buildUpcomingCard(
                    context, 
                    dietProvider.todayPlan?.meals?.firstOrNull?.name ?? 'Dinner Meal Plan', 
                    'In 2 hours', 
                    colorScheme.secondary,
                  ),
                  const SizedBox(height: 24),
                  _buildHealthScoreCard(context, 'Overall Health Score', 85, colorScheme),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressPanel(BuildContext context, String label, String value, double progress, Color accent) {
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
                value,
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
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          if (label == 'Log Meal') {
            widget.onNavigate?.call(1);
          } else if (label == 'Workout') {
            widget.onNavigate?.call(2);
          } else {
            showComingSoonSheet(context, label);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outline.withOpacity(0.16)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingCard(BuildContext context, String title, String subtitle, Color accent) {
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
                if (title.contains('Workout')) {
                  widget.onNavigate?.call(2);
                } else if (title.contains('Meal')) {
                  widget.onNavigate?.call(1);
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