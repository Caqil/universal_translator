import 'package:equatable/equatable.dart';

/// Domain entity representing a language
class Language extends Equatable {
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

  const Language({
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
  String toString() => 'Language(code: $code, name: $name)';
}
