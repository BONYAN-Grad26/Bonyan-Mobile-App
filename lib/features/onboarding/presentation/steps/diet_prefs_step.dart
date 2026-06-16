import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/onboarding_provider.dart';

class DietPrefsStep extends StatelessWidget {
  const DietPrefsStep({super.key});

  static const _dietTypes = [
    'BALANCED',
    'KETOGENIC',
    'VEGETARIAN',
    'VEGAN',
    'PALEO',
    'MEDITERRANEAN',
  ];

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
            'Diet Preferences',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick the nutrition style that best matches your lifestyle.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.72),
                ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _dietTypes
                .map(
                  (dietType) => _DietChoiceCard(
                    label: dietType,
                    isSelected: provider.dietType == dietType,
                    onTap: () => provider.updateDietType(dietType),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _DietChoiceCard extends StatelessWidget {
  const _DietChoiceCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 170,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.14)
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.25),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label.replaceAll('_', ' '),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                ),
          ),
        ),
      ),
    );
  }
}
