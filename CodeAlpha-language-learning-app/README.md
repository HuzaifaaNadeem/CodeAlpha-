# Lingua — Signature Language Learning

A polished, offline-first Flutter language learning application built for CodeAlpha Task 4.

## Included

- Mobile-first light UI
- Built-in Spanish beginner course
- 5 lessons / 40 useful vocabulary & phrase items
- Card-by-card lessons
- Pronunciation cues
- Context examples
- Favorites
- Lesson completion
- Streak tracking
- Practice accuracy
- 3D flashcards
- 4-option MCQ quizzes with instant feedback
- Matching-pair exercise
- Offline progress persistence with SharedPreferences
- Home / Learn / Practice / Profile tabs
- Riverpod state management
- Feature-first clean architecture
- Repository abstraction
- Unit and widget tests

## Project architecture

```
lib/
  core/
    theme/
    utils/
  features/
    learning/
      domain/
        entities/
        repositories/
      data/
        sources/
        repositories/
      presentation/
        providers/
        screens/
        widgets/
```

## First setup

A web target is already included for your current Chrome workflow. After extracting it into its own directory, run:

```powershell
flutter pub get
dart format lib test
flutter analyze
flutter test
```

Then launch on Chrome:

```powershell
flutter run -d chrome
```

## Notes

- All lesson content and progress work offline.
- The Pronounce action currently shows phonetic pronunciation cues. Real TTS/audio can be added later without changing the learning data model.
- The starter course is English → Spanish. `StarterCourse` is isolated so more languages can be added cleanly later.

For Android later, generate only the Android platform folder with `flutter create --platforms=android .` after backing up source files, then configure the Android SDK.
