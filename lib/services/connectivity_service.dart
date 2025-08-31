import 'dart:async';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  bool _isOnline = true;
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();

  bool get isOnline => _isOnline;
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  void _updateConnectivity(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      _connectivityController.add(isOnline);
      debugPrint('Connectivity changed: ${isOnline ? 'Online' : 'Offline'}');
    }
  }

  void initialize() {
    _simulateConnectivityCheck();
  }

  void _simulateConnectivityCheck() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateConnectivity(true);
    });
  }

  void setConnectivity(bool isOnline) {
    _updateConnectivity(isOnline);
  }

  void dispose() {
    _connectivityController.close();
  }
}