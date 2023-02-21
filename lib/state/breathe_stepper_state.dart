import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zeph_beta/stepper/models/zeph_step.dart';

class BreatheStepperState extends ChangeNotifier {
  late int _stepIndex = -1;
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
}
