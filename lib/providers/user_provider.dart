import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _username = '';

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;

  void login(String name) {
    _username = name.trim();
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _username = '';
    _isLoggedIn = false;
    notifyListeners();
  }
}
