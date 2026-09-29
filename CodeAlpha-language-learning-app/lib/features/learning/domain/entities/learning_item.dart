class LearningItem {
  const LearningItem({
    required this.id,
    required this.source,
    required this.target,
    required this.pronunciation,
    required this.example,
    required this.kind,
  });

  final String id;
  final String source;
  final String target;
  final String pronunciation;
  final String example;
  final LearningItemKind kind;
}

enum LearningItemKind { vocabulary, phrase }
