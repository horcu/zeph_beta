import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zeph_beta/models/UserInformation.dart';
import 'package:zeph_beta/models/zeph_user.dart';
import 'package:zeph_beta/stepper/models/zeph_step.dart';

class DashboardState extends ChangeNotifier {
  UserInformation _userInformation  =  UserInformation.init();

  late String _stateCity = "";
  String get stateCity => _stateCity;

  UserInformation get userInformation  => _userInformation;


  void setUserInformation(UserInformation userInformation) {
    _userInformation = userInformation;
    notifyListeners();
  }

  void setCurrentLocationStateAndCity(String state, String city) {
    _stateCity = "$state, $city";
    notifyListeners();
  }

}
