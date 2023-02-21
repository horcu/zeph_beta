// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zeph_beta/user/user_state_persistence.dart';

/// An implementation that uses
/// `package:shared_preferences`.
class LocalStorageUserAuthPersistence extends UserAuthPersistence {
  final Future<SharedPreferences> instanceFuture =
      SharedPreferences.getInstance();

  @override
  Future<bool> getIsLoggedIn() async {
    final prefs = await instanceFuture;
    return prefs.getBool('isUserLoggedIn') ?? false;
  }

  @override
  Future<void> setIsLoggedIn(bool value) async {
    final prefs = await instanceFuture;
    await prefs.setBool('isUserLoggedIn', value);
  }

  @override
  Future<String> getUserId() async {
    final prefs = await instanceFuture;
    return prefs.getString('userId') ?? "0";
  }

  @override
  Future<void> setUserId(String userId) async {
    final prefs = await instanceFuture;
    await prefs.setString('userId', userId);
  }

  @override
  Future<bool> setFcmToken(String fcmToken) async {
    final prefs = await instanceFuture;
    await prefs.setString('fcmToken', fcmToken);
    return true;
  }

  @override
  Future<String> getFcmToken() async {
    final prefs = await instanceFuture;
    return prefs.getString('fcmToken') ?? "";
  }
}
