// lib/features/camera/data/datasources/ocr_datasource_impl.dart
import 'dart:io';
import 'dart:ui' show Rect;
import 'package:google_ml_kit/google_ml_kit.dart';
import '../../../../core/error/exceptions.dart';
import '../models/ocr_result_model.dart';

/// Real implementation of OCR data source using Google ML Kit
class OcrDataSourceImpl implements OcrDataSource {
  late final TextRecognizer _textRecognizer;

  OcrDataSourceImpl() {
    _textRecognizer = GoogleMlKit.vision.textRecognizer();
  }

  @override
  Future<OcrResultModel> extractTextFromImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw OcrException.processingFailed(
            'Image file does not exist: $imagePath');
      }

      return await extractTextFromFile(file);
    } catch (e) {
      if (e is OcrException) rethrow;
      throw OcrException.processingFailed(
          'Failed to extract text from image: $e');
    }
  }

  @override
  Future<OcrResultModel> extractTextFromFile(File imageFile) async {
    try {
      // Validate file
      if (!await imageFile.exists()) {
        throw OcrException.processingFailed('Image file does not exist');
      }

      final fileSize = await imageFile.length();
      if (fileSize == 0) {
        throw OcrException.processingFailed('Image file is empty');
      }

      if (fileSize > 10 * 1024 * 1024) {
        // 10MB limit
        throw OcrException.processingFailed('Image file is too large (>10MB)');
      }

      // Create input image
      final inputImage = InputImage.fromFile(imageFile);

      // Process image for text recognition
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Convert to our model
      final result = _convertToOcrResultModel(recognizedText);

      return result;
    } catch (e) {
      if (e is OcrException) rethrow;
      throw OcrException.processingFailed('OCR processing failed: $e');
    }
  }

  @override
  Future<bool> isOcrAvailable() async {
    try {
      // Test if text recognizer can be created
      final testRecognizer = GoogleMlKit.vision.textRecognizer();
      await testRecognizer.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> getSupportedLanguages() async {
    // Google ML Kit supports automatic language detection
    // Return commonly supported language codes
    return [
      'en', // English
      'es', // Spanish
      'fr', // French
      'de', // German
      'it', // Italian
      'pt', // Portuguese
      'ru', // Russian
      'ja', // Japanese
      'ko', // Korean
      'zh', // Chinese (Simplified)
      'zh-TW', // Chinese (Traditional)
      'ar', // Arabic
      'hi', // Hindi
      'th', // Thai
      'vi', // Vietnamese
      'nl', // Dutch
      'pl', // Polish
      'tr', // Turkish
      'sv', // Swedish
      'da', // Danish
      'no', // Norwegian
      'fi', // Finnish
      'cs', // Czech
      'hu', // Hungarian
      'el', // Greek
      'he', // Hebrew
      'id', // Indonesian
      'ms', // Malay
      'uk', // Ukrainian
      'bg', // Bulgarian
      'hr', // Croatian
      'et', // Estonian
      'lv', // Latvian
      'lt', // Lithuanian
      'ro', // Romanian
      'sk', // Slovak
      'sl', // Slovenian
    ];
  }

  @override
  Future<OcrResultModel> extractTextWithLanguageHint(
    String imagePath,
    String languageCode,
  ) async {
    // Google ML Kit automatically detects language, so we use the same method
    // In future versions, you could use specific language models if available
    return await extractTextFromImage(imagePath);
  }

  /// Convert Google ML Kit RecognizedText to our OcrResultModel
  OcrResultModel _convertToOcrResultModel(RecognizedText recognizedText) {
    try {
      final textBlocks = <TextBlockModel>[];
      double totalConfidence = 0.0;
      int blockCount = 0;

      for (final textBlock in recognizedText.blocks) {
        final lines = <TextLineModel>[];

        for (final textLine in textBlock.lines) {
          final elements = <TextElementModel>[];

          for (final textElement in textLine.elements) {
            elements.add(TextElementModel(
              text: textElement.text,
              boundingBox: _convertRect(textElement.boundingBox),
              confidence: _calculateElementConfidence(textElement),
            ));
          }

          lines.add(TextLineModel(
            text: textLine.text,
            boundingBox: _convertRect(textLine.boundingBox),
            confidence: _calculateLineConfidence(textLine),
            elements: elements,
          ));
        }

        final blockConfidence = _calculateBlockConfidence(textBlock);

        textBlocks.add(TextBlockModel(
          text: textBlock.text,
          boundingBox: _convertRect(textBlock.boundingBox),
          confidence: blockConfidence,
          lines: lines,
        ));

        totalConfidence += blockConfidence;
        blockCount++;
      }

      final averageConfidence =
          blockCount > 0 ? totalConfidence / blockCount : 0.0;

      return OcrResultModel(
        text: recognizedText.text,
        confidence: averageConfidence,
        language:
            _detectLanguage(recognizedText.text), // Simple language detection
        textBlocks: textBlocks,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw OcrException.processingFailed(
          'Failed to convert ML Kit result: $e');
    }
  }

  /// Convert ML Kit Rect to our RectModel
  RectModel _convertRect(Rect? mlkitRect) {
    if (mlkitRect == null) {
      return const RectModel(left: 0, top: 0, width: 0, height: 0);
    }

    return RectModel(
      left: mlkitRect.left,
      top: mlkitRect.top,
      width: mlkitRect.width,
      height: mlkitRect.height,
    );
  }

  /// Calculate confidence for text element
  /// Note: Google ML Kit doesn't provide direct confidence scores
  /// These are heuristic-based estimations
  double _calculateElementConfidence(TextElement element) {
    final text = element.text;
    if (text.isEmpty) return 0.0;

    double confidence = 0.75; // Base confidence

    // Longer elements tend to be more reliable
    if (text.length >= 3) confidence += 0.1;
    if (text.length >= 6) confidence += 0.05;

    // Adjust based on character types
    if (RegExp(r'^[A-Za-z\s]+$').hasMatch(text)) {
      confidence += 0.1; // Pure alphabetic text
    } else if (RegExp(r'^\d+$').hasMatch(text)) {
      confidence += 0.15; // Pure numeric text
    } else if (RegExp(r'^[A-Za-z0-9\s.,!?-]+$').hasMatch(text)) {
      confidence += 0.05; // Mixed alphanumeric with basic punctuation
    }

    // Penalize very short text
    if (text.length == 1) confidence -= 0.2;

    // Penalize text with many special characters
    final specialCharCount =
        text.replaceAll(RegExp(r'[A-Za-z0-9\s]'), '').length;
    if (specialCharCount > text.length * 0.3) {
      confidence -= 0.2;
    }

    return confidence.clamp(0.0, 1.0);
  }

  /// Calculate confidence for text line
  double _calculateLineConfidence(TextLine line) {
    final text = line.text;
    if (text.isEmpty) return 0.0;

    double confidence = 0.8; // Base confidence for lines

    // Longer lines tend to be more reliable
    if (text.length > 10) confidence += 0.1;
    if (text.length > 20) confidence += 0.05;

    // Multiple words are more reliable
    final wordCount =
        text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    if (wordCount > 1) confidence += 0.05;
    if (wordCount > 3) confidence += 0.05;

    // Check for sentence structure
    if (RegExp(r'^[A-Z].*[.!?]$').hasMatch(text.trim())) {
      confidence += 0.1; // Proper sentence structure
    }

    return confidence.clamp(0.0, 1.0);
  }

  /// Calculate confidence for text block
  double _calculateBlockConfidence(TextBlock block) {
    final text = block.text;
    if (text.isEmpty) return 0.0;

    double confidence = 0.85; // Base confidence for blocks

    // Larger blocks tend to be more reliable
    if (text.length > 50) confidence += 0.05;
    if (text.length > 100) confidence += 0.05;

    // Multiple lines are generally more reliable
    final lineCount = block.lines.length;
    if (lineCount > 1) confidence += 0.05;
    if (lineCount > 3) confidence += 0.05;

    // Check text quality
    final alphanumericRatio =
        text.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').length / text.length;
    if (alphanumericRatio > 0.8) {
      confidence += 0.05; // High alphanumeric content
    }

    return confidence.clamp(0.0, 1.0);
  }

  /// Simple language detection based on text characteristics
  String? _detectLanguage(String text) {
    if (text.trim().isEmpty) return null;

    // This is a very basic implementation
    // In a real app, you might use a proper language detection library

    // Check for common English words
    final englishWords = [
      'the',
      'and',
      'or',
      'but',
      'in',
      'on',
      'at',
      'to',
      'for',
      'of',
      'with',
      'by'
    ];
    final lowerText = text.toLowerCase();
    final englishWordCount =
        englishWords.where((word) => lowerText.contains(' $word ')).length;

    if (englishWordCount > 0) return 'en';

    // Check for character sets
    if (RegExp(r'[\u4e00-\u9fff]').hasMatch(text)) return 'zh'; // Chinese
    if (RegExp(r'[\u3040-\u309f\u30a0-\u30ff]').hasMatch(text))
      return 'ja'; // Japanese
    if (RegExp(r'[\uac00-\ud7af]').hasMatch(text)) return 'ko'; // Korean
    if (RegExp(r'[\u0600-\u06ff]').hasMatch(text)) return 'ar'; // Arabic
    if (RegExp(r'[\u0400-\u04ff]').hasMatch(text))
      return 'ru'; // Cyrillic (Russian)

    // Default to null (auto-detect)
    return null;
  }

  /// Clean up resources
  Future<void> dispose() async {
    try {
      await _textRecognizer.close();
    } catch (e) {
      print('Warning: Error disposing text recognizer: $e');
    }
  }
}

/// Abstract interface that the implementation follows
abstract class OcrDataSource {
  Future<OcrResultModel> extractTextFromImage(String imagePath);
  Future<OcrResultModel> extractTextFromFile(File imageFile);
  Future<bool> isOcrAvailable();
  Future<List<String>> getSupportedLanguages();
  Future<OcrResultModel> extractTextWithLanguageHint(
      String imagePath, String languageCode);
}
