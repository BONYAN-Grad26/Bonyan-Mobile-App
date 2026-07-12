
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bonyaan_app/core/theme/app_theme.dart';
import 'package:bonyaan_app/core/network/api_client.dart';
import 'package:bonyaan_app/core/network/token_storage_impl.dart';
import 'package:bonyaan_app/core/repositories/repositories.dart';
import 'package:bonyaan_app/core/providers/providers.dart';
import 'package:bonyaan_app/features/auth/presentation/pages/login_page.dart';
import 'package:bonyaan_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bonyaan_app/features/dashboard/presentation/pages/main_dashboard.dart';
import 'package:bonyaan_app/features/onboarding/data/repositories/metrics_repository.dart';
import 'package:bonyaan_app/features/onboarding/presentation/pages/onboarding_wizard.dart';
import 'package:bonyaan_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:bonyaan_app/features/splash/splash_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  final tokenStorage = SharedPreferencesTokenStorage();
  final authProvider = AuthProvider(tokenStorage: tokenStorage);
  
  final apiClient = ApiClient(
    baseUrl: const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080'),
    tokenStorage: tokenStorage,
    onUnauthorized: () {
      authProvider.logout();
      Future.microtask(() {
        final ctx = globalNavigatorKey.currentContext;
        if (ctx != null) {
          ctx.read<OnboardingProvider>().reset();
          ctx.read<DietPlanProvider>().reset();
          ctx.read<WorkoutProvider>().reset();
          ctx.read<ProfileProvider>().reset();
        }
        globalNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      });
    },
  );

  runApp(MyApp(apiClient: apiClient, authProvider: authProvider, prefs: prefs));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  final AuthProvider authProvider;
  final SharedPreferences prefs;

  const MyApp({super.key, required this.apiClient, required this.authProvider, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
        ),
        ChangeNotifierProvider<OnboardingProvider>(
          create: (_) => OnboardingProvider(metricsRepository: MetricsRepository(apiClient: apiClient)),
        ),
        ChangeNotifierProvider<DietPlanProvider>(
          create: (_) => DietPlanProvider(dietPlanRepository: DietPlanRepository(apiClient: apiClient)),
        ),
        ChangeNotifierProvider<WorkoutProvider>(
          create: (_) => WorkoutProvider(workoutRepository: WorkoutRepository(apiClient: apiClient)),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(
            userRepository: UserRepository(apiClient: apiClient),
            healthProfileRepository: HealthProfileRepository(apiClient: apiClient),
          ),
        ),
        ChangeNotifierProvider<AllergyProvider>(
          create: (_) => AllergyProvider(
            allergyRepository: AllergyRepository(apiClient: apiClient),
          ),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProgressProvider>(
          create: (_) => ProgressProvider(prefs: prefs),
          update: (_, auth, progress) {
            final p = progress ?? ProgressProvider(prefs: prefs);
            p.updateUserEmail(auth.currentUser?.email);
            return p;
          },
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (_) => ChatProvider(),
        ),
        ChangeNotifierProvider<MealSuggesterProvider>(
          create: (_) => MealSuggesterProvider(),
        ),
        ChangeNotifierProvider<MachineClassifierProvider>(
          create: (_) => MachineClassifierProvider(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            navigatorKey: globalNavigatorKey,
            title: 'Bonyaan',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            debugShowCheckedModeBanner: false,
            home: SplashScreen(
              child: Consumer2<AuthProvider, OnboardingProvider>(
                builder: (context, authProvider, onboardingProvider, _) {
                  switch (authProvider.status) {
                    case AuthStatus.initial:
                    case AuthStatus.loading:
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                    case AuthStatus.authenticated:
                      if (!onboardingProvider.hasCheckedExistingProfile &&
                          !onboardingProvider.isCheckingExistingProfile) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.read<OnboardingProvider>().loadExistingProfileIfNeeded();
                        });
                      }

                      if (onboardingProvider.isCheckingExistingProfile) {
                        return const Scaffold(
                          body: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (onboardingProvider.hasCheckedExistingProfile &&
                          onboardingProvider.savedProfile == null) {
                        return const OnboardingWizard();
                      }

                      return const MainDashboard();

                    case AuthStatus.unauthenticated:
                      return const LoginPage();
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
