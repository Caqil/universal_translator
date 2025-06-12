// lib/features/conversation/data/models/conversation_session_model.dart
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/conversation_session.dart';
import '../../domain/entities/conversation_message.dart';
import 'conversation_message_model.dart';

part 'conversation_session_model.g.dart';

@HiveType(typeId: 4) // Ensure this doesn't conflict with existing typeIds
@JsonSerializable()
class ConversationSessionModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String user1Language;

  @HiveField(2)
  final String user2Language;

  @HiveField(3)
  final String user1LanguageName;

  @HiveField(4)
  final String user2LanguageName;

  @HiveField(5)
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime startTime;

  @HiveField(6)
  @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
  final DateTime? endTime;

  @HiveField(7)
  final List<ConversationMessageModel> messages;

  @HiveField(8)
  final bool isFavorite;

  @HiveField(9)
  final String? title;

  const ConversationSessionModel({
    required this.id,
    required this.user1Language,
    required this.user2Language,
    required this.user1LanguageName,
    required this.user2LanguageName,
    required this.startTime,
    this.endTime,
    this.messages = const [],
    this.isFavorite = false,
    this.title,
  });

  factory ConversationSessionModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationSessionModelToJson(this);

  ConversationSession toEntity() => ConversationSession(
        id: id,
        user1Language: user1Language,
        user2Language: user2Language,
        user1LanguageName: user1LanguageName,
        user2LanguageName: user2LanguageName,
        startTime: startTime,
        endTime: endTime,
        messages: messages.map((m) => m.toEntity()).toList(),
        isFavorite: isFavorite,
        title: title,
      );

  factory ConversationSessionModel.fromEntity(ConversationSession entity) =>
      ConversationSessionModel(
        id: entity.id,
        user1Language: entity.user1Language,
        user2Language: entity.user2Language,
        user1LanguageName: entity.user1LanguageName,
        user2LanguageName: entity.user2LanguageName,
        startTime: entity.startTime,
        endTime: entity.endTime,
        messages: entity.messages
            .map((m) => ConversationMessageModel.fromEntity(m))
            .toList(),
        isFavorite: entity.isFavorite,
        title: entity.title,
      );

  // Helper methods
  Duration get duration => (endTime ?? DateTime.now()).difference(startTime);
  bool get isActive => endTime == null;
  int get messageCount => messages.length;

  static DateTime _dateTimeFromJson(String json) => DateTime.parse(json);
  static String _dateTimeToJson(DateTime dateTime) =>
      dateTime.toIso8601String();
  static DateTime? _dateTimeFromJsonNullable(String? json) =>
      json != null ? DateTime.parse(json) : null;
  static String? _dateTimeToJsonNullable(DateTime? dateTime) =>
      dateTime?.toIso8601String();

  @override
  List<Object?> get props => [
        id,
        user1Language,
        user2Language,
        user1LanguageName,
        user2LanguageName,
        startTime,
        endTime,
        messages,
        isFavorite,
        title
      ];
}
