import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/onboarding_provider.dart';

class MedicalStep extends StatelessWidget {
  const MedicalStep({super.key});

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
            'Medical Notes',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share any medical context that helps tailor your nutrition and fitness plans.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.72),
                ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: provider.medicalNotes ?? '',
            minLines: 6,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Medical Notes (optional)',
              hintText: 'Injuries, chronic conditions, medications, or anything important.',
              alignLabelWithHint: true,
            ),
            onChanged: (value) {
              final trimmed = value.trim();
              provider.updateMedicalNotes(trimmed.isEmpty ? null : trimmed);
            },
          ),
        ],
      ),
    );
  }
}