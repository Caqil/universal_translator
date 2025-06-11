// lib/core/network/network_info.dart - Minimal version with @injectable
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:injectable/injectable.dart';

/// Abstract class for network connectivity information
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
  Future<bool> get hasInternetAccess;
  Future<List<ConnectivityResult>> get connectivityResult;
}

/// Implementation of NetworkInfo
@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;
  final InternetConnectionChecker _internetChecker;

  NetworkInfoImpl(this._connectivity, this._internetChecker);

  @override
  Future<bool> get isConnected async {
    final connectivityResults = await _connectivity.checkConnectivity();
    return connectivityResults.isNotEmpty &&
        !connectivityResults.contains(ConnectivityResult.none);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (results) =>
          results.isNotEmpty && !results.contains(ConnectivityResult.none),
    );
  }

  @override
  Future<bool> get hasInternetAccess async {
    try {
      if (!await isConnected) {
        return false;
      }
      return await _internetChecker.hasConnection;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<ConnectivityResult>> get connectivityResult async {
    return await _connectivity.checkConnectivity();
  }
}

/// Injectable module for external dependencies
@module
abstract class NetworkModule {
  @lazySingleton
  Connectivity get connectivity => Connectivity();

  @lazySingleton
  InternetConnectionChecker get internetConnectionChecker =>
      InternetConnectionChecker.createInstance();
}
