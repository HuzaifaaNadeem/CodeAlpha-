import 'package:hive/hive.dart';

import '../../domain/entities/quiz_stat.dart';

class QuizStatModel {
  const QuizStatModel({
    required this.id,
    required this.deckId,
    required this.correct,
    required this.incorrect,
    required this.durationSeconds,
    required this.completedAt,
  });

  final String id;
  final String deckId;
  final int correct;
  final int incorrect;
  final int durationSeconds;
  final DateTime completedAt;

  QuizStat toEntity() => QuizStat(
        id: id,
        deckId: deckId,
        correct: correct,
        incorrect: incorrect,
        durationSeconds: durationSeconds,
        completedAt: completedAt,
      );

  factory QuizStatModel.fromEntity(QuizStat stat) => QuizStatModel(
        id: stat.id,
        deckId: stat.deckId,
        correct: stat.correct,
        incorrect: stat.incorrect,
        durationSeconds: stat.durationSeconds,
        completedAt: stat.completedAt,
      );
}

class QuizStatModelAdapter extends TypeAdapter<QuizStatModel> {
  static const int typeIdValue = 2;

  @override
  int get typeId => typeIdValue;

  @override
  QuizStatModel read(BinaryReader reader) {
    return QuizStatModel(
      id: reader.readString(),
      deckId: reader.readString(),
      correct: reader.readInt(),
      incorrect: reader.readInt(),
      durationSeconds: reader.readInt(),
      completedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, QuizStatModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.deckId)
      ..writeInt(obj.correct)
      ..writeInt(obj.incorrect)
      ..writeInt(obj.durationSeconds)
      ..writeInt(obj.completedAt.millisecondsSinceEpoch);
  }
}
