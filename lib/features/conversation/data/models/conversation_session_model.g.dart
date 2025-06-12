// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationSessionModelAdapter
    extends TypeAdapter<ConversationSessionModel> {
  @override
  final int typeId = 4;

  @override
  ConversationSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversationSessionModel(
      id: fields[0] as String,
      user1Language: fields[1] as String,
      user2Language: fields[2] as String,
      user1LanguageName: fields[3] as String,
      user2LanguageName: fields[4] as String,
      startTime: fields[5] as DateTime,
      endTime: fields[6] as DateTime?,
      messages: (fields[7] as List).cast<ConversationMessageModel>(),
      isFavorite: fields[8] as bool,
      title: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ConversationSessionModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.user1Language)
      ..writeByte(2)
      ..write(obj.user2Language)
      ..writeByte(3)
      ..write(obj.user1LanguageName)
      ..writeByte(4)
      ..write(obj.user2LanguageName)
      ..writeByte(5)
      ..write(obj.startTime)
      ..writeByte(6)
      ..write(obj.endTime)
      ..writeByte(7)
      ..write(obj.messages)
      ..writeByte(8)
      ..write(obj.isFavorite)
      ..writeByte(9)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationSessionModel _$ConversationSessionModelFromJson(
        Map<String, dynamic> json) =>
    ConversationSessionModel(
      id: json['id'] as String,
      user1Language: json['user1Language'] as String,
      user2Language: json['user2Language'] as String,
      user1LanguageName: json['user1LanguageName'] as String,
      user2LanguageName: json['user2LanguageName'] as String,
      startTime: ConversationSessionModel._dateTimeFromJson(
          json['startTime'] as String),
      endTime: ConversationSessionModel._dateTimeFromJsonNullable(
          json['endTime'] as String?),
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) =>
                  ConversationMessageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isFavorite: json['isFavorite'] as bool? ?? false,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$ConversationSessionModelToJson(
        ConversationSessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user1Language': instance.user1Language,
      'user2Language': instance.user2Language,
      'user1LanguageName': instance.user1LanguageName,
      'user2LanguageName': instance.user2LanguageName,
      'startTime': ConversationSessionModel._dateTimeToJson(instance.startTime),
      'endTime':
          ConversationSessionModel._dateTimeToJsonNullable(instance.endTime),
      'messages': instance.messages,
      'isFavorite': instance.isFavorite,
      'title': instance.title,
    };
