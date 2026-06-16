import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../onboarding/data/models/health_metric_model.dart';
import '../../../onboarding/data/repositories/metrics_repository.dart';
import '../widgets/metric_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final MetricsRepository _metricsRepository = MetricsRepository();

  HealthMetricModel? _metrics;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _metricsRepository.getMyHealthProfile();
      setState(() {
        _metrics = profile;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    final userName = authProvider.currentUser?.firstName;
    final greetingName = (userName == null || userName.isEmpty) ? 'Alex' : userName;

    final int caloriesCurrent = 1850;
    final int proteinCurrent = 95;
    const int waterCurrent = 6;
    const int stepsCurrent = 8234;
    final int caloriesGoal = _metrics?.dailyCalorieTarget ?? 2200;
    const int proteinGoal = 150;
    const int waterGoal = 8;
    const int stepsGoal = 10000;

    return RefreshIndicator(
      onRefresh: _loadMetrics,
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
              // 100% Safe Native Title
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
                  Text(
                    'Today’s AI Recommendations',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildRecommendationCard(
                    context,
                    colorScheme.primary,
                    'Increase Water Intake',
                    'You’re 2 cups behind your daily goal. Stay hydrated!',
                  ),
                  const SizedBox(height: 12),
                  _buildRecommendationCard(
                    context,
                    colorScheme.secondary,
                    'You’re Doing Great!',
                    'You’ve completed 2 of your 3 scheduled workouts this week.',
                  ),
                  const SizedBox(height: 12),
                  _buildRecommendationCard(
                    context,
                    colorScheme.tertiary,
                    'Perfect Nutrition',
                    'Your macros are perfectly balanced for muscle gain. Keep it up!',
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
                  _buildUpcomingCard(context, 'Upper Body Workout', 'Today at 6:00 PM', colorScheme.primary),
                  const SizedBox(height: 12),
                  _buildUpcomingCard(context, 'Dinner Meal Plan', 'In 2 hours', colorScheme.secondary),
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

  Widget _buildRecommendationCard(BuildContext context, Color accent, String title, String subtitle) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
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
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.72),
                  ),
                ),
              ],
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

  // FIXED: No horizontal Flex paradoxes. Stacked vertically, cleanly bounded.
  Widget _buildActionButton(BuildContext context, IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {},
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
              onPressed: () {},
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