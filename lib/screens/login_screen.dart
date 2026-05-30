import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../config/theme.dart';
import '../providers/user_provider.dart';
import '../providers/locale_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = TextEditingController();
  bool _isZh = true;
  bool _showNicknameField = false;

  bool get _isDesktopOrWeb =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows;

  @override
  void initState() {
    super.initState();
    final locale = context.read<LocaleProvider>().locale;
    _isZh = locale.languageCode == 'zh';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitNickname() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    context.read<UserProvider>().login(name);
    Navigator.of(context).pop();
  }

  void _handleDouyinLogin() {
    if (_isDesktopOrWeb) {
      _showQrCodeDialog();
    } else {
      _handleNativeDouyinAuth();
    }
  }

  void _handleNativeDouyinAuth() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isZh ? '请先配置抖音 client_key' : 'Please configure Douyin client_key first'),
        backgroundColor: AppColors.ultraViolet,
      ),
    );
  }

  void _showQrCodeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _DouyinQrDialog(
        isZh: _isZh,
        onSimulateLogin: () {
          Navigator.pop(ctx);
          context.read<UserProvider>().loginViaDouyin(
            douyinOpenId: 'douyin_${DateTime.now().millisecondsSinceEpoch}',
            nickname: _isZh ? '发芽网球手' : 'SproutPlayer',
            avatarUrl: '',
          );
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.wisteria,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ultraViolet,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _isZh ? '登录' : 'Login',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.ultraViolet,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎾', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 8),
              Text(
                _isZh ? '欢迎来到网球手账' : 'Welcome to TennisSprout',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ultraViolet,
                ),
              ),
              const SizedBox(height: 32),

              // ═══════════════════════════════════════════
              // Douyin login capsule card
              // ═══════════════════════════════════════════
              _DouyinLoginButton(
                isDesktopOrWeb: _isDesktopOrWeb,
                onTap: _handleDouyinLogin,
              ),

              const SizedBox(height: 24),

              // ── OR divider ──
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppColors.ultraViolet.withValues(alpha: 0.2),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      _isZh ? '或者' : 'or',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ultraViolet.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColors.ultraViolet.withValues(alpha: 0.2),
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Nickname login toggle ──
              if (!_showNicknameField)
                GestureDetector(
                  onTap: () => setState(() => _showNicknameField = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.ultraViolet.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
                    ),
                    child: Text(
                      _isZh ? '用昵称登录' : 'Sign in with nickname',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ultraViolet.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                ),

              if (_showNicknameField) ...[
                TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  onSubmitted: (_) => _submitNickname(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ultraViolet,
                  ),
                  decoration: InputDecoration(
                    hintText: _isZh ? '输入你的昵称...' : 'Enter your nickname...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.ultraViolet.withValues(alpha: 0.35),
                    ),
                    filled: true,
                    fillColor: AppColors.white.withValues(alpha: 0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitNickname,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellowGreen,
                      foregroundColor: AppColors.pakistanGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
                      ),
                    ),
                    child: Text(
                      _isZh ? '开启发芽之旅 🌱' : 'Start Sprouting 🌱',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// DOUYIN LOGIN BUTTON — dark gray capsule
// ═══════════════════════════════════════════════
class _DouyinLoginButton extends StatelessWidget {
  final bool isDesktopOrWeb;
  final VoidCallback onTap;

  const _DouyinLoginButton({
    required this.isDesktopOrWeb,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3C),
          borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3A3A3C).withValues(alpha: 0.30),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/douyin_note.svg',
              width: 28,
              height: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              '用抖音账号一键栽种种子 🦘',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
            if (isDesktopOrWeb) ...[
              const SizedBox(width: 6),
              Text(
                '📱',
                style: TextStyle(fontSize: 13, color: AppColors.yellowGreen.withValues(alpha: 0.6)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// QR CODE DIALOG — journal photo-frame style
// ═══════════════════════════════════════════════
class _DouyinQrDialog extends StatefulWidget {
  final bool isZh;
  final VoidCallback onSimulateLogin;

  const _DouyinQrDialog({required this.isZh, required this.onSimulateLogin});

  @override
  State<_DouyinQrDialog> createState() => _DouyinQrDialogState();
}

class _DouyinQrDialogState extends State<_DouyinQrDialog> {
  static const _kPlaceholderClientKey = 'douyin_client_key_placeholder';
  static const _kRedirectUri = 'https://vocal-biscuit-e6a310.netlify.app/callback';

  static String _buildQrLoginUrl() {
    return 'https://open.douyin.com/platform/oauth/connect'
        '?client_key=$_kPlaceholderClientKey'
        '&response_type=code'
        '&scope=user_info'
        '&redirect_uri=${Uri.encodeComponent(_kRedirectUri)}'
        '&state=tennis-sprout';
  }

  @override
  Widget build(BuildContext context) {
    final isZh = widget.isZh;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFBF7),
          borderRadius: BorderRadius.circular(TennisTheme.radiusLG),
          border: Border.all(color: AppColors.wisteria, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.ultraViolet.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isZh ? '📱 抖音扫码登录' : 'Scan with Douyin',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ultraViolet,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isZh ? '打开抖音扫一扫二维码' : 'Open Douyin and scan the QR code',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ultraViolet.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),

            // QR code
            Container(
              width: 180,
              height: 180,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.wisteria, width: 1.5),
              ),
              child: QrImageView(
                data: _buildQrLoginUrl(),
                version: QrVersions.auto,
                size: 156,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.circle,
                  color: Color(0xFF3A3A3C),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.circle,
                  color: Color(0xFF3A3A3C),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Demo login button — simulates successful Douyin auth
            GestureDetector(
              onTap: widget.onSimulateLogin,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3C),
                  borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/douyin_note.svg',
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isZh ? '模拟扫码登录 (测试)' : 'Simulate Scan (Test)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.yellowGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.wisteriaLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(TennisTheme.radiusSM),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 14, color: AppColors.ultraViolet.withValues(alpha: 0.5)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      isZh
                          ? '配置真实抖音开放平台 client_key 后，扫码即可自动授权登录'
                          : 'After configuring a real Douyin client_key, scan to auto-login',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ultraViolet.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.coralRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.close, size: 18, color: AppColors.coralRed),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
