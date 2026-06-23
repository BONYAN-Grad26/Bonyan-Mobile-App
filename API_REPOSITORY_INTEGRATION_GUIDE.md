# API Repository Integration Guide

## Overview

This guide shows how to integrate the `ApiClient`, repositories, and models into your Flutter app with Provider state management.

## Project Structure

```
lib/core/
├── models/
│   ├── auth_models.dart
│   ├── health_metrics_models.dart
│   ├── diet_plan_models.dart
│   ├── workout_models.dart
│   └── models.dart (barrel)
├── network/
│   ├── api_client.dart (HTTP client with JWT)
│   ├── exceptions.dart (Custom exceptions)
│   ├── token_storage_impl.dart (SharedPreferences impl)
│   └── network.dart (barrel)
└── repositories/
    ├── auth_repository.dart
    ├── health_profile_repository.dart
    └── repositories.dart (barrel)
```

## Step 1: Add Dependencies

Update `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  shared_preferences: ^2.2.0
  provider: ^6.0.0
```

Then run: `flutter pub get`

## Step 2: Initialize ApiClient (in main.dart or separate setup file)

```dart
import 'package:bonyaan_app/core/network/network.dart';
import 'package:bonyaan_app/core/repositories/repositories.dart';

// Initialize token storage and API client
final tokenStorage = SharedPreferencesTokenStorage();
final apiClient = ApiClient(
  baseUrl: 'http://your-backend-url:8080', // Configure based on environment
  tokenStorage: tokenStorage,
  timeout: const Duration(seconds: 30),
);

// Initialize repositories
final authRepository = AuthRepository(apiClient: apiClient);
final healthProfileRepository = HealthProfileRepository(apiClient: apiClient);
```

## Step 3: Create Provider Classes for State Management

### Example: AuthProvider (using ChangeNotifier)

```dart
import 'package:flutter/foundation.dart';
import 'package:bonyaan_app/core/repositories/repositories.dart';
import 'package:bonyaan_app/core/models/models.dart';
import 'package:bonyaan_app/core/network/exceptions.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthProvider({required this.authRepository});

  AuthResponse? _authResponse;
  bool _isLoading = false;
  String? _error;

  // Getters
  AuthResponse? get authResponse => _authResponse;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authResponse != null;

  // Register
  Future<void> register(RegisterRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final message = await authRepository.register(request);
      _error = null; // Registration successful
      print('Registered: $message');
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  // Login
  Future<void> login(LoginRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _authResponse = await authRepository.login(request);
      _error = null;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _authResponse = null;
      notifyListeners();
      rethrow;
    }
  }

  // Confirm Email
  Future<void> confirmEmail(ConfirmEmailRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _authResponse = await authRepository.confirmEmail(request);
      _error = null;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  // Resend OTP
  Future<void> resendOtp(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final message = await authRepository.resendOtp(email);
      _error = null;
      print('OTP sent: $message');
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await authRepository.logout();
      _authResponse = null;
      _error = null;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  // Check authentication
  Future<void> checkAuthentication() async {
    final isAuth = await authRepository.isAuthenticated();
    if (isAuth) {
      // Optionally refresh user info here
      notifyListeners();
    }
  }
}
```

### Example: HealthProfileProvider

```dart
import 'package:flutter/foundation.dart';
import 'package:bonyaan_app/core/repositories/repositories.dart';
import 'package:bonyaan_app/core/models/models.dart';
import 'package:bonyaan_app/core/network/exceptions.dart';

class HealthProfileProvider extends ChangeNotifier {
  final HealthProfileRepository repository;

  HealthProfileProvider({required this.repository});

  HealthMetrics? _healthMetrics;
  bool _isLoading = false;
  String? _error;

  // Getters
  HealthMetrics? get healthMetrics => _healthMetrics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _healthMetrics != null;

  // Load health profile
  Future<void> loadHealthProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _healthMetrics = await repository.getMyHealthProfile();
      _error = null;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  // Create health profile
  Future<void> createHealthProfile(HealthMetrics metrics) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _healthMetrics = await repository.createHealthProfile(metrics);
      _error = null;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  // Update health profile
  Future<void> updateHealthProfile(int id, HealthMetrics metrics) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _healthMetrics = await repository.updateHealthProfile(id, metrics);
      _error = null;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  // Delete health profile
  Future<void> deleteHealthProfile(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.deleteHealthProfile(id);
      _healthMetrics = null;
      _error = null;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }
}
```

## Step 4: Register Providers in main.dart

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bonyaan_app/core/network/network.dart';
import 'package:bonyaan_app/core/repositories/repositories.dart';

// Setup repositories and providers
final tokenStorage = SharedPreferencesTokenStorage();
final apiClient = ApiClient(
  baseUrl: 'http://192.168.1.100:8080',
  tokenStorage: tokenStorage,
);
final authRepository = AuthRepository(apiClient: apiClient);
final healthRepository = HealthProfileRepository(apiClient: apiClient);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (context) => HealthProfileProvider(repository: healthRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Bonyaan',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const HomePage(),
      ),
    );
  }
}
```

## Step 5: Usage in Widgets

### Login Example

```dart
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final authProvider = context.read<AuthProvider>();
    final request = LoginRequest(
      email: emailController.text,
      password: passwordController.text,
    );

    try {
      await authProvider.login(request);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
        // Navigate to home
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${authProvider.error}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _handleLogin,
                  child: authProvider.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

### Health Profile Example

```dart
class HealthProfilePage extends StatelessWidget {
  const HealthProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Profile')),
      body: Consumer<HealthProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Text('Error: ${provider.error}'),
            );
          }

          final metrics = provider.healthMetrics;
          if (metrics == null) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to health profile setup
                  Navigator.of(context).pushNamed('/health-setup');
                },
                child: const Text('Create Health Profile'),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              ListTile(
                title: const Text('Age'),
                subtitle: Text('${metrics.age} years'),
              ),
              ListTile(
                title: const Text('Weight'),
                subtitle: Text('${metrics.weightKg} kg'),
              ),
              ListTile(
                title: const Text('Height'),
                subtitle: Text('${metrics.heightCm} cm'),
              ),
              ListTile(
                title: const Text('BMI'),
                subtitle: Text('${metrics.bmi?.toStringAsFixed(1)} (${metrics.bmiCategory})'),
              ),
              ListTile(
                title: const Text('TDEE'),
                subtitle: Text('${metrics.tdee} kcal/day'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to edit profile
                  Navigator.of(context).pushNamed('/health-edit');
                },
                child: const Text('Edit Profile'),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

## Step 6: Environment Configuration

Create `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // DEV: http://192.168.1.100:8080
  // PROD: https://api.bonyaan.com
  // Staging: https://staging-api.bonyaan.com
  
  static const String devBaseUrl = 'http://192.168.1.100:8080';
  static const String prodBaseUrl = 'https://api.bonyaan.com';
  static const String stagingBaseUrl = 'https://staging-api.bonyaan.com';

  static String getBaseUrl(String environment) {
    switch (environment) {
      case 'dev':
        return devBaseUrl;
      case 'prod':
        return prodBaseUrl;
      case 'staging':
        return stagingBaseUrl;
      default:
        return devBaseUrl;
    }
  }
}
```

Update main.dart:

```dart
import 'package:bonyaan_app/config/api_config.dart';

final apiClient = ApiClient(
  baseUrl: ApiConfig.getBaseUrl('dev'),
  tokenStorage: tokenStorage,
);
```

## Error Handling

The repositories throw specific exceptions that you can catch:

```dart
import 'package:bonyaan_app/core/network/exceptions.dart';

try {
  await authRepository.login(request);
} on UnauthorizedException catch (e) {
  print('Invalid credentials: ${e.message}');
} on NetworkException catch (e) {
  print('Network error: ${e.message}');
} on ValidationException catch (e) {
  print('Validation error: ${e.message}');
  print('Errors: ${e.errors}');
} on ApiException catch (e) {
  print('API error: ${e.message}');
} catch (e) {
  print('Unknown error: $e');
}
```

## Best Practices

1. **Token Storage:** Tokens are automatically stored/retrieved. On 401, token is cleared.
2. **Error Handling:** Always wrap API calls in try/catch with specific exception types.
3. **Loading States:** Use `isLoading` getter to show loading indicators.
4. **UI Updates:** Providers automatically notify listeners on state changes.
5. **Null Safety:** All optional fields are nullable (marked with `?`).
6. **Timeouts:** Default 30s timeout can be customized per ApiClient.
7. **Testing:** Inject mock repositories in tests using Provider.override.

## Next Steps

Once repositories are working, you can:
1. Create providers for diet plans (`DietPlanProvider`)
2. Create providers for workouts (`WorkoutProvider`)
3. Implement offline caching with `sqflite`
4. Add automatic token refresh logic
5. Implement proper navigation flows
