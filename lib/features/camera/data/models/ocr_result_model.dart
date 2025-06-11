// lib/features/camera/data/models/ocr_result_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/ocr_result.dart';

part 'ocr_result_model.g.dart';

/// Data model for OCR results that can be serialized/deserialized
@JsonSerializable()
class OcrResultModel extends OcrResult {
  const OcrResultModel({
    required super.text,
    required super.confidence,
    super.language,
    required List<TextBlockModel> textBlocks,
    required super.timestamp,
  }) : super(textBlocks: textBlocks);

  /// Create model from domain entity
  factory OcrResultModel.fromEntity(OcrResult entity) {
    return OcrResultModel(
      text: entity.text,
      confidence: entity.confidence,
      language: entity.language,
      textBlocks: entity.textBlocks
          .map((block) => TextBlockModel.fromEntity(block))
          .toList(),
      timestamp: entity.timestamp,
    );
  }

  /// Create model from JSON
  factory OcrResultModel.fromJson(Map<String, dynamic> json) =>
      _$OcrResultModelFromJson(json);

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$OcrResultModelToJson(this);

  /// Convert model to domain entity
  OcrResult toEntity() {
    return OcrResult(
      text: text,
      confidence: confidence,
      language: language,
      textBlocks: textBlocks
          .map((block) => (block as TextBlockModel).toEntity())
          .toList(),
      timestamp: timestamp,
    );
  }

  /// Create empty model
  factory OcrResultModel.empty() {
    return OcrResultModel(
      text: '',
      confidence: 0.0,
      textBlocks: const [],
      timestamp: DateTime.now(),
    );
  }

  @override
  List<TextBlockModel> get textBlocks =>
      super.textBlocks.cast<TextBlockModel>();
}

/// Data model for text blocks
@JsonSerializable()
class TextBlockModel extends TextBlock {
  const TextBlockModel({
    required super.text,
    required RectModel boundingBox,
    required super.confidence,
    required List<TextLineModel> lines,
  }) : super(boundingBox: boundingBox, lines: lines);

  /// Create model from domain entity
  factory TextBlockModel.fromEntity(TextBlock entity) {
    return TextBlockModel(
      text: entity.text,
      boundingBox: RectModel.fromEntity(entity.boundingBox),
      confidence: entity.confidence,
      lines:
          entity.lines.map((line) => TextLineModel.fromEntity(line)).toList(),
    );
  }

  /// Create model from JSON
  factory TextBlockModel.fromJson(Map<String, dynamic> json) =>
      _$TextBlockModelFromJson(json);

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$TextBlockModelToJson(this);

  /// Convert model to domain entity
  TextBlock toEntity() {
    return TextBlock(
      text: text,
      boundingBox: (boundingBox as RectModel).toEntity(),
      confidence: confidence,
      lines: lines.map((line) => (line as TextLineModel).toEntity()).toList(),
    );
  }

  @override
  RectModel get boundingBox => super.boundingBox as RectModel;

  @override
  List<TextLineModel> get lines => super.lines.cast<TextLineModel>();
}

/// Data model for text lines
@JsonSerializable()
class TextLineModel extends TextLine {
  const TextLineModel({
    required super.text,
    required RectModel boundingBox,
    required super.confidence,
    required List<TextElementModel> elements,
  }) : super(boundingBox: boundingBox, elements: elements);

  /// Create model from domain entity
  factory TextLineModel.fromEntity(TextLine entity) {
    return TextLineModel(
      text: entity.text,
      boundingBox: RectModel.fromEntity(entity.boundingBox),
      confidence: entity.confidence,
      elements: entity.elements
          .map((element) => TextElementModel.fromEntity(element))
          .toList(),
    );
  }

  /// Create model from JSON
  factory TextLineModel.fromJson(Map<String, dynamic> json) =>
      _$TextLineModelFromJson(json);

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$TextLineModelToJson(this);

  /// Convert model to domain entity
  TextLine toEntity() {
    return TextLine(
      text: text,
      boundingBox: (boundingBox as RectModel).toEntity(),
      confidence: confidence,
      elements: elements
          .map((element) => (element as TextElementModel).toEntity())
          .toList(),
    );
  }

  @override
  RectModel get boundingBox => super.boundingBox as RectModel;

  @override
  List<TextElementModel> get elements =>
      super.elements.cast<TextElementModel>();
}

/// Data model for text elements
@JsonSerializable()
class TextElementModel extends TextElement {
  const TextElementModel({
    required super.text,
    required RectModel boundingBox,
    required super.confidence,
  }) : super(boundingBox: boundingBox);

  /// Create model from domain entity
  factory TextElementModel.fromEntity(TextElement entity) {
    return TextElementModel(
      text: entity.text,
      boundingBox: RectModel.fromEntity(entity.boundingBox),
      confidence: entity.confidence,
    );
  }

  /// Create model from JSON
  factory TextElementModel.fromJson(Map<String, dynamic> json) =>
      _$TextElementModelFromJson(json);

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$TextElementModelToJson(this);

  /// Convert model to domain entity
  TextElement toEntity() {
    return TextElement(
      text: text,
      boundingBox: (boundingBox as RectModel).toEntity(),
      confidence: confidence,
    );
  }

  @override
  RectModel get boundingBox => super.boundingBox as RectModel;
}

/// Data model for rectangles/bounding boxes
@JsonSerializable()
class RectModel extends Rect {
  const RectModel({
    required super.left,
    required super.top,
    required super.width,
    required super.height,
  });

  /// Create model from domain entity
  factory RectModel.fromEntity(Rect entity) {
    return RectModel(
      left: entity.left,
      top: entity.top,
      width: entity.width,
      height: entity.height,
    );
  }

  /// Create model from JSON
  factory RectModel.fromJson(Map<String, dynamic> json) =>
      _$RectModelFromJson(json);

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$RectModelToJson(this);

  /// Convert model to domain entity
  Rect toEntity() {
    return Rect(
      left: left,
      top: top,
      width: width,
      height: height,
    );
  }
}
