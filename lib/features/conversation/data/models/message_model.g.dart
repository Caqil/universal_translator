// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  final int typeId = 9;

  @override
  MessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageModel(
      id: fields[0] as String,
      conversationId: fields[1] as String,
      type: fields[2] as MessageTypeAdapter,
      sender: fields[3] as MessageSenderAdapter,
      originalText: fields[4] as String,
      translatedText: fields[5] as String?,
      originalLanguage: fields[6] as String,
      translatedLanguage: fields[7] as String?,
      timestamp: fields[8] as DateTime,
      isRead: fields[9] as bool,
      isTranslating: fields[10] as bool,
      confidence: fields[11] as double?,
      voiceFilePath: fields[12] as String?,
      voiceDuration: fields[13] as int?,
      hasTranslationError: fields[14] as bool,
      translationError: fields[15] as String?,
      isFavorite: fields[16] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.conversationId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.sender)
      ..writeByte(4)
      ..write(obj.originalText)
      ..writeByte(5)
      ..write(obj.translatedText)
      ..writeByte(6)
      ..write(obj.originalLanguage)
      ..writeByte(7)
      ..write(obj.translatedLanguage)
      ..writeByte(8)
      ..write(obj.timestamp)
      ..writeByte(9)
      ..write(obj.isRead)
      ..writeByte(10)
      ..write(obj.isTranslating)
      ..writeByte(11)
      ..write(obj.confidence)
      ..writeByte(12)
      ..write(obj.voiceFilePath)
      ..writeByte(13)
      ..write(obj.voiceDuration)
      ..writeByte(14)
      ..write(obj.hasTranslationError)
      ..writeByte(15)
      ..write(obj.translationError)
      ..writeByte(16)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageTypeAdapterAdapter extends TypeAdapter<MessageTypeAdapter> {
  @override
  final int typeId = 7;

  @override
  MessageTypeAdapter read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageTypeAdapter.text;
      case 1:
        return MessageTypeAdapter.translation;
      case 2:
        return MessageTypeAdapter.voice;
      case 3:
        return MessageTypeAdapter.system;
      default:
        return MessageTypeAdapter.text;
    }
  }

  @override
  void write(BinaryWriter writer, MessageTypeAdapter obj) {
    switch (obj) {
      case MessageTypeAdapter.text:
        writer.writeByte(0);
        break;
      case MessageTypeAdapter.translation:
        writer.writeByte(1);
        break;
      case MessageTypeAdapter.voice:
        writer.writeByte(2);
        break;
      case MessageTypeAdapter.system:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageTypeAdapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageSenderAdapterAdapter extends TypeAdapter<MessageSenderAdapter> {
  @override
  final int typeId = 8;

  @override
  MessageSenderAdapter read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageSenderAdapter.user;
      case 1:
        return MessageSenderAdapter.participant;
      case 2:
        return MessageSenderAdapter.system;
      default:
        return MessageSenderAdapter.user;
    }
  }

  @override
  void write(BinaryWriter writer, MessageSenderAdapter obj) {
    switch (obj) {
      case MessageSenderAdapter.user:
        writer.writeByte(0);
        break;
      case MessageSenderAdapter.participant:
        writer.writeByte(1);
        break;
      case MessageSenderAdapter.system:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageSenderAdapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      type: $enumDecode(_$MessageTypeAdapterEnumMap, json['type']),
      sender: $enumDecode(_$MessageSenderAdapterEnumMap, json['sender']),
      originalText: json['originalText'] as String,
      translatedText: json['translatedText'] as String?,
      originalLanguage: json['originalLanguage'] as String,
      translatedLanguage: json['translatedLanguage'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      isTranslating: json['isTranslating'] as bool? ?? false,
      confidence: (json['confidence'] as num?)?.toDouble(),
      voiceFilePath: json['voiceFilePath'] as String?,
      voiceDuration: (json['voiceDuration'] as num?)?.toInt(),
      hasTranslationError: json['hasTranslationError'] as bool? ?? false,
      translationError: json['translationError'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'type': _$MessageTypeAdapterEnumMap[instance.type]!,
      'sender': _$MessageSenderAdapterEnumMap[instance.sender]!,
      'originalText': instance.originalText,
      'translatedText': instance.translatedText,
      'originalLanguage': instance.originalLanguage,
      'translatedLanguage': instance.translatedLanguage,
      'timestamp': instance.timestamp.toIso8601String(),
      'isRead': instance.isRead,
      'isTranslating': instance.isTranslating,
      'confidence': instance.confidence,
      'voiceFilePath': instance.voiceFilePath,
      'voiceDuration': instance.voiceDuration,
      'hasTranslationError': instance.hasTranslationError,
      'translationError': instance.translationError,
      'isFavorite': instance.isFavorite,
    };

const _$MessageTypeAdapterEnumMap = {
  MessageTypeAdapter.text: 'text',
  MessageTypeAdapter.translation: 'translation',
  MessageTypeAdapter.voice: 'voice',
  MessageTypeAdapter.system: 'system',
};

const _$MessageSenderAdapterEnumMap = {
  MessageSenderAdapter.user: 'user',
  MessageSenderAdapter.participant: 'participant',
  MessageSenderAdapter.system: 'system',
};
