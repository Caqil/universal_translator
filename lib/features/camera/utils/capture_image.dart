// lib/features/camera/utils/capture_image.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../core/error/exceptions.dart' as exceptions;

/// Utility class for image capture operations
class CaptureImageUtil {
  /// Capture image using the provided camera controller
  static Future<String> captureImage(CameraController controller) async {
    try {
      // Validate controller state
      if (!controller.value.isInitialized) {
        throw exceptions.CameraException.initializationFailed(
            'Controller not initialized');
      }

      if (controller.value.isTakingPicture) {
        throw exceptions.CameraException.captureFailed(
            'Already taking a picture');
      }

      // Get temporary directory for saving the image
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = _generateImageFileName();
      final String filePath = path.join(tempDir.path, fileName);

      // Capture the image
      final XFile imageFile = await controller.takePicture();

      // Copy to our desired location with proper error handling
      final File sourceFile = File(imageFile.path);
      final File targetFile = File(filePath);

      if (!await sourceFile.exists()) {
        throw exceptions.CameraException.captureFailed(
            'Captured image file not found');
      }

      await sourceFile.copy(filePath);

      // Verify the copied file exists and has content
      if (!await targetFile.exists()) {
        throw exceptions.CameraException.captureFailed(
            'Failed to save captured image');
      }

      final int fileSize = await targetFile.length();
      if (fileSize == 0) {
        throw exceptions.CameraException.captureFailed(
            'Captured image file is empty');
      }

      // Clean up the temporary file from camera
      try {
        await sourceFile.delete();
      } catch (e) {
        // Non-critical error, log but don't throw
        print('Warning: Failed to clean up temporary camera file: $e');
      }

      return filePath;
    } on CameraException {
      rethrow;
    } catch (e) {
      throw exceptions.CameraException.captureFailed('Unexpected error: $e');
    }
  }

  /// Capture image with specific quality settings
  static Future<String> captureImageWithQuality(
    CameraController controller, {
    int quality = 85,
  }) async {
    try {
      // Validate quality parameter
      if (quality < 1 || quality > 100) {
        throw exceptions.CameraException.captureFailed(
            'Quality must be between 1 and 100');
      }

      // Validate controller state
      if (!controller.value.isInitialized) {
        throw exceptions.CameraException.initializationFailed(
            'Controller not initialized');
      }

      // Get temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = _generateImageFileName();
      final String filePath = path.join(tempDir.path, fileName);

      // Capture with quality settings
      final XFile imageFile = await controller.takePicture();

      // Copy to target location
      await File(imageFile.path).copy(filePath);

      // Clean up original file
      try {
        await File(imageFile.path).delete();
      } catch (e) {
        print('Warning: Failed to clean up temporary file: $e');
      }

      return filePath;
    } on CameraException {
      rethrow;
    } catch (e) {
      throw exceptions.CameraException.captureFailed(
          'Failed to capture with quality: $e');
    }
  }

  /// Save captured image to permanent storage
  static Future<String> saveImageToPermanentStorage(String imagePath) async {
    try {
      final File sourceFile = File(imagePath);

      if (!await sourceFile.exists()) {
        throw exceptions.CameraException.captureFailed(
            'Source image file not found');
      }

      // Get documents directory for permanent storage
      final Directory documentsDir = await getApplicationDocumentsDirectory();
      final Directory savedImagesDir = Directory(
        path.join(documentsDir.path, 'camera_images'),
      );

      // Create directory if it doesn't exist
      if (!await savedImagesDir.exists()) {
        await savedImagesDir.create(recursive: true);
      }

      // Generate permanent file name
      final String fileName = _generatePermanentImageFileName();
      final String permanentPath = path.join(savedImagesDir.path, fileName);

      // Copy to permanent location
      await sourceFile.copy(permanentPath);

      // Verify the file was copied successfully
      final File permanentFile = File(permanentPath);
      if (!await permanentFile.exists()) {
        throw exceptions.CameraException.captureFailed(
            'Failed to save to permanent storage');
      }

      return permanentPath;
    } catch (e) {
      throw exceptions.CameraException.captureFailed(
          'Failed to save permanently: $e');
    }
  }

  /// Delete temporary image file
  static Future<void> deleteTemporaryImage(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Non-critical error, just log
      print('Warning: Failed to delete temporary image: $e');
    }
  }

  /// Get image file size in bytes
  static Future<int> getImageFileSize(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Check if image file is valid
  static Future<bool> isValidImageFile(String imagePath) async {
    try {
      final File file = File(imagePath);

      // Check if file exists
      if (!await file.exists()) {
        return false;
      }

      // Check if file has content
      final int size = await file.length();
      if (size == 0) {
        return false;
      }

      // Check file extension
      final String extension = path.extension(imagePath).toLowerCase();
      final List<String> validExtensions = ['.jpg', '.jpeg', '.png'];

      if (!validExtensions.contains(extension)) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Generate unique filename for temporary images
  static String _generateImageFileName() {
    final DateTime now = DateTime.now();
    final String timestamp = now.millisecondsSinceEpoch.toString();
    return 'camera_temp_$timestamp.jpg';
  }

  /// Generate unique filename for permanent images
  static String _generatePermanentImageFileName() {
    final DateTime now = DateTime.now();
    final String timestamp = now.millisecondsSinceEpoch.toString();
    final String dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    return 'camera_${dateStr}_$timestamp.jpg';
  }

  /// Get list of saved images
  static Future<List<String>> getSavedImages() async {
    try {
      final Directory documentsDir = await getApplicationDocumentsDirectory();
      final Directory savedImagesDir = Directory(
        path.join(documentsDir.path, 'camera_images'),
      );

      if (!await savedImagesDir.exists()) {
        return [];
      }

      final List<FileSystemEntity> files = await savedImagesDir.list().toList();
      final List<String> imagePaths = [];

      for (final file in files) {
        if (file is File) {
          final String extension = path.extension(file.path).toLowerCase();
          if (['.jpg', '.jpeg', '.png'].contains(extension)) {
            imagePaths.add(file.path);
          }
        }
      }

      // Sort by modification time (newest first)
      imagePaths.sort((a, b) {
        final fileA = File(a);
        final fileB = File(b);
        return fileB.lastModifiedSync().compareTo(fileA.lastModifiedSync());
      });

      return imagePaths;
    } catch (e) {
      print('Error getting saved images: $e');
      return [];
    }
  }

  /// Clean up old temporary images
  static Future<void> cleanupOldTemporaryImages() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final List<FileSystemEntity> files = await tempDir.list().toList();
      final DateTime cutoffTime =
          DateTime.now().subtract(const Duration(hours: 24));

      for (final file in files) {
        if (file is File && file.path.contains('camera_temp_')) {
          final DateTime lastModified = await file.lastModified();
          if (lastModified.isBefore(cutoffTime)) {
            try {
              await file.delete();
            } catch (e) {
              print('Warning: Failed to delete old temp file ${file.path}: $e');
            }
          }
        }
      }
    } catch (e) {
      print('Warning: Failed to cleanup old temporary images: $e');
    }
  }
}
