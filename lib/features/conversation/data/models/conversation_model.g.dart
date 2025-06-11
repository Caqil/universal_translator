// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationModelAdapter extends TypeAdapter<ConversationModel> {
  @override
  final int typeId = 6;

  @override
  ConversationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversationModel(
      id: fields[0] as String,
      title: fields[1] as String,
      messages: (fields[2] as List).cast<MessageModel>(),
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      sourceLanguage: fields[5] as String,
      targetLanguage: fields[6] as String,
      isArchived: fields[7] as bool,
      isPinned: fields[8] as bool,
      participantName: fields[9] as String?,
      category: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ConversationModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.messages)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.sourceLanguage)
      ..writeByte(6)
      ..write(obj.targetLanguage)
      ..writeByte(7)
      ..write(obj.isArchived)
      ..writeByte(8)
      ..write(obj.isPinned)
      ..writeByte(9)
      ..write(obj.participantName)
      ..writeByte(10)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationModel _$ConversationModelFromJson(Map<String, dynamic> json) =>
    ConversationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      sourceLanguage: json['sourceLanguage'] as String,
      targetLanguage: json['targetLanguage'] as String,
      isArchived: json['isArchived'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      participantName: json['participantName'] as String?,
      category: json['category'] as String?,
    );

Map<String, dynamic> _$ConversationModelToJson(ConversationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'messages': instance.messages,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'sourceLanguage': instance.sourceLanguage,
      'targetLanguage': instance.targetLanguage,
      'isArchived': instance.isArchived,
      'isPinned': instance.isPinned,
      'participantName': instance.participantName,
      'category': instance.category,
    };
