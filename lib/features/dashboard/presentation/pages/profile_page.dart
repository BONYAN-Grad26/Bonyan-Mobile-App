import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/providers/allergy_provider.dart';
import '../../../../core/widgets/bonyaan_logo.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNavigateToSettings;

  const ProfilePage({super.key, this.onBack, this.onNavigateToSettings});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  Future<void> _loadProfileData() async {
    final profileProvider = context.read<ProfileProvider>();
    final allergyProvider = context.read<AllergyProvider>();
    await Future.wait([
      profileProvider.fetchMyHealthProfile(),
      allergyProvider.fetchMyAllergies(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final profileProvider = context.watch<ProfileProvider>();
    final authProvider = context.watch<AuthProvider>();
    final allergyProvider = context.watch<AllergyProvider>();

    if (profileProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profileProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(profileProvider.errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfileData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final progressProvider = context.watch<ProgressProvider>();
    
    final authUser = authProvider.currentUser;
    final customFirst = progressProvider.customFirstName;
    final customLast = progressProvider.customLastName;
    
    final firstName = customFirst.isNotEmpty ? customFirst : (authUser?.firstName ?? '');
    final lastName = customLast.isNotEmpty ? customLast : (authUser?.lastName ?? '');
    
    final fullName = '$firstName $lastName'.trim().isEmpty ? 'User' : '$firstName $lastName'.trim();
                      
    final metrics = profileProvider.healthMetrics;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 20), // Added whitespace at the top
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
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
                        child: Text(
                          'My Profile',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18, // Smaller text
                                color: colorScheme.onSurface,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.onNavigateToSettings != null)
                  IconButton(
                    onPressed: widget.onNavigateToSettings,
                    icon: Icon(Icons.settings_outlined, color: colorScheme.primary, size: 28),
                  )
                else
                  const BonyaanLogo.small(),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Personal Data',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colorScheme.outline,
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.secondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 36,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    fullName,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () {
                                    final firstCtrl = TextEditingController(text: firstName);
                                    final lastCtrl = TextEditingController(text: lastName);
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Edit Name'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(controller: firstCtrl, decoration: const InputDecoration(labelText: 'First Name')),
                                            const SizedBox(height: 10),
                                            TextField(controller: lastCtrl, decoration: const InputDecoration(labelText: 'Last Name')),
                                          ],
                                        ),
                                        actions: [
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    progressProvider.setCustomName(firstCtrl.text, lastCtrl.text);
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Save'),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                style: TextButton.styleFrom(
                                                  minimumSize: const Size.fromHeight(48),
                                                  padding: EdgeInsets.zero,
                                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                ),
                                                child: const Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            if (authUser?.email != null && authUser!.email.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                authUser.email,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(0.70),
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildProfileStat(context, 'Age', metrics?.age?.toString() ?? 'N/A')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildProfileStat(context, 'Gender', metrics?.gender?.name ?? 'N/A')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildProfileStat(context, 'Height', '${metrics?.heightCm ?? 0} cm')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildProfileStat(context, 'Weight', '${metrics?.weightKg ?? 0} kg')),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Health Metrics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colorScheme.outline,
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BMI & Body Composition',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 18),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildMetricTile(context, 'BMI', _calculateBMI(metrics), 'Normal')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildMetricTile(context, 'Lean Mass', '${metrics?.muscleMassKg ?? 'N/A'} kg', null)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildMetricTile(context, 'Fat %', '${metrics?.fatPercentage ?? 'N/A'}%', null)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildMetricTile(context, 'TDEE', '${metrics?.dailyCalorieTarget ?? 'N/A'}', 'kcal/day')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Goals',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildMetricTile(context, 'Primary Goal', metrics?.dietGoal?.name ?? 'N/A', null)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildMetricTile(context, 'Target Weight', '${metrics?.targetWeightKg ?? 'N/A'} kg', null)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildMetricTile(context, 'Diet Type', metrics?.dietType?.name ?? 'N/A', null)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildMetricTile(context, 'Daily Calorie Goal', '${metrics?.dailyCalorieTarget ?? 'N/A'} kcal', null)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Medical & Allergies',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colorScheme.outline,
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      allergyProvider.allergies.isNotEmpty
                          ? 'Allergies: ${allergyProvider.allergies.map((a) => a.name).join(', ')}'
                          : 'Allergies: None recorded',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      metrics?.medicalNotes != null && metrics!.medicalNotes!.isNotEmpty 
                          ? 'Medical Notes: ${metrics.medicalNotes}' 
                          : 'Medical Notes: None provided',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.75),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120), // Padding for floating nav bar
          ],
        ),
      ),
    );
  }

  String _calculateBMI(dynamic metrics) {
    if (metrics == null || metrics.weightKg == null || metrics.heightCm == null || metrics.heightCm == 0) {
      return 'N/A';
    }
    final heightM = metrics.heightCm! / 100;
    final bmi = metrics.weightKg! / (heightM * heightM);
    return bmi.toStringAsFixed(1);
  }

  Widget _buildProfileStat(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.70),
                  ),
            ),
          ),
          const SizedBox(height: 4),
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

  Widget _buildMetricTile(BuildContext context, String label, String value, String? subtitle) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outline,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.70),
                  ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.70),
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
