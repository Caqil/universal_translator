// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speech_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpeechResultModel _$SpeechResultModelFromJson(Map<String, dynamic> json) =>
    SpeechResultModel(
      recognizedWords: json['recognizedWords'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      isFinal: json['isFinal'] as bool,
      languageCode: json['languageCode'] as String,
      timestamp:
          SpeechResultModel._dateTimeFromJson(json['timestamp'] as String),
      alternatives: (json['alternatives'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: (json['duration'] as num).toInt()),
      hasHighConfidence: json['hasHighConfidence'] as bool? ?? false,
    );

Map<String, dynamic> _$SpeechResultModelToJson(SpeechResultModel instance) =>
    <String, dynamic>{
      'recognizedWords': instance.recognizedWords,
      'confidence': instance.confidence,
      'isFinal': instance.isFinal,
      'languageCode': instance.languageCode,
      'timestamp': SpeechResultModel._dateTimeToJson(instance.timestamp),
      'alternatives': instance.alternatives,
      'duration': instance.duration?.inMicroseconds,
      'hasHighConfidence': instance.hasHighConfidence,
    };
