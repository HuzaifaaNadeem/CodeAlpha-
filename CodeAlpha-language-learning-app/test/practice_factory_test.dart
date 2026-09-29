import 'package:codealpha_language_learning_app/features/learning/data/sources/practice_factory.dart';
import 'package:codealpha_language_learning_app/features/learning/data/sources/starter_course.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MCQ factory creates four distinct choices with the correct answer', () {
    final questions = PracticeFactory.mcqQuestions(
      StarterCourse.allItems,
      count: 8,
      seed: 42,
    );

    expect(questions, hasLength(8));
    for (final question in questions) {
      expect(question.options, hasLength(4));
      expect(question.options.toSet(), hasLength(4));
      expect(question.options, contains(question.answer));
    }
  });
}
