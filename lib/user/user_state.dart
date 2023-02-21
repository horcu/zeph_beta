import 'package:flutter/cupertino.dart';
import 'package:zeph_beta/user/user_state_persistence.dart';

class UserState extends ChangeNotifier {
  final UserAuthPersistence _store;

  /// Creates an instance of [UserState] backed by an injected
  /// persistence [store].
  UserState(UserAuthPersistence store) : _store = store;

  bool _isLoggedIn = false;
  Future<bool> Function() get isLoggedIn => getIsLoggedIn;

  Future<bool> getIsLoggedIn() async {
    final isLoggedIn = await _store.getIsLoggedIn();
    _isLoggedIn = isLoggedIn;
    return isLoggedIn;
  }

  setIsLoggedIn(bool value) {
    _isLoggedIn = value;
    _store.setIsLoggedIn(value);
    notifyListeners();
  }

  void setUserId(String userId) {
    _store.setUserId(userId);
    notifyListeners();
  }

  Future<String> getUserId() async {
    return await _store.getUserId();
  }

  void setFcmToken(String fcmToken) {
    _store.setFcmToken(fcmToken);
    notifyListeners();
  }
}
