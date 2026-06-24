import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/widgets/bonyaan_logo.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = Provider.of<SettingsProvider>(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your preferences',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.70),
                      ),
                    ),
                  ],
                ),
                const BonyaanLogo.small(),
              ],
            ),
            _buildSectionTitle(context, 'Notifications'),
            const SizedBox(height: 12),
            _buildToggleRow(context, 'Meal Reminders', 'Get reminded to log your meals', settings.mealReminders, (v) => settings.setMealReminders(v)),
            _buildToggleRow(context, 'Workout Alerts', 'Get notified when workouts are ready', settings.workoutAlerts, (v) => settings.setWorkoutAlerts(v)),

            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Appearance'),
            const SizedBox(height: 12),
            _buildAppearanceOption(context),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Account'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error.withOpacity(0.1),
                  foregroundColor: colorScheme.error,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  minimumSize: const Size(0, 52),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildToggleRow(BuildContext context, String title, String subtitle, bool enabled, ValueChanged<bool> onChanged) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
          Checkbox(value: enabled, onChanged: (v) => onChanged(v ?? false)),
        ],
      ),
    );
  }

  Widget _buildAppearanceOption(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = Provider.of<SettingsProvider>(context);
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
            'Theme',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPill(context, 'Light', settings.themeMode == ThemeMode.light, () => settings.setThemeMode(ThemeMode.light)),
              const SizedBox(width: 10),
              _buildPill(context, 'Dark', settings.themeMode == ThemeMode.dark, () => settings.setThemeMode(ThemeMode.dark)),
              const SizedBox(width: 10),
              _buildPill(context, 'System', settings.themeMode == ThemeMode.system, () => settings.setThemeMode(ThemeMode.system)),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildPill(BuildContext context, String label, bool selected, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primary.withOpacity(0.12) : colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? colorScheme.primary : colorScheme.outline.withOpacity(0.16),
            ),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}