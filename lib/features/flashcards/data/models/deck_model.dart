import 'package:hive/hive.dart';

import '../../domain/entities/deck.dart';

class DeckModel {
  const DeckModel({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  final String id;
  final String title;
  final DateTime createdAt;

  Deck toEntity() => Deck(id: id, title: title, createdAt: createdAt);

  factory DeckModel.fromEntity(Deck deck) => DeckModel(
        id: deck.id,
        title: deck.title,
        createdAt: deck.createdAt,
      );
}

class DeckModelAdapter extends TypeAdapter<DeckModel> {
  static const int typeIdValue = 0;

  @override
  int get typeId => typeIdValue;

  @override
  DeckModel read(BinaryReader reader) {
    return DeckModel(
      id: reader.readString(),
      title: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, DeckModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.title)
      ..writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}
