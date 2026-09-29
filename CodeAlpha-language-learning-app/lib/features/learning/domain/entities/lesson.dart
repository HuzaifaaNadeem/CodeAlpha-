import 'learning_item.dart';

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.colorValue,
    required this.items,
  });

  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final int colorValue;
  final List<LearningItem> items;
}
