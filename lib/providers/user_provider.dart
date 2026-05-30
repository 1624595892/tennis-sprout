import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;

  /// Whether a user (guest or Douyin-authenticated) is currently signed in.
  bool get isLoggedIn => _user != null;

  /// The current user model — null before first login.
  UserModel? get user => _user;

  /// Backward-compat: display name shown in the home header.
  String get username => _user?.nickname ?? '';

  /// Backward-compat: true when authenticated via Douyin (non-guest).
  bool get isDouyinBound => _user != null && !_user!.douyinOpenId.startsWith('guest_');

  /// Douyin OAuth login — sets the real identity.
  void loginViaDouyin({
    required String douyinOpenId,
    required String nickname,
    required String avatarUrl,
    UserRole role = UserRole.student,
  }) {
    _user = UserModel(
      douyinOpenId: douyinOpenId,
      nickname: nickname,
      avatarUrl: avatarUrl,
      role: role,
    );
    notifyListeners();
  }

  /// Guest / nickname-only login — used on desktop when native Douyin SDK isn't available.
  void login(String name) {
    _user = UserModel.guest(name.trim());
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
