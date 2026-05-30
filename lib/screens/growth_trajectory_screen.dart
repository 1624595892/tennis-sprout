import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/practice_log.dart';
import '../providers/practice_provider.dart';
import '../providers/coach_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/time_lock_helper.dart';
import '../widgets/common/paper_background.dart';
import '../widgets/coach_feedback/coach_feedback_widget.dart';

class GrowthTrajectoryScreen extends StatefulWidget {
  const GrowthTrajectoryScreen({super.key});

  @override
  State<GrowthTrajectoryScreen> createState() => _GrowthTrajectoryScreenState();
}

class _GrowthTrajectoryScreenState extends State<GrowthTrajectoryScreen> {
  late DateTime _focusedMonth; // first day of the displayed month

  bool get _isZh {
    try {
      return context.read<LocaleProvider>().locale.languageCode == 'zh';
    } catch (_) {
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  void _onDayTap(DateTime day) {
    final practice = context.read<PracticeProvider>();
    final logs = practice.getLogsForDate(day);

    if (logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isZh ? '这天还没有练习记录 🌱' : 'No practice log on this day 🌱'),
          backgroundColor: AppColors.ultraViolet,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _showHistoryCard(day, logs);
  }

  void _showHistoryCard(DateTime day, List<PracticeLog> logs) {
    final log = logs.first; // primary log for the day
    final editable = TimeLockHelper.isEditable(day);
    final coach = context.read<CoachProvider>();
    final isBound = coach.isBound;
    final hasFeedback = isBound && coach.feedbacks.isNotEmpty;

    final weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    final dateLabel = '${day.year}.${day.month}.${day.day} 周${weekdays[day.weekday - 1]}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          builder: (ctx, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.wisteriaLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(TennisTheme.radiusLG)),
                boxShadow: [
                  BoxShadow(color: AppColors.ultraViolet, blurRadius: 20, offset: Offset(0, -4)),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.ultraViolet.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date header
                  Row(
                    children: [
                      const Text('📅', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(dateLabel, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ultraViolet)),
                      const Spacer(),
                      if (!editable)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.coralRed.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
                          ),
                          child: Text(
                            _isZh ? '已封存' : 'Sealed',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.coralRed),
                          ),
                        ),
                      if (editable)
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.pushNamed(context, '/practice-log', arguments: day);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.yellowGreen,
                              borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
                            ),
                            child: Text(
                              _isZh ? '编辑 ✏️' : 'Edit ✏️',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.pakistanGreen),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Stars
                  _buildStarDisplay(log.starRating),
                  const SizedBox(height: 16),

                  // Subject tags
                  if (log.subjectTags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: log.subjectTags.map((tag) => CapsuleTag(label: tag, selected: true, onTap: null)).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Journal entry
                  if (log.notes.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDFBF7),
                        borderRadius: BorderRadius.circular(TennisTheme.radiusMD),
                        border: Border.all(color: AppColors.wisteria, width: 1.5),
                        boxShadow: [
                          BoxShadow(color: AppColors.ultraViolet.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isZh ? '📝 训练日记' : '📝 Journal',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ultraViolet.withValues(alpha: 0.5)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            log.notes,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ultraViolet, height: 1.6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Coach feedback section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(TennisTheme.radiusMD),
                      border: Border.all(color: AppColors.wisteria.withValues(alpha: 0.6)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _isZh ? '🎙️ 教练反馈' : '🎙️ Coach Feedback',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ultraViolet.withValues(alpha: 0.5)),
                        ),
                        const SizedBox(height: 12),
                        if (isBound && hasFeedback)
                          Center(
                            child: CoachFeedbackWidget(
                              coachProvider: coach,
                              logId: log.id,
                            ),
                          )
                        else
                          Center(
                            child: Text(
                              isBound
                                  ? (_isZh ? '教练正在提着球筐赶来的路上... 🏃‍♂️' : 'Coach is on the way with the ball basket... 🏃‍♂️')
                                  : (_isZh ? '暂未绑定教练' : 'No coach bound yet'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600,
                                color: AppColors.ultraViolet.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // View full entry button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushNamed(context, '/practice-log', arguments: day);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ultraViolet,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TennisTheme.radiusFull)),
                      ),
                      child: Text(
                        editable
                            ? (_isZh ? '打开编辑今日手账 ✏️' : 'Open Today\'s Journal ✏️')
                            : (_isZh ? '查看完整成长记录 📖' : 'View Full Record 📖'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
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

  Widget _buildStarDisplay(int stars) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: i < stars
                  ? const RadialGradient(colors: [AppColors.yellowGreenLight, AppColors.yellowGreen])
                  : null,
              color: i < stars ? null : AppColors.wisteria.withValues(alpha: 0.3),
            ),
            child: Center(
              child: Text('🎾', style: TextStyle(fontSize: 16, color: i < stars ? null : AppColors.ultraViolet.withValues(alpha: 0.2))),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.wisteriaLight,
      appBar: AppBar(
        backgroundColor: AppColors.ultraViolet,
        foregroundColor: AppColors.white,
        centerTitle: true,
        title: Text(
          _isZh ? '成长轨迹' : 'Growth Trajectory',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: PaperBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildCalendar(),
            const SizedBox(height: 24),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // CALENDAR
  // ═══════════════════════════════════════════════

  Widget _buildCalendar() {
    final practice = context.watch<PracticeProvider>();
    final today = TimeLockHelper.today;

    // Month navigation
    final monthLabel = '${_focusedMonth.year} 年 ${_focusedMonth.month} 月';

    // Calculate grid
    final firstDayOfMonth = _focusedMonth;
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday; // 1=Mon
    final totalCells = startWeekday - 1 + daysInMonth;
    final totalRows = (totalCells / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(TennisTheme.radiusLG),
        border: Border.all(color: AppColors.wisteria.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.ultraViolet.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Month header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _prevMonth,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.wisteria.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.chevron_left, color: AppColors.ultraViolet),
                ),
              ),
              Text(
                monthLabel,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ultraViolet),
              ),
              GestureDetector(
                onTap: _nextMonth,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.wisteria.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.chevron_right, color: AppColors.ultraViolet),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weekday headers
          Row(
            children: ['一', '二', '三', '四', '五', '六', '日'].map((d) {
              final isWeekend = d == '六' || d == '日';
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isWeekend ? AppColors.coralRed.withValues(alpha: 0.5) : AppColors.ultraViolet.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Hand-drawn separator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: CustomPaint(
              size: const Size(double.infinity, 1),
              painter: _DashedLinePainter(),
            ),
          ),

          // Day grid
          for (int row = 0; row < totalRows; row++)
            Row(
              children: List.generate(7, (col) {
                final cellIndex = row * 7 + col;
                final dayNum = cellIndex - (startWeekday - 1) + 1;

                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 48));
                }

                final dayDate = DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
                final isToday = dayDate == today;
                final hasLog = practice.hasLogOnDate(dayDate);
                final dayKey = TimeLockHelper.dateKey(dayDate);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onDayTap(dayDate),
                    child: Container(
                      height: 48,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.yellowGreen.withValues(alpha: 0.1) : null,
                        borderRadius: BorderRadius.circular(TennisTheme.radiusSM),
                        border: isToday
                            ? Border.all(color: AppColors.yellowGreen.withValues(alpha: 0.5), width: 1.5)
                            : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '$dayNum',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                              color: isToday ? AppColors.pakistanGreen : AppColors.ultraViolet.withValues(alpha: 0.7),
                            ),
                          ),
                          // Sprout stamp
                          if (hasLog)
                            Positioned(
                              bottom: 4, right: 6,
                              child: Container(
                                width: 18, height: 18,
                                decoration: BoxDecoration(
                                  color: AppColors.yellowGreen.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Center(
                                  child: Text('🌱', style: TextStyle(fontSize: 10)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(TennisTheme.radiusMD),
        border: Border.all(color: AppColors.wisteria.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: AppColors.yellowGreen.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(child: Text('🌱', style: TextStyle(fontSize: 12))),
          ),
          const SizedBox(width: 8),
          Text(
            _isZh ? '发芽图章 = 当天有练习记录' : 'Sprout stamp = practice logged',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ultraViolet.withValues(alpha: 0.5)),
          ),
          const SizedBox(width: 20),
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.yellowGreen.withValues(alpha: 0.5), width: 1.5),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _isZh ? '绿框 = 今天' : 'Green border = today',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ultraViolet.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// Dashed-line painter for weekday separator
// ═══════════════════════════════════════════════
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.wisteria.withValues(alpha: 0.4)
      ..strokeWidth = 0.8;
    const dashWidth = 6.0;
    const dashGap = 4.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset((x + dashWidth).clamp(0, size.width), 0), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ═══════════════════════════════════════════════
// Compact capsule tag (used in bottom sheet)
// ═══════════════════════════════════════════════
class CapsuleTag extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const CapsuleTag({super.key, required this.label, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Shorten display label
    final display = label.length > 6 ? '${label.substring(0, 6)}…' : label;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.yellowGreen.withValues(alpha: 0.25) : AppColors.wisteria.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
          border: selected
              ? Border.all(color: AppColors.yellowGreen.withValues(alpha: 0.5), width: 1)
              : null,
        ),
        child: Text(
          display,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.pakistanGreen : AppColors.ultraViolet.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
