import 'package:hive/hive.dart';

import '../../domain/entities/flashcard.dart';

class FlashcardModel {
  const FlashcardModel({
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

  Flashcard toEntity() => Flashcard(
        id: id,
        deckId: deckId,
        question: question,
        answer: answer,
        category: category,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory FlashcardModel.fromEntity(Flashcard card) => FlashcardModel(
        id: card.id,
        deckId: card.deckId,
        question: card.question,
        answer: card.answer,
        category: card.category,
        createdAt: card.createdAt,
        updatedAt: card.updatedAt,
      );
}

class FlashcardModelAdapter extends TypeAdapter<FlashcardModel> {
  static const int typeIdValue = 1;

  @override
  int get typeId => typeIdValue;

  @override
  FlashcardModel read(BinaryReader reader) {
    return FlashcardModel(
      id: reader.readString(),
      deckId: reader.readString(),
      question: reader.readString(),
      answer: reader.readString(),
      category: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, FlashcardModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.deckId)
      ..writeString(obj.question)
      ..writeString(obj.answer)
      ..writeString(obj.category)
      ..writeInt(obj.createdAt.millisecondsSinceEpoch)
      ..writeInt(obj.updatedAt.millisecondsSinceEpoch);
  }
}
