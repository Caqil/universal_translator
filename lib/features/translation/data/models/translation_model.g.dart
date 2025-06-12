// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslationModel _$TranslationModelFromJson(Map<String, dynamic> json) =>
    TranslationModel(
      id: json['id'] as String,
      sourceText: json['sourceText'] as String,
      translatedText: json['translatedText'] as String,
      sourceLanguage: json['sourceLanguage'] as String,
      targetLanguage: json['targetLanguage'] as String,
      timestamp:
          TranslationModel._dateTimeFromJson(json['timestamp'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      confidence: (json['confidence'] as num?)?.toDouble(),
      alternatives: (json['alternatives'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      detectedLanguage: json['detectedLanguage'] as String?,
      isOffline: json['isOffline'] as bool? ?? false,
    );

Map<String, dynamic> _$TranslationModelToJson(TranslationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sourceText': instance.sourceText,
      'translatedText': instance.translatedText,
      'sourceLanguage': instance.sourceLanguage,
      'targetLanguage': instance.targetLanguage,
      'isOffline': instance.isOffline,
      'timestamp': TranslationModel._dateTimeToJson(instance.timestamp),
      'isFavorite': instance.isFavorite,
      'confidence': instance.confidence,
      'alternatives': instance.alternatives,
      'detectedLanguage': instance.detectedLanguage,
    };
