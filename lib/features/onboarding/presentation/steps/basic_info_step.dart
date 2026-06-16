import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/onboarding_provider.dart';

class BasicInfoStep extends StatelessWidget {
  const BasicInfoStep({super.key});

  static const _genderOptions = ['MALE', 'FEMALE', 'OTHER'];

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
            'Basic Information',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help Bonyaan personalize your health profile.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.72),
                ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: provider.age?.toString() ?? '',
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Age',
              hintText: 'e.g. 28',
            ),
            onChanged: (value) {
              final trimmed = value.trim();
              provider.updateAge(trimmed.isEmpty ? null : int.tryParse(trimmed));
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Gender',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _genderOptions
                .map(
                  (option) => _ChoiceCard(
                    label: option,
                    isSelected: provider.gender == option,
                    onTap: () => provider.updateGender(option),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
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
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 150,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.12)
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Text(
            label.replaceAll('_', ' '),
            textAlign: TextAlign.center,
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
