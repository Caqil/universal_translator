
import 'package:equatable/equatable.dart';

/// Entity representing the result of OCR text recognition
class OcrResult extends Equatable {
  /// The extracted text from the image
  final String text;

  /// Confidence level of the recognition (0.0 to 1.0)
  final double confidence;

  /// Language detected in the text (ISO 639-1 code)
  final String? language;

  /// Bounding boxes for each text element
  final List<TextBlock> textBlocks;

  /// Timestamp when OCR was performed
  final DateTime timestamp;

  const OcrResult({
    required this.text,
    required this.confidence,
    this.language,
    required this.textBlocks,
    required this.timestamp,
  });

  /// Create an empty OCR result
  factory OcrResult.empty() {
    return OcrResult(
      text: '',
      confidence: 0.0,
      textBlocks: const [],
      timestamp: DateTime.now(),
    );
  }

  /// Check if the result contains valid text
  bool get hasText => text.trim().isNotEmpty;

  /// Check if the confidence is above a threshold
  bool get isReliable => confidence >= 0.7;

  @override
  List<Object?> get props => [
        text,
        confidence,
        language,
        textBlocks,
        timestamp,
      ];

  @override
  String toString() => 'OcrResult(text: $text, confidence: $confidence)';
}

/// Represents a block of text with its position
class TextBlock extends Equatable {
  /// The text content of this block
  final String text;

  /// Bounding rectangle (x, y, width, height)
  final Rect boundingBox;

  /// Confidence level for this specific text block
  final double confidence;

  /// List of individual lines in this block
  final List<TextLine> lines;

  const TextBlock({
    required this.text,
    required this.boundingBox,
    required this.confidence,
    required this.lines,
  });

  @override
  List<Object> get props => [text, boundingBox, confidence, lines];
}

/// Represents a line of text within a text block
class TextLine extends Equatable {
  /// The text content of this line
  final String text;

  /// Bounding rectangle for this line
  final Rect boundingBox;

  /// Confidence level for this line
  final double confidence;

  /// List of individual words/elements in this line
  final List<TextElement> elements;

  const TextLine({
    required this.text,
    required this.boundingBox,
    required this.confidence,
    required this.elements,
  });

  @override
  List<Object> get props => [text, boundingBox, confidence, elements];
}

/// Represents an individual text element (word or character)
class TextElement extends Equatable {
  /// The text content of this element
  final String text;

  /// Bounding rectangle for this element
  final Rect boundingBox;

  /// Confidence level for this element
  final double confidence;

  const TextElement({
    required this.text,
    required this.boundingBox,
    required this.confidence,
  });

  @override
  List<Object> get props => [text, boundingBox, confidence];
}

/// Simple rectangle class for bounding boxes
class Rect extends Equatable {
  final double left;
  final double top;
  final double width;
  final double height;

  const Rect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  double get right => left + width;
  double get bottom => top + height;

  @override
  List<Object> get props => [left, top, width, height];
}
