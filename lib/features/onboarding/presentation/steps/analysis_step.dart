import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/onboarding_provider.dart';

class AnalysisStep extends StatelessWidget {
  const AnalysisStep({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review and Generate',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Confirm your details, then generate your AI-powered health profile.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.72),
                ),
          ),
          const SizedBox(height: 20),
          _SummaryCard(
            title: 'Basic Metrics',
            values: [
              'Age: ${provider.age ?? '-'}',
              'Gender: ${provider.gender ?? '-'}',
              'Height: ${provider.heightCm?.toStringAsFixed(1) ?? '-'} cm',
              'Weight: ${provider.weightKg?.toStringAsFixed(1) ?? '-'} kg',
            ],
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            title: 'Lifestyle and Goals',
            values: [
              'Activity: ${provider.activityLevel ?? '-'}',
              'Goal: ${provider.dietGoal ?? '-'}',
              'Diet Type: ${provider.dietType ?? '-'}',
              'Target Weight: ${provider.targetWeightKg?.toStringAsFixed(1) ?? '-'} kg',
            ],
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            title: 'Body Composition',
            values: [
              'Muscle Mass: ${provider.muscleMassKg?.toStringAsFixed(1) ?? '-'} kg',
              'Fat Percentage: ${provider.fatPercentage?.toStringAsFixed(1) ?? '-'}%',
              'Daily Calories: ${provider.dailyCalorieTarget?.toString() ?? '-'}',
            ],
          ),
          if ((provider.medicalNotes ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            _SummaryCard(
              title: 'Medical Notes',
              values: [provider.medicalNotes!],
            ),
          ],
          const SizedBox(height: 16),
          if (provider.submissionStatus == OnboardingSubmissionStatus.loading)
            Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Generating your AI profile...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          if (provider.submissionStatus == OnboardingSubmissionStatus.success)
            Text(
              'Success! Your health profile is ready.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.tertiary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          if (provider.submissionStatus == OnboardingSubmissionStatus.error)
            Text(
              provider.errorMessage ?? 'Could not submit your profile right now.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          ...values.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                line,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}