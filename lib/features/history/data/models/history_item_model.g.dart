// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryItemModelAdapter extends TypeAdapter<HistoryItemModel> {
  @override
  final int typeId = 3;

  @override
  HistoryItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryItemModel(
      id: fields[0] as String,
      sourceText: fields[1] as String,
      translatedText: fields[2] as String,
      sourceLanguage: fields[3] as String,
      targetLanguage: fields[4] as String,
      timestamp: fields[5] as DateTime,
      isFavorite: fields[6] as bool,
      confidence: fields[7] as double?,
      alternatives: (fields[8] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, HistoryItemModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sourceText)
      ..writeByte(2)
      ..write(obj.translatedText)
      ..writeByte(3)
      ..write(obj.sourceLanguage)
      ..writeByte(4)
      ..write(obj.targetLanguage)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.isFavorite)
      ..writeByte(7)
      ..write(obj.confidence)
      ..writeByte(8)
      ..write(obj.alternatives);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
