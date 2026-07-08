import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bonyaan_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bonyaan_app/core/providers/providers.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback? onBack;

  const SettingsPage({super.key, this.onBack});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverSafeArea(
            bottom: false,
            sliver: SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 20), // Added whitespace at the top
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildTopBar(context, colorScheme),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Notifications'),
                  const SizedBox(height: 12),
                  _buildToggleRow(context, 'Meal Reminders', 'Get reminded to log your meals', settings.mealReminders, (v) => settings.setMealReminders(v)),
                  _buildToggleRow(context, 'Workout Alerts', 'Get notified when workouts are ready', settings.workoutAlerts, (v) => settings.setWorkoutAlerts(v)),

                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Appearance'),
                  const SizedBox(height: 12),
                  _buildAppearanceOption(context, settings),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Account'),
                  const SizedBox(height: 12),
                  _buildSignOutButton(context, colorScheme),
                  const SizedBox(height: 120), // Padding for floating nav bar
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        if (widget.onBack != null)
          Padding(
            padding: const EdgeInsets.only(right: 0), // Reduced whitespace
            child: IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: colorScheme.onSurface,
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18, // Smaller text
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
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
        border: Border.all(color: colorScheme.outline, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.65), fontSize: 12)),
              ],
            ),
          ),
          Switch(value: enabled, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildAppearanceOption(BuildContext context, SettingsProvider settings) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Theme', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primary.withOpacity(0.12) : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? colorScheme.primary : colorScheme.outline.withOpacity(0.3)),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: selected ? colorScheme.primary : colorScheme.onSurface)),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, ColorScheme colorScheme) {
    return ElevatedButton.icon(
      onPressed: () {
        context.read<AuthProvider>().logout();
        Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.error.withOpacity(0.1),
        foregroundColor: colorScheme.error,
        minimumSize: const Size.fromHeight(52),
        elevation: 0,
      ),
      icon: const Icon(Icons.logout),
      label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
