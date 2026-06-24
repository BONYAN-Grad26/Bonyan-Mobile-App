import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/providers.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/ui_helpers.dart';

class MealsTab extends StatefulWidget {
  const MealsTab({super.key});

  @override
  State<MealsTab> createState() => _MealsTabState();
}

class _MealsTabState extends State<MealsTab> {
  bool _isGenerating = false;
  int _selectedIndex = -1; // -1 means auto-select today on first load

  Future<void> _generatePlan() async {
    setState(() => _isGenerating = true);
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    
    // Generate only the diet plan since we're in the Meals Tab
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

  Future<void> _loadData() async {
    final dietProvider = context.read<DietPlanProvider>();
    await dietProvider.fetchWeeklyPlans();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dietProvider = context.watch<DietPlanProvider>();
    final progressProvider = context.watch<ProgressProvider>();

    print('UI_DEBUG: Current dayPlan meals count is ${dietProvider.todayPlan?.meals?.length ?? -1}');

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
              onPressed: _loadData,
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
      // Find today's index by dayOfWeek
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
    final targetFat = selectedDayPlan?.targetFat?.toInt() ?? 70;

    // Calculate current consumed macros based on checked meals (estimating per meal)
    double currentCalories = 0;
    double currentProtein = 0;
    double currentCarbs = 0;

    final mealsCount = meals.isNotEmpty ? meals.length : 1;
    final caloriesPerMeal = (targetCalories / mealsCount).toDouble();
    final proteinPerMeal = (targetProtein / mealsCount).toDouble();
    final carbsPerMeal = (targetCarbs / mealsCount).toDouble();

    for (final meal in meals) {
      if (progressProvider.isMealCompleted(meal.id ?? meal.name.hashCode)) {
        currentCalories += caloriesPerMeal;
        currentProtein += proteinPerMeal;
        currentCarbs += carbsPerMeal;
      }
    }

    // Helper for formatting date using dayOfWeek instead of parsed date string
    String getWeekday(DayPlan dp) {
      if (dp.dayOfWeek != null && dp.dayOfWeek! >= 1 && dp.dayOfWeek! <= 7) {
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dp.dayOfWeek! - 1];
      }
      return 'Day';
    }

    IconData getMealIcon(String? type) {
      if (type == null) return Icons.restaurant;
      final lower = type.toLowerCase();
      if (lower.contains('breakfast')) return Icons.bakery_dining;
      if (lower.contains('lunch')) return Icons.lunch_dining;
      if (lower.contains('dinner')) return Icons.dinner_dining;
      if (lower.contains('snack')) return Icons.cookie;
      return Icons.restaurant;
    }

    int getUniqueMealId(DayPlan? dp, Meal meal) {
      final day = dp?.dayOfWeek ?? 0;
      final mId = meal.id ?? meal.name.hashCode;
      return day * 100000 + (mId.abs() % 100000);
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
                        'Meal Planning',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your personalized AI-generated meal plan',
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
              'This Week’s Plan',
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
                  for (int i = 0; i < weeklyDays.length; i++)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = i;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          width: 92,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: i == _selectedIndex
                                ? colorScheme.primary.withOpacity(0.12)
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: i == _selectedIndex ? colorScheme.primary : colorScheme.outline.withOpacity(0.18),
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
                              Text(
                                '${weeklyDays[i].targetCalories?.toInt() ?? 0} kcal',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.65),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                height: 6,
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color: colorScheme.outline.withOpacity(0.24),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: FractionallySizedBox(
                                  widthFactor: getDayProgress(weeklyDays[i]).clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colorScheme.secondary,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
                  border: Border.all(color: colorScheme.outline.withOpacity(0.16)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_menu, size: 64, color: colorScheme.primary.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'No Meals Planned',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Generate your AI-powered weekly diet plan to see your personalized meals for today.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.70),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                children: meals.map((meal) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colorScheme.outline.withOpacity(0.16)),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(getMealIcon(meal.mealType), color: colorScheme.primary, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  meal.mealType ?? 'Meal',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.65),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Checkbox(
                                value: progressProvider.isMealCompleted(getUniqueMealId(selectedDayPlan, meal)),
                                onChanged: (val) => progressProvider.toggleMeal(getUniqueMealId(selectedDayPlan, meal), val ?? false),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            meal.name ?? 'Unnamed Meal',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.schedule, size: 16, color: colorScheme.onSurface.withOpacity(0.65)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Prep time: ${meal.preparationTime ?? 0} mins',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.65),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (meal.preparationInstructions != null && meal.preparationInstructions!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Divider(color: colorScheme.outline.withOpacity(0.2)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.auto_awesome, size: 16, color: colorScheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  'AI Prep Tips',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              meal.preparationInstructions!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.75),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            Container(
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
                    'Today’s Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildProgressRow(context, 'Calories', '${currentCalories.toInt()} / ${targetCalories.toInt()}', currentCalories / (targetCalories > 0 ? targetCalories : 1), colorScheme.secondary),
                  const SizedBox(height: 14),
                  _buildProgressRow(context, 'Protein', '${currentProtein.toInt()} / ${targetProtein.toInt()}g', currentProtein / (targetProtein > 0 ? targetProtein : 1), colorScheme.primary),
                  const SizedBox(height: 14),
                  _buildProgressRow(context, 'Carbs', '${currentCarbs.toInt()} / ${targetCarbs.toInt()}g', currentCarbs / (targetCarbs > 0 ? targetCarbs : 1), colorScheme.tertiary),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroInfo(BuildContext context, String label, String value, String unit) {
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
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$value $unit',
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

  Widget _buildProgressRow(BuildContext context, String label, String value, double progress, Color accent) {
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