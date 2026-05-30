/// Role-based routing after login.
enum UserRole { student, coach }

class UserModel {
  /// Douyin unique OpenID — guarantees one account per person across platforms.
  final String douyinOpenId;

  /// Auto-synced Douyin nickname.
  final String nickname;

  /// Auto-synced Douyin avatar URL.
  final String avatarUrl;

  /// Identity routing: Student or Coach.
  final UserRole role;

  /// Reserved field for future Xiaohongshu hand-account binding on the community page.
  final String? xhsId;

  const UserModel({
    required this.douyinOpenId,
    required this.nickname,
    required this.avatarUrl,
    required this.role,
    this.xhsId,
  });

  UserModel copyWith({
    String? douyinOpenId,
    String? nickname,
    String? avatarUrl,
    UserRole? role,
    String? xhsId,
  }) {
    return UserModel(
      douyinOpenId: douyinOpenId ?? this.douyinOpenId,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      xhsId: xhsId ?? this.xhsId,
    );
  }

  /// Guest user displayed before full Douyin OAuth is wired up.
  factory UserModel.guest(String name) {
    return UserModel(
      douyinOpenId: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      nickname: name,
      avatarUrl: '',
      role: UserRole.student,
    );
  }
}
