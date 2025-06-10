// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LanguageModel _$LanguageModelFromJson(Map<String, dynamic> json) =>
    LanguageModel(
      code: json['code'] as String,
      name: json['name'] as String,
      nativeName: json['nativeName'] as String,
      flag: json['flag'] as String,
      isRtl: json['isRtl'] as bool? ?? false,
      family: json['family'] as String? ?? 'Other',
      supportsSTT: json['supportsSTT'] as bool? ?? false,
      supportsTTS: json['supportsTTS'] as bool? ?? false,
      supportsOCR: json['supportsOCR'] as bool? ?? false,
    );

Map<String, dynamic> _$LanguageModelToJson(LanguageModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'nativeName': instance.nativeName,
      'flag': instance.flag,
      'isRtl': instance.isRtl,
      'family': instance.family,
      'supportsSTT': instance.supportsSTT,
      'supportsTTS': instance.supportsTTS,
      'supportsOCR': instance.supportsOCR,
    };
