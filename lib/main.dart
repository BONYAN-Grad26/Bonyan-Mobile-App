
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';



import 'core/theme/app_theme.dart';

import 'features/auth/presentation/pages/login_page.dart';

import 'features/auth/presentation/providers/auth_provider.dart';

import 'features/dashboard/presentation/pages/main_dashboard.dart';

import 'features/onboarding/data/repositories/metrics_repository.dart';

import 'features/onboarding/presentation/pages/onboarding_wizard.dart';

import 'features/onboarding/presentation/providers/onboarding_provider.dart';



void main() {

  runApp(const MyApp());

}



class MyApp extends StatelessWidget {

  const MyApp({super.key});



  @override

  Widget build(BuildContext context) {

    return MultiProvider(

      providers: [

        ChangeNotifierProvider<AuthProvider>(

          create: (_) => AuthProvider(),

        ),

        ChangeNotifierProvider<OnboardingProvider>(

          create: (_) => OnboardingProvider(metricsRepository: MetricsRepository()),

        ),

      ],

      child: MaterialApp(

        title: 'Bonyaan',

        theme: AppTheme.lightTheme,

        darkTheme: AppTheme.darkTheme,

        themeMode: ThemeMode.system,

        home: Consumer2<AuthProvider, OnboardingProvider>(

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



                  // This defers the call until the frame finishes rendering

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



                if (onboardingProvider.submissionStatus == OnboardingSubmissionStatus.success ||

                    onboardingProvider.savedProfile != null) {

                  return const MainDashboard();

                }



                return const OnboardingWizard();

              case AuthStatus.unauthenticated:

                return const LoginPage();

            }

          },

        ),

      ),

    );

  }

} 

