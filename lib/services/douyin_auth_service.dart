import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// Platform-aware Douyin authentication service.
///
/// - **Android / iOS**: invokes native Douyin Open SDK.
/// - **macOS / Windows / Web**: shows a QR code for scan-to-login.
///
/// Setup steps:
/// 1. Register at https://open.douyin.com (抖音开放平台) and obtain a `client_key`.
/// 2. On mobile: integrate the Douyin Open SDK (Android/iOS native setup required).
/// 3. On web: configure the OAuth2 redirect URI on the Douyin Open Platform.
class DouyinAuthService {
  factory DouyinAuthService({required String clientKey}) =>
      _instance ??= DouyinAuthService._(clientKey: clientKey);

  static DouyinAuthService? _instance;

  final String clientKey;
  final bool isMobile;
  final bool isDesktop;

  DouyinAuthService._({required this.clientKey})
      : isMobile = !kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS),
        isDesktop = kIsWeb ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.windows;

  // ── Mobile: native Douyin SDK ──

  /// Register the native Douyin SDK on mobile.
  Future<void> initMobile() async {
    if (!isMobile) return;
    // TODO: initialize Douyin Open SDK with clientKey
  }

  /// Trigger native Douyin auth on mobile. Returns user info on success.
  Future<Map<String, String>?> loginViaNative() async {
    if (!isMobile) return null;
    // TODO: call Douyin native auth, receive openId, nickname, avatarUrl
    throw UnimplementedError('Douyin native SDK requires client_key configuration');
  }

  // ── Desktop / Web: QR code scan login ──

  /// Builds the Douyin OAuth2 QR-login URL.
  ///
  /// The user scans this QR with the Douyin app; after confirmation Douyin
  /// redirects to [redirectUri] with ?code=... which your backend exchanges
  /// for an access_token and openid.
  String buildQrLoginUrl({
    required String redirectUri,
    String scope = 'user_info',
    String state = 'tennis-sprout',
  }) {
    return 'https://open.douyin.com/platform/oauth/connect'
        '?client_key=$clientKey'
        '&response_type=code'
        '&scope=$scope'
        '&redirect_uri=${Uri.encodeComponent(redirectUri)}'
        '&state=$state';
  }
}
