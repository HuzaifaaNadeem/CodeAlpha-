## Built-in starter decks

Fliply seeds seven editable starter decks on first launch, each with eight ready-to-study cards:

- Computer Science Basics
- General Knowledge
- English Vocabulary
- Mathematics
- World Capitals
- Science
- Programming Fundamentals

Starter content is written only once per local installation, so deleted starter decks stay deleted and user-created data is never overwritten.

# Fliply — Flutter Flashcard Quiz App

A bright, offline-first flashcard study application built with Flutter, Riverpod, and Hive.

## Highlights

- Friendly light-first Material 3 interface
- Color-coded deck cards and polished learning dashboard
- Feature-first clean architecture (`domain / data / presentation`)
- Riverpod state management
- Hive offline persistence
- Deck and flashcard CRUD
- 180° 3D flashcard flip animation
- Swipe + Previous/Next study navigation
- Self-assessment quiz mode: **Forgot** / **Got it!**
- Accuracy and time summary after every quiz
- Persistent quiz statistics
- Haptic feedback
- Skeleton loaders and illustrated empty states
- Responsive layouts suitable for mobile, web, and desktop

## Project structure

```text
lib/
  core/
    theme/
    widgets/
  features/
    flashcards/
      data/
      domain/
      presentation/
```

## Run

If this source package has not had Flutter platform folders generated yet:

```bash
flutter create .
flutter pub get
```

Then validate:

```bash
dart format lib test
flutter analyze
flutter test
```

Run in Chrome:

```bash
flutter run -d chrome
```

Run on Windows after installing Visual Studio's **Desktop development with C++** workload:

```bash
flutter run -d windows
```

## Main screens

1. **Home** — colorful dashboard and deck list
2. **Deck** — study/quiz launch actions plus card management
3. **Study** — stacked 3D flip cards with gestures and progress
4. **Quiz** — reveal answer, then mark Forgot or Got it
5. **Summary** — accuracy ring, remembered/forgotten totals, and elapsed time
6. **Add/Edit** — focused flashcard authoring form

## Storage

Hive stores decks, flashcards, and quiz statistics locally, so the app continues to work offline.

## MCQ Quiz Mode

Fliply now includes a true multiple-choice quiz mode in addition to Study and Self Assessment.

- Up to 10 shuffled questions per attempt.
- Four distinct shuffled choices per question.
- Distractors prefer the same deck, then the same category, then the wider local library.
- Immediate green/red answer feedback with haptics.
- Live score and question progress.
- Persistent accuracy and completion time using the existing Hive statistics store.
- Retry with a freshly shuffled quiz.
- Review screen showing every missed question, the selected answer, and the correct answer.
