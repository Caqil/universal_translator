// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationMessageModelAdapter
    extends TypeAdapter<ConversationMessageModel> {
  @override
  final int typeId = 3;

  @override
  ConversationMessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversationMessageModel(
      id: fields[0] as String,
      originalText: fields[1] as String,
      translatedText: fields[2] as String,
      sourceLanguage: fields[3] as String,
      targetLanguage: fields[4] as String,
      isUser1: fields[5] as bool,
      timestamp: fields[6] as DateTime,
      confidence: fields[7] as double,
      alternatives: (fields[8] as List).cast<String>(),
      emotion: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ConversationMessageModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.originalText)
      ..writeByte(2)
      ..write(obj.translatedText)
      ..writeByte(3)
      ..write(obj.sourceLanguage)
      ..writeByte(4)
      ..write(obj.targetLanguage)
      ..writeByte(5)
      ..write(obj.isUser1)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.confidence)
      ..writeByte(8)
      ..write(obj.alternatives)
      ..writeByte(9)
      ..write(obj.emotion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationMessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationMessageModel _$ConversationMessageModelFromJson(
        Map<String, dynamic> json) =>
    ConversationMessageModel(
      id: json['id'] as String,
      originalText: json['originalText'] as String,
      translatedText: json['translatedText'] as String,
      sourceLanguage: json['sourceLanguage'] as String,
      targetLanguage: json['targetLanguage'] as String,
      isUser1: json['isUser1'] as bool,
      timestamp: ConversationMessageModel._dateTimeFromJson(
          json['timestamp'] as String),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      alternatives: (json['alternatives'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      emotion: json['emotion'] as String?,
    );

Map<String, dynamic> _$ConversationMessageModelToJson(
        ConversationMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'originalText': instance.originalText,
      'translatedText': instance.translatedText,
      'sourceLanguage': instance.sourceLanguage,
      'targetLanguage': instance.targetLanguage,
      'isUser1': instance.isUser1,
      'timestamp': ConversationMessageModel._dateTimeToJson(instance.timestamp),
      'confidence': instance.confidence,
      'alternatives': instance.alternatives,
      'emotion': instance.emotion,
    };
