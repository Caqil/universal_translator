// lib/core/network/network_info.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Abstract class for network connectivity information
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
  Future<bool> get hasInternetAccess;
  Future<List<ConnectivityResult>> get connectivityResult;
}

/// Implementation of NetworkInfo using connectivity_plus and internet_connection_checker
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
      // First check if device is connected to a network
      if (!await isConnected) {
        return false;
      }

      // Then check if there's actual internet access
      return await _internetChecker.hasConnection;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<ConnectivityResult>> get connectivityResult async {
    return await _connectivity.checkConnectivity();
  }

  /// Get detailed connectivity information
  Future<NetworkStatus> getNetworkStatus() async {
    final connectivityResults = await this.connectivityResult;
    final hasInternet = await hasInternetAccess;

    return NetworkStatus(
      connectivityResults: connectivityResults,
      hasInternetAccess: hasInternet,
      isConnected: connectivityResults.isNotEmpty &&
          !connectivityResults.contains(ConnectivityResult.none),
    );
  }

  /// Get connection type string for display
  Future<String> getConnectionType() async {
    final results = await connectivityResult;
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return 'No Connection';
    }
    // Prioritize the most relevant connection type
    if (results.contains(ConnectivityResult.wifi)) return 'WiFi';
    if (results.contains(ConnectivityResult.mobile)) return 'Mobile Data';
    if (results.contains(ConnectivityResult.ethernet)) return 'Ethernet';
    if (results.contains(ConnectivityResult.bluetooth)) return 'Bluetooth';
    if (results.contains(ConnectivityResult.vpn)) return 'VPN';
    return 'Other';
  }

  /// Check if connection is metered (mobile data)
  Future<bool> get isMeteredConnection async {
    final results = await connectivityResult;
    return results.contains(ConnectivityResult.mobile);
  }

  /// Get signal strength for mobile connections (if available)
  Future<int?> getMobileSignalStrength() async {
    final results = await connectivityResult;
    if (results.contains(ConnectivityResult.mobile)) {
      // Platform-specific implementation required (e.g., using native channels)
      return null; // Placeholder
    }
    return null;
  }

  /// Test connection to a specific host
  Future<bool> canReachHost(
    String host, {
    int port = 80,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final checker = InternetConnectionChecker.createInstance(
        addresses: [
          AddressCheckOption(
            uri: Uri.parse(host),
            timeout: timeout,
          ),
        ],
      );
      return await checker.hasConnection;
    } catch (e) {
      return false;
    }
  }
}

/// Data class to hold comprehensive network status information
class NetworkStatus {
  final List<ConnectivityResult> connectivityResults;
  final bool hasInternetAccess;
  final bool isConnected;

  const NetworkStatus({
    required this.connectivityResults,
    required this.hasInternetAccess,
    required this.isConnected,
  });

  bool get isOnline => isConnected && hasInternetAccess;
  bool get isOffline => !isOnline;
  bool get isWifi => connectivityResults.contains(ConnectivityResult.wifi);
  bool get isMobile => connectivityResults.contains(ConnectivityResult.mobile);
  bool get isEthernet =>
      connectivityResults.contains(ConnectivityResult.ethernet);

  @override
  String toString() {
    return 'NetworkStatus(connectivity: $connectivityResults, hasInternet: $hasInternetAccess, isConnected: $isConnected)';
  }
}
