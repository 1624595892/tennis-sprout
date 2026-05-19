import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    context.read<UserProvider>().login(name);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.wisteria,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ultraViolet,
        elevation: 0,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decorative tennis emoji
              const Text('🎾', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text(
                _isZh ? '欢迎来到网球手账' : 'Welcome to TennisSprout',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ultraViolet,
                ),
              ),
              const SizedBox(height: 32),

              // Green card with input
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.yellowGreen,
                  borderRadius: BorderRadius.circular(TennisTheme.radiusLG),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pakistanGreen.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(2, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.person_outline_rounded,
                        size: 40, color: AppColors.pakistanGreen.withValues(alpha: 0.7)),
                    const SizedBox(height: 12),
                    Text(
                      _isZh ? '取个名字吧' : 'Pick a nickname',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.pakistanGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isZh ? '你的手写体网球种子名' : 'Your hand-written tennis seed name',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pakistanGreen.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      onSubmitted: (_) => _submit(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.pakistanGreen,
                      ),
                      decoration: InputDecoration(
                        hintText: _isZh ? '输入你的昵称...' : 'Enter your nickname...',
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: AppColors.pakistanGreen.withValues(alpha: 0.35),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pakistanGreen,
                          foregroundColor: AppColors.yellowGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _isZh ? '开启发芽之旅 🌱' : 'Start Sprouting 🌱',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
