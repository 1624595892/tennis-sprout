import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/locale_provider.dart';
import '../providers/daily_status_provider.dart';
import '../providers/skill_tree_provider.dart';
import '../providers/practice_provider.dart';
import '../providers/match_provider.dart';
import '../providers/user_provider.dart';
import '../config/routes.dart';
import '../widgets/daily_status/daily_check_in_card.dart';
import '../widgets/common/paper_background.dart';
import '../widgets/common/sticker_card.dart';
import '../widgets/common/hand_drawn_divider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _runController;
  late final AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _runController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _runController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final userProvider = context.watch<UserProvider>();
    final isZh = localeProvider.isZh;

    return Scaffold(
      // ── Sticky header bar with yellowGreen background ──
      appBar: AppBar(
        backgroundColor: AppColors.yellowGreen,
        foregroundColor: AppColors.pakistanGreen,
        elevation: 2,
        shadowColor: AppColors.yellowGreen.withValues(alpha: 0.3),
        title: SizedBox(
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pill button — left-aligned, auto-sized
              Align(
                alignment: Alignment.centerLeft,
                child: _UserPillButton(
                  isLoggedIn: userProvider.isLoggedIn,
                  username: userProvider.username,
                  isZh: isZh,
                ),
              ),
              // Centered title with sprout icons
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 80),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SproutIcon(),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'TENNIS Sprout',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.pakistanGreen,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    _SproutIcon(),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          _LanguageSwitch(isZh: isZh, localeProvider: localeProvider),
          const SizedBox(width: 12),
        ],
      ),

      // ── Journal paper grid background ──
      body: PaperBackground(
        overlayColor: AppColors.wisteria.withValues(alpha: 0.30),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // ═════════════════════════════════════════
              // CENTER — Logo with floating mini tennis balls
              // ═════════════════════════════════════════
              _AnimatedLogoSection(
                runController: _runController,
                bounceController: _bounceController,
              ),
              const SizedBox(height: 16),

              const HandDrawnDivider(wavy: true),
              const SizedBox(height: 8),

              // ═════════════════════════════════════════
              // DAILY STATUS — Wide Polaroid-style card
              // ═════════════════════════════════════════
              Consumer<DailyStatusProvider>(
                builder: (context, dailyProvider, _) {
                  return DailyCheckInCard(
                    provider: dailyProvider,
                    isZh: isZh,
                  );
                },
              ),

              const SizedBox(height: 12),
              const HandDrawnDivider(dashWidth: 8, dashGap: 5),
              const SizedBox(height: 14),

              // ═════════════════════════════════════════
              // FEATURE CARDS — Vertical Stack
              // ═════════════════════════════════════════
              _SectionLabel(label: isZh ? ' 今日手账' : ' Journal'),
              const SizedBox(height: 12),

              _FeatureCard(
                emoji: '📖',
                title: isZh ? '中英网球词汇学堂' : 'Tennis Vocab Academy',
                subtitle: isZh ? '掌握网球专业术语' : 'Master tennis terminology',
                color: AppColors.yellowGreen,
                onTap: () => Navigator.pushNamed(context, '/vocab-academy'),
              ),
              const SizedBox(height: 14),

              _FeatureCard(
                emoji: '🏋️',
                title: isZh ? '练习日志' : 'Practice Log',
                subtitle: isZh ? '记录每一次挥拍' : 'Log every session',
                color: AppColors.yellowGreenDark,
                onTap: () => Navigator.pushNamed(context, '/practice-log'),
                trailing: Consumer<PracticeProvider>(
                  builder: (context, p, _) => _StatBadge(
                    value: '${p.totalMinutes}',
                    unit: 'min',
                    color: AppColors.yellowGreenDark,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              _FeatureCard(
                emoji: '🏆',
                title: isZh ? '比赛记录' : 'Match Recorder',
                subtitle: isZh ? '追踪每场比赛数据' : 'Track match stats',
                color: AppColors.skyBlue,
                onTap: () => Navigator.pushNamed(context, '/match-recorder'),
                trailing: Consumer<MatchProvider>(
                  builder: (context, p, _) => _WLBadge(
                    wins: p.wins,
                    losses: p.losses,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              _FeatureCard(
                emoji: '🌱',
                title: isZh ? '技术清单与 NTRP 评级' : 'Skill Tree & NTRP',
                subtitle: isZh ? '技能成长追踪' : 'Track your skill growth',
                color: AppColors.avocado,
                onTap: () => Navigator.pushNamed(context, '/skill-tree'),
                trailing: Consumer<SkillTreeProvider>(
                  builder: (context, p, _) => _StatBadge(
                    value: p.ntprEstimate.toStringAsFixed(1),
                    unit: 'NTRP',
                    color: AppColors.avocado,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              _FeatureCard(
                emoji: '📊',
                title: isZh ? '数据分析与 AI 建议' : 'Insights & AI Agent',
                subtitle: isZh ? 'AI 驱动的技术洞察' : 'AI-powered insights',
                color: AppColors.amber,
                onTap: () => Navigator.pushNamed(context, '/insights'),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// ANIMATED LOGO SECTION
// Running mascot with limbs + bouncing mini balls clustered below
// ═══════════════════════════════════════════════
class _AnimatedLogoSection extends StatelessWidget {
  final AnimationController runController;
  final AnimationController bounceController;

  const _AnimatedLogoSection({
    required this.runController,
    required this.bounceController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([runController, bounceController]),
      builder: (context, child) {
        final runT = runController.value;
        final bounceT = bounceController.value;

        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: 360,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ..._buildBouncingBalls(bounceT, constraints.maxWidth / 2),
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Center(child: _RunningMascot(runT: runT)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildBouncingBalls(double t, double centerX) {
    final configs = [
      _BounceConfig(cx: -46, row: 0, size: 22, phase: 0.0),
      _BounceConfig(cx: 0, row: 0, size: 26, phase: 0.22),
      _BounceConfig(cx: 46, row: 0, size: 20, phase: 0.44),
      _BounceConfig(cx: -30, row: 1, size: 20, phase: 0.58),
      _BounceConfig(cx: 30, row: 1, size: 24, phase: 0.78),
      _BounceConfig(cx: 2, row: 2, size: 18, phase: 0.12),
    ];

    const baseY = 290.0;

    return configs.map((c) {
      final phase = (t + c.phase) % 1.0;
      final bounce = pow(sin(phase * pi), 2).toDouble() * 24.0;
      final y = baseY + c.row * 38 - bounce;

      return Positioned(
        left: centerX + c.cx - c.size / 2,
        top: y,
        child: Opacity(
          opacity: 0.4 + (1 - (bounce / 24.0)) * 0.35,
          child: SizedBox(
            width: c.size,
            height: c.size,
            child: CustomPaint(painter: _MiniTennisBallPainter()),
          ),
        ),
      );
    }).toList();
  }
}

class _BounceConfig {
  final double cx;
  final int row;
  final double size;
  final double phase;
  const _BounceConfig({
    required this.cx,
    required this.row,
    required this.size,
    required this.phase,
  });
}

// ═══════════════════════════════════════════════
// RUNNING MASCOT — tennis ball with animated limbs
// ═══════════════════════════════════════════════
class _RunningMascot extends StatelessWidget {
  final double runT;
  const _RunningMascot({required this.runT});

  @override
  Widget build(BuildContext context) {
    final bobY = sin(runT * 4 * pi) * 4.0;
    final tilt = sin(runT * 2 * pi) * 0.06;

    return Transform.translate(
      offset: Offset(0, bobY),
      child: Transform.rotate(
        angle: tilt,
        child: SizedBox(
          width: 180,
          height: 180,
          child: CustomPaint(
            painter: _MascotPainter(runT: runT),
          ),
        ),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  final double runT;
  _MascotPainter({required this.runT});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.36; // smaller ball to fit limbs inside 100x100 box

    // ── Body (tennis ball) ──
    final ballPaint = Paint()
      ..color = AppColors.yellowGreen
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r, ballPaint);

    final gradPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.95,
        colors: [
          AppColors.yellowGreenLight.withValues(alpha: 0.6),
          Colors.transparent,
          AppColors.yellowGreenDark.withValues(alpha: 0.4),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, gradPaint);

    // Seam lines
    final seamPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(_leftSeam(cx, cy, r), seamPaint);
    canvas.drawPath(_rightSeam(cx, cy, r), seamPaint);

    // ── Headband ──
    canvas.save();
    canvas.clipRect(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    final headbandPaint = Paint()
      ..color = AppColors.ultraViolet
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTRB(cx - r, cy - r * 0.28, cx + r, cy - r * 0.05),
      headbandPaint,
    );
    canvas.restore();

    // ── Face ──
    final eyePaint = Paint()
      ..color = AppColors.pakistanGreen
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - r * 0.28, cy + r * 0.1), 3.2, eyePaint);
    canvas.drawCircle(Offset(cx + r * 0.28, cy + r * 0.1), 3.2, eyePaint);

    final hlPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - r * 0.28 - 1, cy + r * 0.1 - 1), 1.2, hlPaint);
    canvas.drawCircle(Offset(cx + r * 0.28 - 1, cy + r * 0.1 - 1), 1.2, hlPaint);

    final smilePaint = Paint()
      ..color = AppColors.pakistanGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(cx - r * 0.15, cy + r * 0.28)
        ..quadraticBezierTo(cx, cy + r * 0.42, cx + r * 0.15, cy + r * 0.28),
      smilePaint,
    );

    final cheekPaint = Paint()
      ..color = AppColors.coralRed.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - r * 0.48, cy + r * 0.22), 5, cheekPaint);
    canvas.drawCircle(Offset(cx + r * 0.48, cy + r * 0.22), 5, cheekPaint);

    // ── Limbs ──
    final limbPaint = Paint()
      ..color = AppColors.ultraViolet
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final swingAngle = runT * 2 * pi;

    // Left arm — swings opposite to left leg
    _drawArm(canvas, cx - r * 0.72, cy + r * 0.05, sin(swingAngle) * 0.7, r, limbPaint, flip: true);
    // Right arm — swings opposite to right leg
    _drawArm(canvas, cx + r * 0.72, cy + r * 0.05, sin(swingAngle + pi) * 0.7, r, limbPaint, flip: false);
    // Left leg
    _drawLeg(canvas, cx - r * 0.28, cy + r * 0.82, sin(swingAngle + pi) * 0.55, r, limbPaint);
    // Right leg
    _drawLeg(canvas, cx + r * 0.28, cy + r * 0.82, sin(swingAngle) * 0.55, r, limbPaint);
  }

  void _drawArm(Canvas canvas, double bx, double by, double swing, double r, Paint paint, {required bool flip}) {
    final path = Path();
    path.moveTo(bx, by);
    path.quadraticBezierTo(
      bx + (flip ? -1 : 1) * r * 0.5,
      by - r * 0.2 + swing * r * 0.45,
      bx + (flip ? -1 : 1) * r * 0.7 + swing * r * 0.15,
      by - r * 0.5 + swing * r * 0.5,
    );
    canvas.drawPath(path, paint);
  }

  void _drawLeg(Canvas canvas, double bx, double by, double swing, double r, Paint paint) {
    final path = Path();
    path.moveTo(bx, by);
    path.quadraticBezierTo(
      bx + swing * r * 0.3,
      by + r * 0.35,
      bx + swing * r * 0.6,
      by + r * 0.7,
    );
    canvas.drawPath(path, paint);
  }

  Path _leftSeam(double cx, double cy, double r) => Path()
    ..moveTo(cx - r * 0.25, cy - r * 0.9)
    ..quadraticBezierTo(cx - r * 0.55, cy, cx - r * 0.25, cy + r * 0.9);

  Path _rightSeam(double cx, double cy, double r) => Path()
    ..moveTo(cx + r * 0.25, cy - r * 0.9)
    ..quadraticBezierTo(cx + r * 0.55, cy, cx + r * 0.25, cy + r * 0.9);

  @override
  bool shouldRepaint(covariant _MascotPainter old) => old.runT != runT;
}

// ═══════════════════════════════════════════════
// MINI TENNIS BALL PAINTER — simplified, no face
// ═══════════════════════════════════════════════
class _MiniTennisBallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final ballPaint = Paint()
      ..color = AppColors.yellowGreen
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, ballPaint);

    final gradientPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.9,
        colors: [
          AppColors.yellowGreenLight.withValues(alpha: 0.5),
          Colors.transparent,
          AppColors.yellowGreenDark.withValues(alpha: 0.3),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, gradientPaint);

    final seamPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - radius * 0.22, center.dy - radius * 0.85)
        ..quadraticBezierTo(center.dx - radius * 0.5, center.dy, center.dx - radius * 0.22, center.dy + radius * 0.85),
      seamPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(center.dx + radius * 0.22, center.dy - radius * 0.85)
        ..quadraticBezierTo(center.dx + radius * 0.5, center.dy, center.dx + radius * 0.22, center.dy + radius * 0.85),
      seamPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ═══════════════════════════════════════════════
// LANGUAGE SWITCH — in the header bar
// ═══════════════════════════════════════════════
// ═══════════════════════════════════════════════
// USER PILL BUTTON — login / username toggle
// ═══════════════════════════════════════════════
class _UserPillButton extends StatelessWidget {
  final bool isLoggedIn;
  final String username;
  final bool isZh;

  const _UserPillButton({
    required this.isLoggedIn,
    required this.username,
    required this.isZh,
  });

  void _onTap(BuildContext context) {
    if (isLoggedIn) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.wisteriaLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TennisTheme.radiusLG),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎾', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                isZh
                    ? '$username 的网球种子正在茁壮成长中！🌱'
                    : '$username\'s tennis seed is sprouting strong! 🌱',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ultraViolet,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                isZh ? '好的' : 'OK',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ultraViolet,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.pushNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        margin: const EdgeInsets.only(left: 4, top: 12, bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
          border: Border.all(
            color: AppColors.ultraViolet.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.ultraViolet.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLoggedIn ? Icons.person_rounded : Icons.lock_outline_rounded,
              size: 13,
              color: AppColors.ultraViolet,
            ),
            const SizedBox(width: 4),
            Text(
              isLoggedIn ? username : '登录',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.ultraViolet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// SPROUT ICON — hand-drawn purple sprout for AppBar title
// ═══════════════════════════════════════════════
class _SproutIcon extends StatelessWidget {
  const _SproutIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _SproutPainter()),
    );
  }
}

class _SproutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final baseY = h * 0.85;

    final stemPaint = Paint()
      ..color = AppColors.ultraViolet
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Curved stem
    final stemPath = Path()
      ..moveTo(cx, baseY)
      ..quadraticBezierTo(cx + w * 0.3, baseY - h * 0.5, cx - w * 0.05, baseY - h * 0.85);
    canvas.drawPath(stemPath, stemPaint);

    // Left leaf
    final leafPaint = Paint()
      ..color = AppColors.ultraViolet.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    final leafPath = Path()
      ..moveTo(cx - w * 0.15, baseY - h * 0.55)
      ..quadraticBezierTo(cx - w * 0.55, baseY - h * 0.65, cx - w * 0.5, baseY - h * 0.78)
      ..quadraticBezierTo(cx - w * 0.15, baseY - h * 0.7, cx - w * 0.15, baseY - h * 0.55);
    canvas.drawPath(leafPath, leafPaint);

    // Right leaf
    final rLeafPath = Path()
      ..moveTo(cx + w * 0.1, baseY - h * 0.42)
      ..quadraticBezierTo(cx + w * 0.55, baseY - h * 0.48, cx + w * 0.45, baseY - h * 0.62)
      ..quadraticBezierTo(cx + w * 0.1, baseY - h * 0.55, cx + w * 0.1, baseY - h * 0.42);
    canvas.drawPath(rLeafPath, leafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _LanguageSwitch extends StatelessWidget {
  final bool isZh;
  final LocaleProvider localeProvider;

  const _LanguageSwitch({required this.isZh, required this.localeProvider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => localeProvider.toggle(),
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.pakistanGreen.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
          border: Border.all(
            color: AppColors.pakistanGreen.withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isZh ? 'EN' : '中文',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.pakistanGreen,
              ),
            ),
            const SizedBox(width: 3),
            Icon(Icons.swap_horiz, size: 14, color: AppColors.pakistanGreen.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// SECTION LABEL
// ═══════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.yellowGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.ultraViolet,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// FEATURE CARD
// ═══════════════════════════════════════════════
class _FeatureCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final Widget? trailing;

  const _FeatureCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: StickerCard(
        padding: const EdgeInsets.all(16),
        backgroundColor: color.withValues(alpha: 0.06),
        rotation: 0,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(TennisTheme.radiusSM),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ultraViolet)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ultraViolet)),
                ],
              ),
            ),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right, size: 20, color: AppColors.ultraViolet.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// STAT BADGE
// ═══════════════════════════════════════════════
class _StatBadge extends StatelessWidget {
  final String value;
  final String unit;
  final Color color;

  const _StatBadge({required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TennisTheme.radiusSM),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color, height: 1.1)),
          Text(unit, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color.withValues(alpha: 0.65))),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// W/L BADGE
// ═══════════════════════════════════════════════
class _WLBadge extends StatelessWidget {
  final int wins;
  final int losses;

  const _WLBadge({required this.wins, required this.losses});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$wins', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.mintGreen)),
        Text(' / ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ultraViolet.withValues(alpha: 0.3))),
        Text('$losses', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.coralRed)),
      ],
    );
  }
}
