class Flashcard {
  const Flashcard({
    required this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String deckId;
  final String question;
  final String answer;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Flashcard copyWith({
    String? question,
    String? answer,
    String? category,
    DateTime? updatedAt,
  }) {
    return Flashcard(
      id: id,
      deckId: deckId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
