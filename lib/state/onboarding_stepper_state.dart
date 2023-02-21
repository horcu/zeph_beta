import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zeph_beta/stepper/models/zeph_step.dart';

class OnboardingStepperState extends ChangeNotifier {
  late int _stepIndex = -1;

  bool _scanResultsFound = false;
  bool get scanResultsFound => _scanResultsFound;

  bool _isScanning  = false;
  bool get isScanning => _isScanning;

  String _deviceName = "";
  String get deviceName => _deviceName;

  bool _deviceConnected = false;
  get deviceConnected => _deviceConnected;

  get stepIndex => _stepIndex;

   late ZephStep _currentStep = ZephStep(
       content: Container(),
       validation: (){
         return null;
       },
       name: "",
       color: Colors.white,
       showBackButton: true,
       showContinueButton: true, index: 0,
       actionOne: () {  },
       actionTwo: () {  });
  ZephStep get currentStep => _currentStep;

  void setCurrentStep(ZephStep currentStep) {
    _currentStep = currentStep;
    notifyListeners();
  }

  void setCurrentStepIndex(int currentStep) {
    _stepIndex = currentStep;
    notifyListeners();
  }

  setDeviceConnected(bool val) {
    _deviceConnected = val;
    notifyListeners();
  }

  setDeviceName(String val) {
    _deviceName = val;
    notifyListeners();
  }

  void setIsScanning(bool val) {
    _isScanning = val;
    notifyListeners();
  }

  void setScanResultsFound(bool val) {
    _scanResultsFound = val;
    notifyListeners();
  }
}
