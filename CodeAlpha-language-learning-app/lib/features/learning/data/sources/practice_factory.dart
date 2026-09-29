import 'dart:math';

import '../../domain/entities/learning_item.dart';
import '../../domain/entities/practice_question.dart';

class PracticeFactory {
  static List<PracticeQuestion> mcqQuestions(
    List<LearningItem> items, {
    int count = 8,
    int? seed,
  }) {
    if (items.length < 4) {
      return const [];
    }
    final random = Random(seed);
    final shuffled = [...items]..shuffle(random);
    final selected = shuffled.take(min(count, shuffled.length));

    return selected.map((item) {
      final distractors = items
          .where((other) => other.id != item.id && other.target != item.target)
          .map((other) => other.target)
          .toSet()
          .toList()
        ..shuffle(random);
      final options = <String>[item.target, ...distractors.take(3)]
        ..shuffle(random);

      return PracticeQuestion(
        prompt: item.source,
        answer: item.target,
        options: options,
        item: item,
      );
    }).toList();
  }

  static List<LearningItem> flashcards(List<LearningItem> items, {int? seed}) {
    final random = Random(seed);
    return [...items]..shuffle(random);
  }

  static List<LearningItem> matchingItems(
    List<LearningItem> items, {
    int count = 5,
    int? seed,
  }) {
    final random = Random(seed);
    final shuffled = [...items]..shuffle(random);
    return shuffled.take(min(count, shuffled.length)).toList();
  }
}
