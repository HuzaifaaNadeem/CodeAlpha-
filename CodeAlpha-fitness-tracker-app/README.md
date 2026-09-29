# PulseFit MAX — Signature Performance OS

A portfolio-grade Flutter fitness and wellness tracker built with feature-first clean architecture, Riverpod, local persistence, live mobile pedometer support, and a premium mobile-first UI.

## Flagship feature set

### Live movement
- Android/iOS live pedometer stream via `pedometer`
- Runtime motion permission via `permission_handler`
- Walking/stopped status when available
- Positive sensor deltas automatically merge into today's steps
- Browser review mode uses a clearly labeled demo sensor instead of pretending Chrome can read physical steps
- Manual steps remain available as a fallback

### Today dashboard
- Daily step goal and animated progress ring
- Distance, floors, active minutes, workout calories
- Live sensor connection state
- Daily wellness score (non-medical)
- Sleep, resting HR, mood and mindfulness
- Hydration tracking
- Calories, protein, carbs and fat tracking
- Quick actions for workout, nutrition, recovery and water
- Today's workout history

### Live workout engine
- 13 activity types
- Live stopwatch
- Pause/resume
- Lap markers
- Light / Moderate / Hard intensity
- MET + body-weight calorie estimation
- Estimated distance for distance-based activities
- Optional planned workout target duration
- Finish protection while a session is running
- Automatic history persistence

### Training programs
- Balanced Foundation — 4 weeks
- 5K Momentum — 6 weeks
- Strength Builder — 8 weeks
- Seven-day weekly prescriptions
- Exercise details for every day
- Active-program selection
- Planned workout launch directly into live workout mode

### Activity history
- Search workouts
- Filter by activity type
- Edit sessions
- Delete with confirmation
- Session totals for minutes and calories
- Manual quick logging

### Insights
- Steps / burn / active minutes / sleep chart modes
- Weekly goal completion
- Step streak
- Average wellness
- Weekly workout adherence
- Average sleep and hydration
- Personal records
- Achievement system with progress bars

### Achievements
- First Move
- 10K Club
- Week Warrior
- 50K Week
- Hydration Hero
- Century Walker
- Time Under Tension
- Early Bird

### Profile & goals
- Name, age, height, body weight and target weight
- Step goal
- Active-minute goal
- Workout-calorie goal
- Hydration goal
- Sleep goal
- Calorie-intake target
- Protein target
- Weekly-workout target
- Current training plan

### Data & privacy
- Offline-first persistence with SharedPreferences
- v1 → v2 local data migration
- Copy full JSON backup
- Copy CSV history export
- Local reset with rich demo reseeding
- No cloud account required

## Architecture

```text
lib/
  core/
    theme/
    widgets/
  features/fitness/
    data/
      repositories/
      services/
    domain/
      entities/
      repositories/
    presentation/
      controllers/
      screens/
      widgets/
```

## Run on Chrome

Chrome is ideal for reviewing the complete UI. The live step card is explicitly a browser demo.

```powershell
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run -d chrome
```

## Run with real live steps on Android

1. Install Android Studio + Android SDK.
2. If this source package does not yet have platform folders, run `flutter create .` once.
3. Apply `platform_setup/ANDROID_STEP_TRACKING.md`.
4. Connect a physical Android device.
5. Run `flutter run` and tap **Connect live steps**.

The pedometer plugin currently supports Android and iOS, and Android 10+ requires `ACTIVITY_RECOGNITION` permission.

## iOS

See `platform_setup/IOS_STEP_TRACKING.md`.

## Important health note

PulseFit is a fitness/wellness product, not a medical device. Wellness scores, resting-heart-rate entries, calorie estimates, and training suggestions are intended for personal fitness tracking and should not be used for diagnosis or treatment decisions.
