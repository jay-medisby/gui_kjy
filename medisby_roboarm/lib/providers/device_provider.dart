import 'package:flutter/material.dart';
import '../widgets/device_status_badge.dart';

class DeviceProvider extends ChangeNotifier {
  bool _isConnected = true;
  DeviceStatus _status = DeviceStatus.ready;

  bool get isConnected => _isConnected;
  DeviceStatus get status => _status;

  void setConnected(bool value) {
    _isConnected = value;
    notifyListeners();
  }

  void setStatus(DeviceStatus value) {
    _status = value;
    notifyListeners();
  }
}
