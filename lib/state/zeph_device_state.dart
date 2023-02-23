import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zeph_beta/models/zeph_user.dart';
import 'package:zeph_beta/stepper/models/zeph_step.dart';

class ZephDeviceState extends ChangeNotifier {

  late String _deviceName = "";
  String get deviceName => _deviceName;

  late bool _isConnected = false;
  bool get isConnected => _isConnected;

  late bool _isScanning = false;
  bool get isScanning => _isScanning;

  late double _batteryLife = 0.0;
  double get batteryLife => _batteryLife;


  setDeviceName(String name){
    _deviceName = name;
    notifyListeners();
  }

  setIsConnected(bool connected){
    _isConnected = connected;
    notifyListeners();
  }

  setIsScanning(bool scanning){
    _isScanning = scanning;
    notifyListeners();
  }

  setBatteryLife(double life){
    _batteryLife = life;
    notifyListeners();
  }
}
