// lib/features/conversation/data/models/conversation_message_model.dart
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/conversation_message.dart';

part 'conversation_message_model.g.dart';

@HiveType(typeId: 3) // Ensure this doesn't conflict with existing typeIds
@JsonSerializable()
class ConversationMessageModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String originalText;

  @HiveField(2)
  final String translatedText;

  @HiveField(3)
  final String sourceLanguage;

  @HiveField(4)
  final String targetLanguage;

  @HiveField(5)
  final bool isUser1;

  @HiveField(6)
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime timestamp;

  @HiveField(7)
  final double confidence;

  @HiveField(8)
  final List<String> alternatives;

  @HiveField(9)
  final String? emotion;

  const ConversationMessageModel({
    required this.id,
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.isUser1,
    required this.timestamp,
    this.confidence = 1.0,
    this.alternatives = const [],
    this.emotion,
  });

  factory ConversationMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationMessageModelToJson(this);

  ConversationMessage toEntity() => ConversationMessage(
        id: id,
        originalText: originalText,
        translatedText: translatedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        isUser1: isUser1,
        timestamp: timestamp,
        confidence: confidence,
        alternatives: alternatives,
        emotion: emotion,
      );

  factory ConversationMessageModel.fromEntity(ConversationMessage entity) =>
      ConversationMessageModel(
        id: entity.id,
        originalText: entity.originalText,
        translatedText: entity.translatedText,
        sourceLanguage: entity.sourceLanguage,
        targetLanguage: entity.targetLanguage,
        isUser1: entity.isUser1,
        timestamp: entity.timestamp,
        confidence: entity.confidence,
        alternatives: entity.alternatives,
        emotion: entity.emotion,
      );

  static DateTime _dateTimeFromJson(String json) => DateTime.parse(json);
  static String _dateTimeToJson(DateTime dateTime) =>
      dateTime.toIso8601String();

  @override
  List<Object?> get props => [
        id,
        originalText,
        translatedText,
        sourceLanguage,
        targetLanguage,
        isUser1,
        timestamp,
        confidence,
        alternatives,
        emotion
      ];
}
