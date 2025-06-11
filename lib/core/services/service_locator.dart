// lib/core/services/service_locator.dart - Enhanced with debugging
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

/// Service locator wrapper for GetIt with enhanced error handling
class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;

  /// Get service instance with detailed error reporting
  static T get<T extends Object>({String? instanceName}) {
    try {
      // Check if the service is registered first
      if (!_getIt.isRegistered<T>(instanceName: instanceName)) {
        _debugPrintAvailableServices();
        throw ServiceLocatorException(
          'Service of type ${T.toString()} ${instanceName != null ? 'with name "$instanceName" ' : ''}is not registered.\n'
          'Available services have been printed to the debug console.',
        );
      }

      return _getIt.get<T>(instanceName: instanceName);
    } catch (e) {
      debugPrint('❌ Failed to get service ${T.toString()}: $e');

      if (e is ServiceLocatorException) {
        rethrow;
      }

      throw ServiceLocatorException(
        'Service of type ${T.toString()} ${instanceName != null ? 'with name "$instanceName" ' : ''}failed to initialize.\n'
        'Error: ${e.toString()}\n'
        'This usually means one of its dependencies failed to initialize.',
      );
    }
  }

  /// Get service instance asynchronously
  static Future<T> getAsync<T extends Object>({String? instanceName}) async {
    try {
      return await _getIt.getAsync<T>(instanceName: instanceName);
    } catch (e) {
      debugPrint('❌ Failed to get async service ${T.toString()}: $e');
      throw ServiceLocatorException(
        'Async service of type ${T.toString()} ${instanceName != null ? 'with name "$instanceName" ' : ''}not found. '
        'Make sure it is registered in the dependency injection container.',
      );
    }
  }

  /// Check if service is registered
  static bool isRegistered<T extends Object>({String? instanceName}) {
    return _getIt.isRegistered<T>(instanceName: instanceName);
  }

  /// Get service safely with fallback
  static T? getSafe<T extends Object>({String? instanceName}) {
    try {
      return get<T>(instanceName: instanceName);
    } catch (e) {
      debugPrint(
          '⚠️ Failed to get service ${T.toString()}, returning null: $e');
      return null;
    }
  }

  /// Register a singleton service
  static void registerSingleton<T extends Object>(
    T instance, {
    String? instanceName,
    bool signalsReady = false,
  }) {
    try {
      _getIt.registerSingleton<T>(
        instance,
        instanceName: instanceName,
        signalsReady: signalsReady,
      );
      debugPrint(
          '✅ Registered singleton: ${T.toString()}${instanceName != null ? ' ($instanceName)' : ''}');
    } catch (e) {
      debugPrint('❌ Failed to register singleton ${T.toString()}: $e');
      rethrow;
    }
  }

  /// Register a lazy singleton service
  static void registerLazySingleton<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
  }) {
    try {
      _getIt.registerLazySingleton<T>(
        factoryFunc,
        instanceName: instanceName,
      );
      debugPrint(
          '✅ Registered lazy singleton: ${T.toString()}${instanceName != null ? ' ($instanceName)' : ''}');
    } catch (e) {
      debugPrint('❌ Failed to register lazy singleton ${T.toString()}: $e');
      rethrow;
    }
  }

  /// Register a factory service
  static void registerFactory<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
  }) {
    try {
      _getIt.registerFactory<T>(
        factoryFunc,
        instanceName: instanceName,
      );
      debugPrint(
          '✅ Registered factory: ${T.toString()}${instanceName != null ? ' ($instanceName)' : ''}');
    } catch (e) {
      debugPrint('❌ Failed to register factory ${T.toString()}: $e');
      rethrow;
    }
  }

  /// Unregister a service
  static Future<void> unregister<T extends Object>({
    String? instanceName,
    FutureOr<dynamic> Function(T)? disposingFunction,
  }) async {
    await _getIt.unregister<T>(
      instanceName: instanceName,
      disposingFunction: disposingFunction,
    );
  }

  /// Reset all registrations
  static Future<void> reset({bool dispose = true}) async {
    await _getIt.reset(dispose: dispose);
  }

  /// Signal that all dependencies are ready
  static void signalReady(Object? instance) {
    _getIt.signalReady(instance);
  }

  /// Wait for all dependencies to be ready
  static Future<void> allReady({
    Duration? timeout,
    bool ignorePendingAsyncCreation = false,
  }) async {
    await _getIt.allReady(
      timeout: timeout,
      ignorePendingAsyncCreation: ignorePendingAsyncCreation,
    );
  }

  /// Get all registered services of a specific type
  static Iterable<T> getAll<T extends Object>() {
    return _getIt.getAll<T>();
  }

  /// Get dependency scope
  static String? get currentScopeName => _getIt.currentScopeName;

  /// Push new scope
  static void pushNewScope({
    String? scopeName,
    ScopeDisposeFunc? dispose,
  }) {
    _getIt.pushNewScope(
      scopeName: scopeName,
      dispose: dispose,
    );
  }

  /// Pop scope
  static Future<void> popScope() async {
    await _getIt.popScope();
  }

  /// Clear scope
  static Future<void> clearScope([String? scopeName]) async {
    await _getIt.dropScope(scopeName!);
  }

  /// Debug: Print all registered services
  static void _debugPrintAvailableServices() {
    if (!kDebugMode) return;

    debugPrint('📋 Currently registered services:');

    // Get all registered service types (this is a simplified version)
    // Note: GetIt doesn't provide direct access to all registered types,
    // so we'll check common ones
    final commonTypes = [
      'TranslationBloc',
      'SettingsBloc',
      'SpeechBloc',
      'TranslationRepository',
      'SettingsRepository',
      'SpeechRepository',
      'DioClient',
      'NetworkInfo',
      'SharedPreferences',
      'Box',
    ];

    for (final type in commonTypes) {
      try {
        // This is a workaround since GetIt doesn't expose all registered types
        debugPrint(
            '   - $type: ${_getIt.isRegistered(instanceName: type) ? '✅' : '❌'}');
      } catch (e) {
        debugPrint('   - $type: ❓ (could not check)');
      }
    }
  }

  /// Validate critical dependencies
  static bool validateCriticalDependencies() {
    final criticalDependencies = [
      'SharedPreferences',
      'DioClient',
      'NetworkInfo',
    ];

    bool allValid = true;

    for (final dependency in criticalDependencies) {
      if (!_getIt.isRegistered(instanceName: dependency)) {
        debugPrint('❌ Critical dependency missing: $dependency');
        allValid = false;
      }
    }

    return allValid;
  }
}

/// Exception thrown by ServiceLocator
class ServiceLocatorException implements Exception {
  final String message;

  const ServiceLocatorException(this.message);

  @override
  String toString() => 'ServiceLocatorException: $message';
}

/// Service locator convenience extensions
extension ServiceLocatorExtensions on Type {
  /// Get service instance by type
  T call<T extends Object>() => ServiceLocator.get<T>();
}
