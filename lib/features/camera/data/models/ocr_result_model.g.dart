// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OcrResultModel _$OcrResultModelFromJson(Map<String, dynamic> json) =>
    OcrResultModel(
      text: json['text'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      language: json['language'] as String?,
      textBlocks: (json['textBlocks'] as List<dynamic>)
          .map((e) => TextBlockModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$OcrResultModelToJson(OcrResultModel instance) =>
    <String, dynamic>{
      'text': instance.text,
      'confidence': instance.confidence,
      'language': instance.language,
      'timestamp': instance.timestamp.toIso8601String(),
      'textBlocks': instance.textBlocks,
    };

TextBlockModel _$TextBlockModelFromJson(Map<String, dynamic> json) =>
    TextBlockModel(
      text: json['text'] as String,
      boundingBox:
          RectModel.fromJson(json['boundingBox'] as Map<String, dynamic>),
      confidence: (json['confidence'] as num).toDouble(),
      lines: (json['lines'] as List<dynamic>)
          .map((e) => TextLineModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TextBlockModelToJson(TextBlockModel instance) =>
    <String, dynamic>{
      'text': instance.text,
      'confidence': instance.confidence,
      'boundingBox': instance.boundingBox,
      'lines': instance.lines,
    };

TextLineModel _$TextLineModelFromJson(Map<String, dynamic> json) =>
    TextLineModel(
      text: json['text'] as String,
      boundingBox:
          RectModel.fromJson(json['boundingBox'] as Map<String, dynamic>),
      confidence: (json['confidence'] as num).toDouble(),
      elements: (json['elements'] as List<dynamic>)
          .map((e) => TextElementModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TextLineModelToJson(TextLineModel instance) =>
    <String, dynamic>{
      'text': instance.text,
      'confidence': instance.confidence,
      'boundingBox': instance.boundingBox,
      'elements': instance.elements,
    };

TextElementModel _$TextElementModelFromJson(Map<String, dynamic> json) =>
    TextElementModel(
      text: json['text'] as String,
      boundingBox:
          RectModel.fromJson(json['boundingBox'] as Map<String, dynamic>),
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$TextElementModelToJson(TextElementModel instance) =>
    <String, dynamic>{
      'text': instance.text,
      'confidence': instance.confidence,
      'boundingBox': instance.boundingBox,
    };

RectModel _$RectModelFromJson(Map<String, dynamic> json) => RectModel(
      left: (json['left'] as num).toDouble(),
      top: (json['top'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );

Map<String, dynamic> _$RectModelToJson(RectModel instance) => <String, dynamic>{
      'left': instance.left,
      'top': instance.top,
      'width': instance.width,
      'height': instance.height,
    };
