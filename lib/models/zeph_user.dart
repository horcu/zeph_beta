import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:zeph_beta/models/fitness.dart';
import 'package:zeph_beta/models/personal_data.dart';
import '../enums/PrimaryGoal.dart';
import '../enums/gender.dart';
import 'UserInformation.dart';
import 'credentials.dart';

class ZephUser  {
  late PrimaryGoal primaryGoal;
  late double latestBreathabilityScore;
  late Fitness fitnessChoices;
  late PersonalData personalData;
  late Credentials credentials;

  ZephUser init() {
    var zUser =  ZephUser();
    zUser.credentials = Credentials();
    zUser.fitnessChoices = Fitness();
    zUser.personalData = PersonalData();
    zUser.primaryGoal = PrimaryGoal.unKnown;
    zUser.latestBreathabilityScore = 0.0;
    return zUser;
  }

  Map<String, dynamic> toUserInfoJson() {
    return {
      "DateOfBirth": personalData.dob,
      "Name" : credentials.name,
      "Sex": personalData.gender == Gender.male ? "male" : "female",
      "Height": personalData.height,
      "Weight": personalData.weight,
      "SignUpDate": credentials.signUpDate,
      "LatestBreathabilityTest": 0
    };
  }
}