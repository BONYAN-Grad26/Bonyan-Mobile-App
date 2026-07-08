import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/onboarding_provider.dart';
import '../steps/analysis_step.dart';
import '../steps/basic_info_step.dart';
import '../steps/body_comp_step.dart';
import '../steps/diet_prefs_step.dart';
import '../steps/goals_step.dart';
import '../steps/lifestyle_step.dart';
import '../steps/medical_step.dart';

class OnboardingWizard extends StatefulWidget {
  const OnboardingWizard({super.key});

  @override
  State<OnboardingWizard> createState() => _OnboardingWizardState();
}

class _OnboardingWizardState extends State<OnboardingWizard> {
  static const int _totalSteps = 7;

  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToNextStep() async {
    final provider = context.read<OnboardingProvider>();

    if (_currentIndex == _totalSteps - 1) {
      final success = await provider.submitProfile();
      if (!mounted) {
        return;
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Health profile generated successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to generate health profile.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _goToPreviousStep() async {
    if (_currentIndex == 0) {
      return;
    }

    await _pageController.previousPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  bool _isCurrentStepValid(OnboardingProvider provider) {
    switch (_currentIndex) {
      case 0:
        return provider.age != null && provider.gender != null && provider.gender!.isNotEmpty;
      case 1:
        return provider.heightCm != null && provider.weightKg != null;
      case 2:
        return provider.activityLevel != null && provider.activityLevel!.isNotEmpty;
      case 3:
        return provider.dietGoal != null && provider.dietGoal!.isNotEmpty;
      case 4:
        return provider.dietType != null && provider.dietType!.isNotEmpty;
      case 5:
      case 6:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<OnboardingProvider>(
      builder: (context, provider, _) {
        final progress = (_currentIndex + 1) / _totalSteps;
        final isSubmitting = provider.submissionStatus == OnboardingSubmissionStatus.loading;
        final isValidStep = _isCurrentStepValid(provider);
        final isLastStep = _currentIndex == _totalSteps - 1;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonyaan Onboarding',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Step ${_currentIndex + 1} of $_totalSteps',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.72),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            '${(progress * 100).round()}%',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: progress,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    children: const [
                      BasicInfoStep(),
                      BodyCompStep(),
                      LifestyleStep(),
                      GoalsStep(),
                      DietPrefsStep(),
                      MedicalStep(),
                      AnalysisStep(),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _currentIndex == 0 || isSubmitting ? null : _goToPreviousStep,
                          child: const Text('Back'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: (!isValidStep || isSubmitting) ? null : _goToNextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                          ),
                          child: isSubmitting
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                              : Text(isLastStep ? 'Generate My AI Profile' : 'Next'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
