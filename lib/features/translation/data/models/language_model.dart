import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/language.dart';

part 'language_model.g.dart';

/// Data model for language
@JsonSerializable()
class LanguageModel extends Equatable {
  /// Language code (ISO 639-1)
  final String code;

  /// English name of the language
  final String name;

  /// Native name of the language
  final String nativeName;

  /// Flag emoji for the language
  final String flag;

  /// Whether the language is written right-to-left
  final bool isRtl;

  /// Language family
  final String family;

  /// Whether speech-to-text is supported
  final bool supportsSTT;

  /// Whether text-to-speech is supported
  final bool supportsTTS;

  /// Whether OCR is supported
  final bool supportsOCR;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    this.isRtl = false,
    this.family = 'Other',
    this.supportsSTT = false,
    this.supportsTTS = false,
    this.supportsOCR = false,
  });

  /// Create from JSON
  factory LanguageModel.fromJson(Map<String, dynamic> json) =>
      _$LanguageModelFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$LanguageModelToJson(this);

  /// Convert to domain entity
  Language toEntity() {
    return Language(
      code: code,
      name: name,
      nativeName: nativeName,
      flag: flag,
      isRtl: isRtl,
      family: family,
      supportsSTT: supportsSTT,
      supportsTTS: supportsTTS,
      supportsOCR: supportsOCR,
    );
  }

  /// Create from domain entity
  factory LanguageModel.fromEntity(Language entity) {
    return LanguageModel(
      code: entity.code,
      name: entity.name,
      nativeName: entity.nativeName,
      flag: entity.flag,
      isRtl: entity.isRtl,
      family: entity.family,
      supportsSTT: entity.supportsSTT,
      supportsTTS: entity.supportsTTS,
      supportsOCR: entity.supportsOCR,
    );
  }

  /// Copy with new values
  LanguageModel copyWith({
    String? code,
    String? name,
    String? nativeName,
    String? flag,
    bool? isRtl,
    String? family,
    bool? supportsSTT,
    bool? supportsTTS,
    bool? supportsOCR,
  }) {
    return LanguageModel(
      code: code ?? this.code,
      name: name ?? this.name,
      nativeName: nativeName ?? this.nativeName,
      flag: flag ?? this.flag,
      isRtl: isRtl ?? this.isRtl,
      family: family ?? this.family,
      supportsSTT: supportsSTT ?? this.supportsSTT,
      supportsTTS: supportsTTS ?? this.supportsTTS,
      supportsOCR: supportsOCR ?? this.supportsOCR,
    );
  }

  @override
  List<Object?> get props => [
        code,
        name,
        nativeName,
        flag,
        isRtl,
        family,
        supportsSTT,
        supportsTTS,
        supportsOCR,
      ];

  @override
  String toString() => 'LanguageModel(code: $code, name: $name)';
}
