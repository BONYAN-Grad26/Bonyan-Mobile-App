import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
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
              'Manage your preferences and account settings',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.70),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Notifications'),
            const SizedBox(height: 12),
            _buildToggleRow(context, 'Meal Reminders', 'Get reminded to log your meals', true),
            _buildToggleRow(context, 'Workout Alerts', 'Get notified when workouts are ready', true),
            _buildToggleRow(context, 'Progress Updates', 'Weekly summary of your progress', true),
            _buildToggleRow(context, 'AI Insights', 'Daily AI-powered health recommendations', false),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Privacy & Security'),
            const SizedBox(height: 12),
            _buildToggleRow(context, 'Private Profile', 'Only you can see your health data', true),
            _buildToggleRow(context, 'Data Analytics', 'Allow Bonyan to improve using your data', false),
            _buildToggleRow(context, 'Research Studies', 'Participate in health research (optional)', false),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Appearance'),
            const SizedBox(height: 12),
            _buildAppearanceOption(context),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Language & Region'),
            const SizedBox(height: 12),
            _buildSelectRow(context, 'Language', ['English (US)', 'English (UK)', 'Spanish', 'French', 'Arabic']),
            const SizedBox(height: 12),
            _buildSelectRow(context, 'Timezone', ['UTC-5 (Eastern Time)', 'UTC-6 (Central Time)', 'UTC-7 (Mountain Time)', 'UTC-8 (Pacific Time)', 'UTC+0 (GMT)']),
            const SizedBox(height: 12),
            _buildMeasurementOption(context),
            const SizedBox(height: 24),

            // FIXED: Removed the fatal `Size.fromHeight` infinite width issue!
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      minimumSize: const Size(0, 52), // FIXED BOUNDS
                    ),
                    child: const Text('Save Changes', overflow: TextOverflow.ellipsis, maxLines: 1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurface,
                      side: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      minimumSize: const Size(0, 52), // FIXED BOUNDS
                    ),
                    child: const Text('Reset', overflow: TextOverflow.ellipsis, maxLines: 1),
                  ),
                ),
              ],
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

  Widget _buildToggleRow(BuildContext context, String title, String subtitle, bool enabled) {
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
          Checkbox(value: enabled, onChanged: (_) {}),
        ],
      ),
    );
  }

  Widget _buildAppearanceOption(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
              _buildPill(context, 'Light', true),
              const SizedBox(width: 10),
              _buildPill(context, 'Dark', false),
              const SizedBox(width: 10),
              _buildPill(context, 'System', false),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Accent Color',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: [
              _buildAccentDot(context, colorScheme.primary, true),
              _buildAccentDot(context, Colors.blue.shade500, false),
              _buildAccentDot(context, Colors.orange.shade500, false),
              _buildAccentDot(context, Colors.pink.shade500, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementOption(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
            'Measurement Units',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPill(context, 'Metric (kg, cm)', true),
              const SizedBox(width: 10),
              _buildPill(context, 'Imperial (lbs, in)', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectRow(BuildContext context, String label, List<String> options) {
    final colorScheme = Theme.of(context).colorScheme;
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
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: options.first,
            isExpanded: true, // FIXED: Prevents text overflow crashes in dropdowns
            decoration: InputDecoration(
              filled: true,
              fillColor: colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.24)),
              ),
            ),
            items: options
                .map(
                  (option) => DropdownMenuItem(
                value: option,
                child: Text(option),
              ),
            )
                .toList(),
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }

  Widget _buildPill(BuildContext context, String label, bool selected) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
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
    );
  }

  Widget _buildAccentDot(BuildContext context, Color color, bool selected) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: selected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
      ),
    );
  }
}