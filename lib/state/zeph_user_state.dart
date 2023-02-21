import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zeph_beta/models/zeph_user.dart';
import 'package:zeph_beta/stepper/models/zeph_step.dart';

class ZephUserState extends ChangeNotifier {

  late ZephUser _zephUser = ZephUser().init();
  ZephUser get zephUser => _zephUser;

  setZephUser(ZephUser zUser){
    _zephUser = zUser;
    notifyListeners();
  }
}
