import 'package:hive/hive.dart';
import '../../domain/entities/history_item.dart';

part 'history_item_model.g.dart';

@HiveType(typeId: 3) // Make sure this typeId is unique in your app
class HistoryItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String sourceText;

  @HiveField(2)
  final String translatedText;

  @HiveField(3)
  final String sourceLanguage;

  @HiveField(4)
  final String targetLanguage;

  @HiveField(5)
  final DateTime timestamp;

  @HiveField(6)
  final bool isFavorite;

  @HiveField(7)
  final double? confidence;

  @HiveField(8)
  final List<String>? alternatives;

  HistoryItemModel({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
    this.isFavorite = false,
    this.confidence,
    this.alternatives,
  });

  /// Convert from domain entity
  factory HistoryItemModel.fromEntity(HistoryItem entity) {
    return HistoryItemModel(
      id: entity.id,
      sourceText: entity.sourceText,
      translatedText: entity.translatedText,
      sourceLanguage: entity.sourceLanguage,
      targetLanguage: entity.targetLanguage,
      timestamp: entity.timestamp,
      isFavorite: entity.isFavorite,
      confidence: entity.confidence,
      alternatives: entity.alternatives,
    );
  }

  /// Convert to domain entity
  HistoryItem toEntity() {
    return HistoryItem(
      id: id,
      sourceText: sourceText,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      timestamp: timestamp,
      isFavorite: isFavorite,
      confidence: confidence,
      alternatives: alternatives,
    );
  }

  /// Create from JSON
  factory HistoryItemModel.fromJson(Map<String, dynamic> json) {
    return HistoryItemModel(
      id: json['id'] as String,
      sourceText: json['sourceText'] as String,
      translatedText: json['translatedText'] as String,
      sourceLanguage: json['sourceLanguage'] as String,
      targetLanguage: json['targetLanguage'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      isFavorite: json['isFavorite'] as bool? ?? false,
      confidence: json['confidence'] as double?,
      alternatives: json['alternatives'] != null
          ? List<String>.from(json['alternatives'] as List)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceText': sourceText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isFavorite': isFavorite,
      'confidence': confidence,
      'alternatives': alternatives,
    };
  }

  HistoryItemModel copyWith({
    String? id,
    String? sourceText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? timestamp,
    bool? isFavorite,
    double? confidence,
    List<String>? alternatives,
  }) {
    return HistoryItemModel(
      id: id ?? this.id,
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
      confidence: confidence ?? this.confidence,
      alternatives: alternatives ?? this.alternatives,
    );
  }
}
