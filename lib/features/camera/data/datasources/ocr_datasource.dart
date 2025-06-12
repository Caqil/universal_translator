import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/services/injection_container.dart';

abstract class OcrDataSource {
  Future<List<String>> recognizeTextFromImage(String imagePath);
  Future<void> dispose();
}

@LazySingleton(as: OcrDataSource)
class OcrDataSourceImpl implements OcrDataSource {
  // Use sl() to get dependency instead of constructor injection
  TextRecognizer get _textRecognizer => sl<TextRecognizer>();

  @override
  Future<List<String>> recognizeTextFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isEmpty) {
        throw OcrException.noTextFound();
      }

      // Extract text blocks
      final List<String> textBlocks = [];
      for (final block in recognizedText.blocks) {
        if (block.text.trim().isNotEmpty) {
          textBlocks.add(block.text.trim());
        }
      }

      return textBlocks;
    } catch (e) {
      if (e is OcrException) {
        rethrow;
      }
      throw OcrException.processingFailed(e.toString());
    }
  }

  @override
  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}
