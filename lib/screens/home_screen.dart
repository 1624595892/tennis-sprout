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

// ═══════════════════════════════════════════════
// GRAND SLAM — court skin configs
// ═══════════════════════════════════════════════
enum GrandSlam { ao, rg, wb, us }

extension GrandSlamSkin on GrandSlam {
  String get label {
    switch (this) {
      case GrandSlam.ao: return '澳网';
      case GrandSlam.rg: return '法网';
      case GrandSlam.wb: return '温网';
      case GrandSlam.us: return '美网';
    }
  }

  String get flag {
    switch (this) {
      case GrandSlam.ao: return '🇦🇺';
      case GrandSlam.rg: return '🇫🇷';
      case GrandSlam.wb: return '🇬🇧';
      case GrandSlam.us: return '🇺🇸';
    }
  }

  Color get courtColor {
    switch (this) {
      case GrandSlam.ao: return const Color(0xFF8FB7DB);
      case GrandSlam.rg: return const Color(0xFFD67B66);
      case GrandSlam.wb: return const Color(0xFF769471);
      case GrandSlam.us: return const Color(0xFF5C78A4);
    }
  }

  Color get lineColor {
    switch (this) {
      case GrandSlam.ao: return Colors.white.withValues(alpha: 0.55);
      case GrandSlam.rg: return Colors.white.withValues(alpha: 0.40);
      case GrandSlam.wb: return AppColors.white.withValues(alpha: 0.50);
      case GrandSlam.us: return AppColors.yellowGreen.withValues(alpha: 0.55);
    }
  }

  bool get showStrawberry => this == GrandSlam.wb;
  bool get showClayParticles => this == GrandSlam.rg;
}

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
        centerTitle: true,
        leading: _UserIconButton(
          isLoggedIn: userProvider.isLoggedIn,
          username: userProvider.username,
          isDouyinBound: userProvider.isDouyinBound,
          avatarUrl: userProvider.user?.avatarUrl,
          isZh: isZh,
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SproutIcon(),
            SizedBox(width: 6),
            Text(
              'TENNIS Sprout',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.pakistanGreen,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(width: 6),
            _SproutIcon(),
          ],
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
              // CENTER — Mascot + Grand Slam court mat
              // ═════════════════════════════════════════
              _GrandSlamLogoSection(
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
                emoji: '📅',
                title: isZh ? '成长轨迹' : 'Growth Trajectory',
                subtitle: isZh ? '日历回溯每一次挥拍' : 'Calendar view of every session',
                color: AppColors.mintGreen,
                onTap: () => Navigator.pushNamed(context, '/growth-trajectory'),
                trailing: Consumer<PracticeProvider>(
                  builder: (context, p, _) => _StatBadge(
                    value: '${p.loggedDates.length}',
                    unit: isZh ? '天' : 'd',
                    color: AppColors.mintGreen,
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

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// GRAND SLAM LOGO SECTION
// Mascot standing on a Grand Slam court mat with bouncing balls + capsule switcher
// ═══════════════════════════════════════════════
class _GrandSlamLogoSection extends StatefulWidget {
  final AnimationController runController;
  final AnimationController bounceController;

  const _GrandSlamLogoSection({
    required this.runController,
    required this.bounceController,
  });

  @override
  State<_GrandSlamLogoSection> createState() => _GrandSlamLogoSectionState();
}

class _GrandSlamLogoSectionState extends State<_GrandSlamLogoSection> {
  GrandSlam _selected = GrandSlam.ao;

  void _selectCourt(GrandSlam gs) {
    if (gs == _selected) return;
    setState(() => _selected = gs);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.runController, widget.bounceController]),
      builder: (context, child) {
        final runT = widget.runController.value;
        final bounceT = widget.bounceController.value;

        return LayoutBuilder(
          builder: (context, constraints) {
            final centerX = constraints.maxWidth / 2;
            return SizedBox(
              height: 480,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Layer 1: Court surface (behind balls) ──
                  Positioned(
                    top: 320,
                    left: centerX - 195,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      width: 390,
                      height: 88,
                      decoration: BoxDecoration(
                        color: _selected.courtColor.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _selected.courtColor.withValues(alpha: 0.8),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _selected.courtColor.withValues(alpha: 0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: _CourtLinePainter(
                          courtColor: _selected.courtColor,
                          lineColor: _selected.lineColor,
                        ),
                      ),
                    ),
                  ),

                  // Easter egg: clay particles (Roland Garros)
                  if (_selected.showClayParticles)
                    ..._buildClayParticles(centerX),

                  // Easter egg: strawberry bubble (Wimbledon)
                  if (_selected.showStrawberry)
                    Positioned(
                      top: 16,
                      left: centerX + 44,
                      child: _StrawberryBubble(runT: runT),
                    ),

                  // ── Layer 2: Bouncing mini balls ──
                  ..._buildBouncingBalls(bounceT, centerX),

                  // ── Layer 3: Running mascot ──
                  Positioned(
                    top: 46,
                    left: 0,
                    right: 0,
                    child: Center(child: _RunningMascot(runT: runT)),
                  ),

                  // ── Layer 4: Court switcher dots ──
                  Positioned(
                    top: 422,
                    left: 0,
                    right: 0,
                    child: _GrandSlamDots(
                      selected: _selected,
                      onSelect: _selectCourt,
                    ),
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
      _BounceConfig(cx: -52, row: 0, size: 22, phase: 0.0),
      _BounceConfig(cx: 0, row: 0, size: 26, phase: 0.22),
      _BounceConfig(cx: 52, row: 0, size: 20, phase: 0.44),
      _BounceConfig(cx: -34, row: 1, size: 20, phase: 0.58),
      _BounceConfig(cx: 34, row: 1, size: 24, phase: 0.78),
    ];

    const baseY = 274.0;

    return configs.map((c) {
      final phase = (t + c.phase) % 1.0;
      final bounce = pow(sin(phase * pi), 2).toDouble() * 18.0;
      final y = baseY + c.row * 34 - bounce;

      return Positioned(
        left: centerX + c.cx - c.size / 2,
        top: y,
        child: Opacity(
          opacity: 0.38 + (1 - (bounce / 18.0)) * 0.35,
          child: SizedBox(
            width: c.size,
            height: c.size,
            child: CustomPaint(painter: _MiniTennisBallPainter()),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildClayParticles(double centerX) {
    final rng = Random(42);
    return List.generate(10, (i) {
      final x = centerX - 100 + rng.nextDouble() * 200;
      final baseY = 340.0 + rng.nextDouble() * 14;
      return Positioned(
        left: x,
        top: baseY,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 600 + rng.nextInt(400)),
          builder: (context, v, _) {
            return Opacity(
              opacity: (1 - v) * 0.5,
              child: Transform.translate(
                offset: Offset(sin(v * 2) * 10, -v * 14),
                child: Container(
                  width: 2.5 + rng.nextDouble() * 3,
                  height: 2.5 + rng.nextDouble() * 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD67B66).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
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
// GRAND SLAM DOTS — 4 tiny court-color indicators
// ═══════════════════════════════════════════════
class _GrandSlamDots extends StatelessWidget {
  final GrandSlam selected;
  final void Function(GrandSlam) onSelect;

  const _GrandSlamDots({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: GrandSlam.values.map((gs) {
        final active = gs == selected;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GestureDetector(
            onTap: () => onSelect(gs),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: active ? 28 : 18,
              height: active ? 28 : 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active
                    ? gs.courtColor
                    : const Color(0xFFBAACEB).withValues(alpha: 0.35),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: gs.courtColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════
// COURT LINE PAINTER — hand-drawn court lines on the mat
// ═══════════════════════════════════════════════
class _CourtLinePainter extends CustomPainter {
  final Color courtColor;
  final Color lineColor;

  _CourtLinePainter({required this.courtColor, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Centre service line (vertical)
    canvas.drawLine(
      Offset(size.width / 2, 8),
      Offset(size.width / 2, size.height - 8),
      paint,
    );

    // Net line (horizontal)
    canvas.drawLine(
      Offset(12, size.height / 2),
      Offset(size.width - 12, size.height / 2),
      paint,
    );

    // Outer border rounded rect
    final borderPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, 4, size.width - 16, size.height - 8),
        const Radius.circular(12),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CourtLinePainter old) =>
      courtColor != old.courtColor || lineColor != old.lineColor;
}

// ═══════════════════════════════════════════════
// STRAWBERRY BUBBLE — Wimbledon easter egg
// ═══════════════════════════════════════════════
class _StrawberryBubble extends StatelessWidget {
  final double runT;
  const _StrawberryBubble({required this.runT});

  @override
  Widget build(BuildContext context) {
    final bob = sin(runT * 3 * pi) * 3.0;

    return Transform.translate(
      offset: Offset(0, bob),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.coralRed.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🍓', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            Text(
              'Strawberries & Cream!',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: AppColors.coralRed.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
class _UserIconButton extends StatelessWidget {
  final bool isLoggedIn;
  final String username;
  final bool isDouyinBound;
  final String? avatarUrl;
  final bool isZh;

  const _UserIconButton({
    required this.isLoggedIn,
    required this.username,
    required this.isDouyinBound,
    required this.avatarUrl,
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
              if (avatarUrl != null && avatarUrl!.isNotEmpty)
                ClipOval(
                  child: Image.network(
                    avatarUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Text('🎾', style: TextStyle(fontSize: 40)),
                  ),
                )
              else
                const Text('🎾', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              if (isDouyinBound)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '🎵 抖音认证',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.yellowGreen,
                    ),
                  ),
                ),
              if (isDouyinBound) const SizedBox(height: 8),
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
      child: SizedBox(
        width: 48,
        height: 48,
        child: isDouyinBound && avatarUrl != null && avatarUrl!.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: ClipOval(
                  child: Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person_rounded,
                      size: 22,
                      color: AppColors.ultraViolet,
                    ),
                  ),
                ),
              )
            : const Icon(
                Icons.person_rounded,
                size: 22,
                color: AppColors.ultraViolet,
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
