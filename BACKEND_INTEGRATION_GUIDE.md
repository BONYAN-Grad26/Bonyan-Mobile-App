# Flutter Backend Integration Guide

## 📋 Step 1: API Endpoints Analysis

### Authentication Endpoints
**Base URL:** `/api/auth`

| Method | Endpoint | Request | Response |
|--------|----------|---------|----------|
| POST | `/register` | `RegisterRequest` | `String` (success message) |
| POST | `/login` | `LoginRequest` | `AuthResponse` |
| POST | `/confirm-email` | `ConfirmEmailRequest` | `AuthResponse` |
| POST | `/resend-otp` | `{ email: string }` | `String` (success message) |

### Health Profile Endpoints
**Base URL:** `/api/health-profile`

| Method | Endpoint | Request | Response |
|--------|----------|---------|----------|
| GET | `/me` | — | `HealthMetrics` |
| GET | `/{id}` | — | `HealthMetrics` |
| POST | `/` | `HealthMetrics` | `HealthMetrics` |
| PUT | `/{id}` | `HealthMetrics` | `HealthMetrics` |
| DELETE | `/{id}` | — | `String` |

### Diet Plan Endpoints
**Base URL:** `/api/diet-plan`

| Method | Endpoint | Request | Response |
|--------|----------|---------|----------|
| POST | `/generate-weekly` | `?startDate=YYYY-MM-DD&weekNumber=1` | `WeeklyPlan` |
| GET | `/weekly` | — | `List<WeeklyPlan>` |
| GET | `/{planId}` | — | `WeeklyPlan` |
| GET | `/daily/{planId}` | — | `DayPlan` |
| GET | `/today` | — | `DayPlan` |
| PUT | `/{planId}` | `WeeklyPlan` | `WeeklyPlan` |
| DELETE | `/{planId}` | — | `String` |

### Workout Plan Endpoints
**Base URL:** `/workout-plan`

| Method | Endpoint | Request | Response |
|--------|----------|---------|----------|
| POST | `/generate-weekly` | — | `WorkoutPlan` |
| GET | `/{id}` | — | `WorkoutPlan` |
| GET | `/user/{userId}` | — | `List<WorkoutPlan>` |
| GET | `/today` | — | `TodayWorkout` |
| DELETE | `/{id}` | — | `String` |

### User Endpoints
**Base URL:** `/api/user`

| Method | Endpoint | Request | Response |
|--------|----------|---------|----------|
| GET | `/{id}` | — | `UserProfile` |

---

## 📦 Step 2: Dart Models Generated

### Authentication Models
**File:** `lib/core/models/auth_models.dart`

1. **AuthResponse** - JWT token + expiry
   ```dart
   - accessToken: String
   - expiresIn: DateTime
   ```

2. **RegisterRequest** - User registration payload
   ```dart
   - firstName: String
   - lastName: String
   - email: String
   - password: String
   ```

3. **LoginRequest** - User login payload
   ```dart
   - email: String
   - password: String
   ```

4. **ConfirmEmailRequest** - Email verification payload
   ```dart
   - email: String
   - otp: String
   ```

5. **UserProfile** - User account info
   ```dart
   - firstName: String
   - lastName: String
   - email: String
   ```

### Health Metrics Models
**File:** `lib/core/models/health_metrics_models.dart`

1. **HealthMetrics** - Full health profile (optional fields for null values)
   ```dart
   - id: int?
   - age: int?
   - weightKg: double?
   - heightCm: double?
   - muscleMassKg: double?
   - fatPercentage: double?
   - gender: Gender?
   - activityLevel: ActivityLevel?
   - medicalNotes: String?
   - dietType: DietType?
   - dietGoal: DietGoal?
   - bmi: double?
   - bmiCategory: String?
   - tdee: int?
   - fatMass: double?
   - leanMass: double?
   - bodyFatCategory: String?
   - targetWeightKg: double?
   - dailyCalorieTarget: int?
   ```

2. **Enums**
   - `Gender`: male, female, other
   - `ActivityLevel`: sedentary, light, moderate, active, veryActive
   - `DietGoal`: loseFat, gainMuscle, maintain, bulkUp
   - `DietType`: balanced, lowCarb, highProtein, keto, vegan, vegetarian

### Diet Plan Models
**File:** `lib/core/models/diet_plan_models.dart`

1. **Ingredient** - Individual ingredient in a meal
   ```dart
   - ingredientId: int?
   - ingredientName: String?
   - quantity: double?
   - measurementUnit: String? (g, ml, kg, l, cup, tbsp, tsp, piece, oz, lb)
   ```

2. **Meal** - Single meal entry
   ```dart
   - id: int?
   - name: String?
   - mealType: String? (Breakfast, Lunch, Dinner, Snack)
   - description: String?
   - preparationTime: int?
   - preparationInstructions: String?
   - order: int?
   - ingredients: List<Ingredient>?
   ```

3. **DayPlan** - Single day's meal plan
   ```dart
   - id: int?
   - date: String? (YYYY-MM-DD)
   - dayOfWeek: int? (1-7)
   - targetCalories: double?
   - targetProtein: double?
   - targetCarbs: double?
   - targetFat: double?
   - targetFiber: double?
   - targetSugar: double?
   - waterGoal: double?
   - aiDailyTips: String?
   - meals: List<Meal>?
   ```

4. **WeeklyPlan** - Complete weekly meal plan
   ```dart
   - id: int?
   - weekNumber: int?
   - startDate: String?
   - endDate: String?
   - weeklyCalorieTarget: double?
   - weeklyProteinTarget: double?
   - weeklyCarbTarget: double?
   - weeklyFatTarget: double?
   - weeklyStrategy: String?
   - aiPreparationTips: String?
   - days: List<DayPlan>?
   ```

### Workout Models
**File:** `lib/core/models/workout_models.dart`

1. **Exercise** - Individual exercise
   ```dart
   - name: String?
   - sets: int?
   - reps: String? (e.g., "8-10", "5", "AMRAP")
   - restSeconds: int?
   - notes: String?
   ```

2. **WorkoutDay** - Single workout session
   ```dart
   - session: String? (e.g., "Upper Body A")
   - focus: String? (e.g., "Chest, Back, Shoulders")
   - exercises: List<Exercise>?
   ```

3. **WorkoutPlan** - Weekly workout plan
   ```dart
   - planName: String? (e.g., "Push/Pull/Legs")
   - splitType: String? (PPL, Upper/Lower, FullBody)
   - splitReasoning: String?
   - weeklySchedule: Map<String, WorkoutDay>? (Keys: day names)
   ```

4. **TodayWorkout** - Today's workout session
   ```dart
   - session: String?
   - focus: String?
   - exercises: List<Exercise>?
   - date: DateTime?
   ```

---

## 🎯 Step 4: Integration Mapping

### HomeTab Widget
**Responsibilities:** Overview dashboard with health metrics summary

**Calls:**
- `HealthMetricsRepository.getMyHealthProfile()` → Display BMI, TDEE, body fat category
- `DietPlanRepository.getTodayPlan()` → Show meal plan summary & progress
- `WorkoutRepository.getTodayWorkout()` → Display today's workout info

**Related Models:**
- `HealthMetrics` (for BMI card, body fat info)
- `DayPlan` (for meal summary)
- `TodayWorkout` (for workout summary)

---

### MealsTab Widget
**Responsibilities:** View and manage meal plans

**Calls:**
- `DietPlanRepository.getWeeklyPlans()` → List all weekly plans
- `DietPlanRepository.getTodayPlan()` → Show current day's meals
- `DietPlanRepository.generateWeeklyPlan(startDate, weekNumber)` → Create new plan
- `DietPlanRepository.updateWeeklyPlan(planId, plan)` → Modify existing plan
- `DietPlanRepository.deleteWeeklyPlan(planId)` → Remove plan

**Related Models:**
- `WeeklyPlan` (for weekly view)
- `DayPlan` (for daily view)
- `Meal` (for individual meal display)
- `Ingredient` (for recipe details)

---

### WorkoutsTab Widget
**Responsibilities:** View and manage workout plans

**Calls:**
- `WorkoutRepository.generateWeeklyWorkoutPlan()` → Create new plan
- `WorkoutRepository.getById(planId)` → View specific plan
- `WorkoutRepository.getTodayWorkout()` → Show today's session
- `WorkoutRepository.deletePlan(planId)` → Remove workout

**Related Models:**
- `WorkoutPlan` (for weekly overview)
- `TodayWorkout` (for current session)
- `WorkoutDay` (for individual day view)
- `Exercise` (for exercise details)

---

### ProfilePage Widget
**Responsibilities:** View and edit user health profile

**Calls:**
- `HealthMetricsRepository.getMyHealthProfile()` → Display current metrics
- `HealthMetricsRepository.updateHealthProfile(updatedMetrics)` → Save changes
- `HealthMetricsRepository.createHealthProfile(metrics)` → Initial setup
- `AuthRepository.getUserProfile()` → Display name and email
- `HealthMetricsRepository.deleteHealthProfile(id)` → Remove profile (optional)

**Related Models:**
- `HealthMetrics` (for all health data)
- `UserProfile` (for name/email)
- Enums: `Gender`, `ActivityLevel`, `DietGoal`, `DietType`

---

### SettingsPage Widget
**Recommendations:**
- Store JWT token in `SharedPreferences` or `SecureStorage`
- Display app theme, language, notifications (local settings)
- Logout calls `AuthRepository.logout()` → Clear token & redirect to login

**Possible Calls:**
- Local settings: No API call
- Logout: `AuthRepository.logout()`

---

## 🔐 Authentication Flow for All Repositories

Every repository method should:

1. **Check Token:** Verify JWT is stored and not expired
2. **Add Authorization Header:**
   ```dart
   headers: {
     'Authorization': 'Bearer $accessToken',
     'Content-Type': 'application/json',
   }
   ```
3. **Handle 401 Unauthorized:**
   - Clear stored token
   - Redirect user to login
4. **Catch Exceptions:** Network errors, parse errors, validation errors

---

## 📝 Next Steps

**Step 3 will generate:**
1. `AuthRepository` - Login, register, token refresh
2. `HealthMetricsRepository` - CRUD operations on health data
3. `DietPlanRepository` - Meal plan operations
4. `WorkoutRepository` - Workout plan operations
5. `UserRepository` - User profile operations

Each repository will include:
- Proper HTTP client setup with auth headers
- Error handling with custom exceptions
- JSON serialization/deserialization using the models above
- Null safety and optional field handling
