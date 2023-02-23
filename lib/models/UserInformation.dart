import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:zeph_beta/models/fitness.dart';
import 'package:zeph_beta/models/personal_data.dart';
import '../enums/PrimaryGoal.dart';
import '../enums/gender.dart';
import 'credentials.dart';

class UserInformation{
  late String dateOfBirth;
  late String firstName;
  late String lastName;
  late String sex;
  late String height;
  late double weight;
  late double lastBreathabilityTest;
  late String signUpDate;

  UserInformation({
    required this.dateOfBirth,
    required this.firstName,
  required this.lastName,
  required this.sex,
  required this.height,
  required this.weight,
  required this.lastBreathabilityTest,
  required this.signUpDate});

  static UserInformation init() {
    return UserInformation(dateOfBirth: "",
        firstName: "",
        lastName: "",
        sex: "",
        height: "",
        weight: 0,
        lastBreathabilityTest: 0,
        signUpDate: "");
  }

  factory UserInformation.fromJson(dynamic w) {
    try {
     // Map<String, dynamic>? w = jsonDecode(json) as Map<String, dynamic>;

      return UserInformation(
          dateOfBirth: w["DateOfBirth"] ?? "",
          firstName: w["FirstName"] ?? "",
          lastName: w["LastName"] ?? "",
          sex: w["Sex"] ?? "",
          height: w["height"] ?? "",
          weight: w["weight"] ?? 0,
          lastBreathabilityTest: w["lastBreathabilityTest"] ?? 0,
          signUpDate: w["signupDate"] ?? "");

    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return UserInformation.init();
    }
  }
}



