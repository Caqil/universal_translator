// lib/features/conversation/domain/entities/conversation_session.dart
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'conversation_message.dart';

class ConversationSession extends Equatable {
  final String id;
  final String user1Language;
  final String user2Language;
  final String user1LanguageName;
  final String user2LanguageName;
  final DateTime startTime;
  final DateTime? endTime;
  final List<ConversationMessage> messages;
  final bool isFavorite;
  final String? title; // auto-generated or user-defined

  const ConversationSession({
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

  // Helper methods
  Duration get duration => (endTime ?? DateTime.now()).difference(startTime);
  bool get isActive => endTime == null;
  int get messageCount => messages.length;

  String get generatedTitle {
    if (title != null && title!.isNotEmpty) return title!;
    final formatter = DateFormat('MMM dd, yyyy • HH:mm');
    return '$user1LanguageName ↔ $user2LanguageName • ${formatter.format(startTime)}';
  }

  ConversationSession copyWith({
    String? id,
    String? user1Language,
    String? user2Language,
    String? user1LanguageName,
    String? user2LanguageName,
    DateTime? startTime,
    DateTime? endTime,
    List<ConversationMessage>? messages,
    bool? isFavorite,
    String? title,
  }) {
    return ConversationSession(
      id: id ?? this.id,
      user1Language: user1Language ?? this.user1Language,
      user2Language: user2Language ?? this.user2Language,
      user1LanguageName: user1LanguageName ?? this.user1LanguageName,
      user2LanguageName: user2LanguageName ?? this.user2LanguageName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      messages: messages ?? this.messages,
      isFavorite: isFavorite ?? this.isFavorite,
      title: title ?? this.title,
    );
  }

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
