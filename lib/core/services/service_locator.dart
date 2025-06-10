import 'dart:async';

import 'package:get_it/get_it.dart';
import '../constants/app_constants.dart';

/// Service locator wrapper for GetIt
/// Provides a cleaner interface for dependency access
class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;

  /// Get service instance
  static T get<T extends Object>({String? instanceName}) {
    try {
      return _getIt.get<T>(instanceName: instanceName);
    } catch (e) {
      throw ServiceLocatorException(
        'Service of type ${T.toString()} ${instanceName != null ? 'with name "$instanceName" ' : ''}not found. '
        'Make sure it is registered in the dependency injection container.',
      );
    }
  }

  /// Get service instance asynchronously
  static Future<T> getAsync<T extends Object>({String? instanceName}) async {
    try {
      return await _getIt.getAsync<T>(instanceName: instanceName);
    } catch (e) {
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

  /// Register a singleton service
  static void registerSingleton<T extends Object>(
    T instance, {
    String? instanceName,
    bool signalsReady = false,
  }) {
    _getIt.registerSingleton<T>(
      instance,
      instanceName: instanceName,
      signalsReady: signalsReady,
    );
  }

  /// Register a lazy singleton service
  static void registerLazySingleton<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
  }) {
    _getIt.registerLazySingleton<T>(
      factoryFunc,
      instanceName: instanceName,
    );
  }

  /// Register a factory service
  static void registerFactory<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
  }) {
    _getIt.registerFactory<T>(
      factoryFunc,
      instanceName: instanceName,
    );
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

  /// Check if GetIt is ready
  static bool get isReady => _getIt.isReadySync<T>();

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
