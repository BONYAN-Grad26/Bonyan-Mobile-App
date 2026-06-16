import 'package:flutter/material.dart';

class WorkoutsTab extends StatelessWidget {
  const WorkoutsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final workouts = [
      {
        'name': 'Upper Body Strength',
        'type': 'Strength',
        'duration': 45,
        'exercises': 6,
        'difficulty': 'Intermediate',
        'scheduled': 'Today at 6:00 PM',
        'focusAreas': ['Chest', 'Back', 'Shoulders'],
      },
      {
        'name': 'HIIT Cardio Blast',
        'type': 'Cardio',
        'duration': 30,
        'exercises': 8,
        'difficulty': 'Advanced',
        'scheduled': 'Tomorrow at 7:00 AM',
        'focusAreas': ['Full Body', 'Endurance'],
      },
      {
        'name': 'Lower Body & Core',
        'type': 'Strength',
        'duration': 50,
        'exercises': 7,
        'difficulty': 'Intermediate',
        'scheduled': 'Thursday at 5:30 PM',
        'focusAreas': ['Legs', 'Glutes', 'Core'],
      },
    ];

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
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero, // FIXED: Overrides global infinite width
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: const Text('Custom Workout', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  for (var item in [
                    {'day': 'Mon', 'workout': 'Upper'},
                    {'day': 'Tue', 'workout': 'Lower'},
                    {'day': 'Wed', 'workout': 'Rest'},
                    {'day': 'Thu', 'workout': 'Full', 'active': true},
                    {'day': 'Fri', 'workout': 'Cardio'},
                    {'day': 'Sat', 'workout': 'Core'},
                    {'day': 'Sun', 'workout': 'Rest'},
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                        width: 92,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: item['active'] == true
                              ? colorScheme.primary.withOpacity(0.12)
                              : colorScheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: item['active'] == true
                                ? colorScheme.primary
                                : colorScheme.outline.withOpacity(0.18),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              item['day'] as String,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['workout'] as String,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
            Column(
              children: workouts.map((workout) {
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
                                        workout['type'] as String,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurface.withOpacity(0.65),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    workout['name'] as String,
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
                                      Text(
                                        workout['scheduled'] as String,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurface.withOpacity(0.65),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size.zero, // FIXED: Overrides global infinite width
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              child: const Text('Start', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWorkoutStat(context, 'Duration', '${workout['duration']} min'),
                            const SizedBox(width: 8),
                            _buildWorkoutStat(context, 'Exercises', '${workout['exercises']}'),
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
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: (workout['focusAreas'] as List<String>)
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
                    'This Week’s Stats',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatsRow(context, 'Completed', '2/5', 0.40, colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Total Duration',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.65),
                    ),
                  ),
                  Text(
                    '6.5 hrs',
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
                    '2,140',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
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