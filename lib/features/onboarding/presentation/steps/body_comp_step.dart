import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/onboarding_provider.dart';

class BodyCompStep extends StatelessWidget {
  const BodyCompStep({super.key});

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
            'Body Composition',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your current measurements for precise recommendations.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.72),
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: provider.heightCm?.toString() ?? '',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    hintText: '175',
                  ),
                  onChanged: (value) {
                    final trimmed = value.trim();
                    provider.updateHeightCm(trimmed.isEmpty ? null : double.tryParse(trimmed));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: provider.weightKg?.toString() ?? '',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    hintText: '70.5',
                  ),
                  onChanged: (value) {
                    final trimmed = value.trim();
                    provider.updateWeightKg(trimmed.isEmpty ? null : double.tryParse(trimmed));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: provider.muscleMassKg?.toString() ?? '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Muscle Mass (kg) - optional',
            ),
            onChanged: (value) {
              provider.updateMuscleMassKg(value.trim().isEmpty ? null : double.tryParse(value));
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: provider.fatPercentage?.toString() ?? '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Fat Percentage - optional',
              hintText: 'e.g. 18.2',
            ),
            onChanged: (value) {
              provider.updateFatPercentage(value.trim().isEmpty ? null : double.tryParse(value));
            },
          ),
        ],
      ),
    );
  }
}
