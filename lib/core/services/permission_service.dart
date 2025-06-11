// lib/core/services/permission_service.dart

import 'package:permission_handler/permission_handler.dart';

/// Service for managing app permissions
class PermissionService {
  /// Check if microphone permission is granted
  static Future<bool> get hasMicrophonePermission async {
    return await Permission.microphone.isGranted;
  }

  /// Check if camera permission is granted
  static Future<bool> get hasCameraPermission async {
    return await Permission.camera.isGranted;
  }

  /// Check if storage permission is granted
  static Future<bool> get hasStoragePermission async {
    return await Permission.storage.isGranted;
  }

  /// Check if all required permissions are granted
  static Future<bool> get hasAllRequiredPermissions async {
    final microphone = await hasMicrophonePermission;
    final camera = await hasCameraPermission;
    final storage = await hasStoragePermission;
    return microphone && camera && storage;
  }

  /// Request microphone permission
  static Future<PermissionStatus> requestMicrophonePermission() async {
    return await Permission.microphone.request();
  }

  /// Request camera permission
  static Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  /// Request storage permission
  static Future<PermissionStatus> requestStoragePermission() async {
    return await Permission.storage.request();
  }

  /// Request all permissions at once
  static Future<Map<Permission, PermissionStatus>>
      requestAllPermissions() async {
    return await [
      Permission.microphone,
      Permission.camera,
      Permission.storage,
    ].request();
  }

  /// Get microphone permission status
  static Future<PermissionStatus> get microphoneStatus async {
    return await Permission.microphone.status;
  }

  /// Get camera permission status
  static Future<PermissionStatus> get cameraStatus async {
    return await Permission.camera.status;
  }

  /// Get storage permission status
  static Future<PermissionStatus> get storageStatus async {
    return await Permission.storage.status;
  }

  /// Open app settings for manual permission management
  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Check if should request permissions (not all granted)
  static Future<bool> get shouldRequestPermissions async {
    return !(await hasAllRequiredPermissions);
  }

  /// Get permission status summary for debugging
  static Future<Map<String, String>> getPermissionStatusSummary() async {
    final microphone = await microphoneStatus;
    final camera = await cameraStatus;
    final storage = await storageStatus;

    return {
      'microphone': microphone.toString(),
      'camera': camera.toString(),
      'storage': storage.toString(),
      'all_granted': (await hasAllRequiredPermissions).toString(),
    };
  }
}
