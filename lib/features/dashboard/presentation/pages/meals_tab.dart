import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bonyaan_app/core/providers/providers.dart';
import 'package:bonyaan_app/core/models/models.dart';
import '../widgets/meal_suggester_sheet.dart';

class MealsTab extends StatefulWidget {
  const MealsTab({super.key});

  @override
  State<MealsTab> createState() => _MealsTabState();
}

class _MealsTabState extends State<MealsTab> {
  bool _isGenerating = false;
  int _selectedIndex = -1; // -1 means auto-select today on first load
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _generatePlan() async {
    setState(() => _isGenerating = true);
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    
    final success = await context.read<DietPlanProvider>().generateWeeklyPlan(startDate: todayStr);
    
    if (mounted) {
      setState(() => _isGenerating = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diet plan generated successfully!')),
        );
        await _loadData();
      } else {
        final dp = context.read<DietPlanProvider>();
        final error = dp.generationError ?? dp.errorMessage ?? 'Failed to generate plan.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
        if (dp.generationError != null) {
          _loadData();
        }
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

  Future<void> _loadData([bool isRefresh = false]) async {
    final dietProvider = context.read<DietPlanProvider>();
    if (isRefresh || dietProvider.currentPlan == null || (dietProvider.currentPlan?.days?.isEmpty ?? true)) {
      await dietProvider.fetchWeeklyPlans();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dietProvider = context.watch<DietPlanProvider>();
    final progressProvider = context.watch<ProgressProvider>();

    if (dietProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (dietProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(dietProvider.errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadData(true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final currentPlan = dietProvider.currentPlan;
    List<DayPlan> weeklyDays = currentPlan?.days ?? [];

    if (weeklyDays.isEmpty && dietProvider.todayPlan != null) {
      weeklyDays = [dietProvider.todayPlan!];
    }
    
    final todayWeekday = DateTime.now().weekday;

    if (_selectedIndex == -1 && weeklyDays.isNotEmpty) {
      int todayIdx = weeklyDays.indexWhere((dp) => dp.dayOfWeek == todayWeekday);
      _selectedIndex = todayIdx != -1 ? todayIdx : 0;
    }

    DayPlan? selectedDayPlan;
    if (weeklyDays.isNotEmpty) {
      if (_selectedIndex >= weeklyDays.length) _selectedIndex = 0;
      if (_selectedIndex >= 0) selectedDayPlan = weeklyDays[_selectedIndex];
    } else {
      selectedDayPlan = dietProvider.todayPlan;
    }

    final meals = selectedDayPlan?.meals ?? [];
    final targetCalories = selectedDayPlan?.targetCalories?.toInt() ?? 2200;
    final targetProtein = selectedDayPlan?.targetProtein?.toInt() ?? 150;
    final targetCarbs = selectedDayPlan?.targetCarbs?.toInt() ?? 275;

    double currentCalories = 0;
    double currentProtein = 0;
    double currentCarbs = 0;

    final mealsCount = meals.isNotEmpty ? meals.length : 1;
    final caloriesPerMeal = (targetCalories / mealsCount).toDouble();
    final proteinPerMeal = (targetProtein / mealsCount).toDouble();
    final carbsPerMeal = (targetCarbs / mealsCount).toDouble();

    int getUniqueMealId(DayPlan? dp, Meal meal) {
      final day = dp?.dayOfWeek ?? 0;
      final mId = meal.id ?? meal.name.hashCode;
      return day * 100000 + (mId.abs() % 100000);
    }

    for (final meal in meals) {
      final uniqueId = getUniqueMealId(selectedDayPlan, meal);
      if (progressProvider.isMealCompleted(uniqueId)) {
        currentCalories += caloriesPerMeal;
        currentProtein += proteinPerMeal;
        currentCarbs += carbsPerMeal;
      }
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
                  _buildWeekSplit(context, weeklyDays, colorScheme, progressProvider, getUniqueMealId),
                  const SizedBox(height: 24),
                  _buildScannerButton(context, colorScheme),
                  const SizedBox(height: 16),
                  _buildMealsSection(context, selectedDayPlan, meals, colorScheme, progressProvider, getUniqueMealId),
                  const SizedBox(height: 16),
                  _buildSummaryCard(context, currentCalories, targetCalories, currentProtein, targetProtein, currentCarbs, targetCarbs, colorScheme),
                  const SizedBox(height: 120), // Extra space for nav bar
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
        Text(
          'Meal Planning',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your personalized AI-generated meal plan',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.70),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekSplit(BuildContext context, List<DayPlan> weeklyDays, ColorScheme colorScheme, ProgressProvider progressProvider, Function getUniqueMealId) {
    String getWeekday(DayPlan dp) {
      if (dp.dayOfWeek != null && dp.dayOfWeek! >= 1 && dp.dayOfWeek! <= 7) {
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dp.dayOfWeek! - 1];
      }
      return 'Day';
    }

    double getDayProgress(DayPlan dp) {
      if (dp.meals == null || dp.meals!.isEmpty) return 0.0;
      int completed = 0;
      for (var meal in dp.meals!) {
        final mealId = getUniqueMealId(dp, meal);
        if (progressProvider.isMealCompleted(mealId)) {
          completed++;
        }
      }
      return completed / dp.meals!.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Week’s Plan',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          child: Row(
            children: [
              for (int i = 0; i < weeklyDays.length; i++)
                GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Container(
                      width: 92,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: i == _selectedIndex ? colorScheme.primary.withValues(alpha: 0.12) : colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: i == _selectedIndex ? colorScheme.primary : colorScheme.outline,
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            getWeekday(weeklyDays[i]),
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: (weeklyDays[i].targetCalories ?? 0).toDouble()),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            builder: (context, kcal, child) {
                              return Text(
                                '${kcal.toInt()} kcal',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.65),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: getDayProgress(weeklyDays[i]).clamp(0.0, 1.0)),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Container(
                                width: double.infinity,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: colorScheme.outline.withValues(alpha: 0.24),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colorScheme.secondary,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
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
          builder: (context) => const MealSuggesterSheet(),
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
      label: const Text(
        'Scan Ingredients for a Meal Idea',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMealsSection(BuildContext context, DayPlan? selectedDayPlan, List<Meal> meals, ColorScheme colorScheme, ProgressProvider progressProvider, Function getUniqueMealId) {
    IconData getMealIcon(String? type) {
      if (type == null) return Icons.restaurant;
      final lower = type.toLowerCase();
      if (lower.contains('breakfast')) return Icons.bakery_dining;
      if (lower.contains('lunch')) return Icons.lunch_dining;
      if (lower.contains('dinner')) return Icons.dinner_dining;
      if (lower.contains('snack')) return Icons.cookie;
      return Icons.restaurant;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today’s Meals',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        if (meals.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Column(
              children: [
                Icon(Icons.restaurant_menu, size: 64, color: colorScheme.primary.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text('No Meals Planned', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('Generate your AI-powered weekly diet plan to see your personalized meals for today.', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generatePlan,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate AI Plan'),
                ),
              ],
            ),
          )
        else
          ...meals.map((meal) {
            final mealId = getUniqueMealId(selectedDayPlan, meal);
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colorScheme.outline),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(getMealIcon(meal.mealType), color: colorScheme.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(meal.mealType ?? 'Meal', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.65), fontWeight: FontWeight.w600))),
                      Checkbox(
                        value: progressProvider.isMealCompleted(mealId),
                        onChanged: (val) => progressProvider.toggleMeal(mealId, val ?? false),
                      ),
                    ],
                  ),
                  Text(meal.name ?? 'Unnamed Meal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16),
                      const SizedBox(width: 6),
                      Text('Prep: ${meal.preparationTime ?? 15} mins'),
                    ],
                  ),
                  if (meal.preparationInstructions != null) ...[
                    const Divider(height: 32),
                    Text('AI Prep Tips', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                    const SizedBox(height: 8),
                    Text(meal.preparationInstructions!, style: const TextStyle(fontSize: 13, height: 1.5)),
                  ],
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, double currentCalories, int targetCalories, double currentProtein, int targetProtein, double currentCarbs, int targetCarbs, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today’s Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 18),
          _buildProgressRow(context, 'Calories', currentCalories, targetCalories.toDouble(), '', const Color(0xFFF09033)),
          const SizedBox(height: 14),
          _buildProgressRow(context, 'Protein', currentProtein, targetProtein.toDouble(), 'g', colorScheme.tertiary),
          const SizedBox(height: 14),
          _buildProgressRow(context, 'Carbs', currentCarbs, targetCarbs.toDouble(), 'g', colorScheme.secondary),
        ],
      ),
    );
  }

  Widget _buildProgressRow(BuildContext context, String label, double current, double target, String suffix, Color accent) {
    final progress = target > 0 ? (current / target) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: current),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, animValue, child) {
                return Text(
                  '${animValue.toInt()} / ${target.toInt()}$suffix',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: progress.clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return LinearProgressIndicator(
              value: value,
              backgroundColor: accent.withValues(alpha: 0.1),
              color: accent,
              minHeight: 8,
              borderRadius: BorderRadius.circular(9),
            );
          },
        ),
      ],
    );
  }
}
