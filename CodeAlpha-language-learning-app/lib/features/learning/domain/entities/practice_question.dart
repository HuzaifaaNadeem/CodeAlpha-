import 'learning_item.dart';

class PracticeQuestion {
  const PracticeQuestion({
    required this.prompt,
    required this.answer,
    required this.options,
    required this.item,
  });

  final String prompt;
  final String answer;
  final List<String> options;
  final LearningItem item;
}
