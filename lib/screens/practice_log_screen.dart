import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../config/theme.dart';
import '../models/practice_log.dart';
import '../providers/practice_provider.dart';
import '../providers/coach_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/time_lock_helper.dart';
import '../widgets/common/paper_background.dart';
import '../widgets/common/capsule_tag.dart';
import '../widgets/coach_feedback/coach_feedback_widget.dart';

class PracticeLogScreen extends StatefulWidget {
  /// If null, defaults to today.
  final DateTime? initialDate;

  const PracticeLogScreen({super.key, this.initialDate});

  @override
  State<PracticeLogScreen> createState() => _PracticeLogScreenState();
}

class _PracticeLogScreenState extends State<PracticeLogScreen> {
  // ── Date ──
  late DateTime _logDate; // date-only
  late bool _editable;

  // ── Subject tags ──
  static const _subjectOptions = [
    '正手 Forehand', '反手 Backhand', '发球 Serve', '截击 Volley',
    '脚步 Footwork', '体能 Fitness', '战术 Tactics', '比赛 Match',
  ];
  final Set<String> _selectedTags = {};

  // ── Star rating ──
  int _starRating = 3;

  // ── Journal ──
  final _journalController = TextEditingController();

  // ── Video / Photo ──
  PlatformFile? _pickedFile;
  VideoPlayerController? _videoController;
  bool _isVideoPlaying = false;

  // ── Existing log id (for update) ──
  String? _existingLogId;

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
    _logDate = TimeLockHelper.dateOnly(widget.initialDate ?? DateTime.now());
    _editable = TimeLockHelper.isEditable(_logDate);
    _loadExistingLog();
  }

  void _loadExistingLog() {
    final practice = context.read<PracticeProvider>();
    final existing = practice.getLogByDate(_logDate);
    if (existing != null) {
      _existingLogId = existing.id;
      _selectedTags.addAll(existing.subjectTags);
      _starRating = existing.starRating;
      _journalController.text = existing.notes;
    }
  }

  @override
  void dispose() {
    _journalController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  bool get _isVideoFile {
    if (_pickedFile == null) return false;
    final ext = _pickedFile!.extension?.toLowerCase() ?? '';
    return ext == 'mp4' || ext == 'mov' || ext == 'avi' || ext == 'mkv';
  }

  bool get _isImageFile {
    if (_pickedFile == null) return false;
    final ext = _pickedFile!.extension?.toLowerCase() ?? '';
    return ext == 'png' || ext == 'jpg' || ext == 'jpeg' || ext == 'heic' || ext == 'webp';
  }

  Future<void> _pickMedia() async {
    if (!_editable) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'avi', 'mkv', 'png', 'jpg', 'jpeg', 'heic', 'webp'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    _videoController?.dispose();
    final file = result.files.first;

    setState(() {
      _pickedFile = file;
      _isVideoPlaying = false;
    });

    if (_isVideoFile && file.path != null && !kIsWeb) {
      final controller = VideoPlayerController.file(File(file.path!));
      _videoController = controller;
      await controller.initialize();
      setState(() {});
    } else {
      _videoController = null;
    }
  }

  void _clearMedia() {
    if (!_editable) return;
    _videoController?.dispose();
    setState(() {
      _pickedFile = null;
      _videoController = null;
      _isVideoPlaying = false;
    });
  }

  void _toggleVideoPlayback() {
    if (_videoController == null) return;
    if (_videoController!.value.isPlaying) {
      _videoController!.pause();
      setState(() => _isVideoPlaying = false);
    } else {
      _videoController!.play();
      setState(() => _isVideoPlaying = true);
    }
  }

  void _submitLog() {
    if (!_editable) return;
    final practice = context.read<PracticeProvider>();

    final log = PracticeLog(
      id: _existingLogId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      drillType: _selectedTags.isEmpty ? (_isZh ? '综合训练' : 'General') : _selectedTags.first,
      durationMinutes: 60,
      selfRating: _starRating * 2.0,
      notes: _journalController.text.trim(),
      videoPath: _isVideoFile ? _pickedFile?.path : null,
      imagePath: _isImageFile ? _pickedFile?.path : null,
      date: _logDate,
      subjectTags: _selectedTags.toList(),
      starRating: _starRating,
      isReviewedByCoach: false,
    );

    final ok = practice.saveLogForDate(log);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isZh ? '⏳ 该日期已锁定，无法修改' : 'This date is locked'),
          backgroundColor: AppColors.coralRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isZh ? '🌱 练习日志已保存！' : 'Practice log saved!'),
        backgroundColor: AppColors.yellowGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (_existingLogId == null) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    final d = _logDate;
    final dateStr = '${d.year}.${d.month}.${d.day} 周${weekdays[d.weekday - 1]}';

    return Scaffold(
      backgroundColor: AppColors.wisteriaLight,
      appBar: AppBar(
        backgroundColor: AppColors.ultraViolet,
        foregroundColor: AppColors.white,
        centerTitle: true,
        title: Text(
          _isZh ? '练习日志' : 'Practice Log',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          if (_editable)
            TextButton(
              onPressed: _submitLog,
              child: Text(
                _isZh ? '保存今日手账 ✏️' : 'Save Journal ✏️',
                style: const TextStyle(
                  color: AppColors.yellowGreen,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          if (!_editable)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  '🌱 该页已封存并记入成长轨迹',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: PaperBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            _buildDateHeader(dateStr),
            const SizedBox(height: 12),
            _buildTodayStatus(),
            const SizedBox(height: 24),
            _buildVideoModule(),
            const SizedBox(height: 24),
            _buildSelfEvalModule(),
            const SizedBox(height: 24),
            _buildCoachFeedbackModule(),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════

  String get _todayKey => TimeLockHelper.dateKey(DateTime.now());

  Widget _buildDateHeader(String dateStr) {
    return Row(
      children: [
        const Text('📅', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Text(
          dateStr,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.ultraViolet,
          ),
        ),
        if (!_editable) ...[
          const SizedBox(width: 10),
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
        ],
      ],
    );
  }

  Widget _buildTodayStatus() {
    final practice = context.watch<PracticeProvider>();
    final todayLogs = practice.getLogsForDate(_logDate);
    final count = todayLogs.length;
    final tags = todayLogs.expand((l) => l.subjectTags).toSet();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(TennisTheme.radiusMD),
        border: Border.all(color: AppColors.wisteria.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: count > 0
                  ? AppColors.yellowGreen.withValues(alpha: 0.2)
                  : AppColors.wisteria.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800,
                  color: count > 0 ? AppColors.pakistanGreen : AppColors.ultraViolet.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count > 0
                      ? (_isZh ? '当日已记录 $count 条练习' : '$count practice log(s)')
                      : (_isZh ? '当日还未记录练习 🌱' : 'No practice logged 🌱'),
                  style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: count > 0 ? AppColors.ultraViolet : AppColors.ultraViolet.withValues(alpha: 0.45),
                  ),
                ),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6, runSpacing: 4,
                    children: tags.map((tag) {
                      final short = tag.length > 6 ? '${tag.substring(0, 6)}…' : tag;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.yellowGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
                        ),
                        child: Text(short, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.pakistanGreen)),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          if (count > 0)
            Icon(Icons.check_circle_rounded, size: 22, color: AppColors.yellowGreen.withValues(alpha: 0.6)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // MODULE 1 — Video / Photo Upload
  // ═══════════════════════════════════════════════

  Widget _buildVideoModule() {
    return _ModuleCard(
      icon: Icons.videocam_rounded,
      title: _isZh ? '训练视频 / 照片' : 'Training Video / Photo',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_pickedFile == null)
            _buildVideoPicker()
          else
            _buildVideoPreview(),
        ],
      ),
    );
  }

  Widget _buildVideoPicker() {
    return GestureDetector(
      onTap: _editable ? _pickMedia : null,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.wisteria.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(TennisTheme.radiusMD),
          border: Border.all(
            color: AppColors.ultraViolet.withValues(alpha: _editable ? 0.2 : 0.08),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _editable ? Icons.cloud_upload_outlined : Icons.lock_outline,
              size: 40,
              color: AppColors.ultraViolet.withValues(alpha: _editable ? 0.4 : 0.2),
            ),
            const SizedBox(height: 10),
            Text(
              _editable
                  ? (_isZh ? '点击上传训练视频/照片' : 'Tap to upload video / photo')
                  : (_isZh ? '该日期已锁定，不可上传' : 'Date locked, upload disabled'),
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: AppColors.ultraViolet.withValues(alpha: _editable ? 0.5 : 0.25),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isZh ? '支持 MP4 / MOV / PNG / JPG' : 'Supports MP4 / MOV / PNG / JPG',
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: AppColors.ultraViolet.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    final hasController = _videoController != null && _videoController!.value.isInitialized;
    final fileName = _pickedFile!.name;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(TennisTheme.radiusMD),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_isImageFile)
                _buildImagePreview()
              else if (hasController)
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                )
              else
                _buildFilePlaceholder(fileName),
              // Play button overlay for video
              if (hasController && _isVideoFile)
                GestureDetector(
                  onTap: _toggleVideoPlayback,
                  child: Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.yellowGreen.withValues(alpha: 0.85),
                    ),
                    child: Icon(
                      _isVideoPlaying ? Icons.pause : Icons.play_arrow_rounded,
                      size: 32, color: AppColors.pakistanGreen,
                    ),
                  ),
                ),
              // Delete sticker — only when editable
              if (_editable)
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: _clearMedia,
                    child: Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.coralRed.withValues(alpha: 0.85),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.coralRed.withValues(alpha: 0.3),
                            blurRadius: 6, offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.close, size: 16, color: AppColors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                fileName, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ultraViolet.withValues(alpha: 0.5)),
              ),
            ),
            if (_editable)
              GestureDetector(
                onTap: _pickMedia,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.wisteria,
                    borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
                  ),
                  child: Text(
                    _isZh ? '更换' : 'Change',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ultraViolet),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    if (_pickedFile!.bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(TennisTheme.radiusMD),
        child: Image.memory(_pickedFile!.bytes!, fit: BoxFit.cover, width: double.infinity, height: 220),
      );
    }
    if (!kIsWeb && _pickedFile!.path != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(TennisTheme.radiusMD),
        child: Image.file(File(_pickedFile!.path!), fit: BoxFit.cover, width: double.infinity, height: 220),
      );
    }
    return _buildFilePlaceholder(_pickedFile!.name);
  }

  Widget _buildFilePlaceholder(String fileName) {
    return Container(
      height: 180, color: const Color(0xFF3A3A3C),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.movie, size: 48, color: AppColors.grey400),
            const SizedBox(height: 8),
            Text(fileName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.grey400)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // MODULE 2 — Self-Evaluation
  // ═══════════════════════════════════════════════

  Widget _buildSelfEvalModule() {
    return _ModuleCard(
      icon: Icons.auto_awesome,
      title: _isZh ? '自我评估' : 'Self Evaluation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(_isZh ? '训练科目' : 'Drill Subjects'),
          const SizedBox(height: 8),
          _buildSubjectTags(),
          const SizedBox(height: 20),
          _buildSectionLabel(_isZh ? '自我评分' : 'Self Rating'),
          const SizedBox(height: 8),
          _buildStarRating(),
          const SizedBox(height: 20),
          _buildSectionLabel(_isZh ? '训练日记' : 'Journal'),
          const SizedBox(height: 8),
          _buildJournalBox(),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ultraViolet.withValues(alpha: 0.5), letterSpacing: 0.5),
    );
  }

  Widget _buildSubjectTags() {
    return IgnorePointer(
      ignoring: !_editable,
      child: Opacity(
        opacity: _editable ? 1.0 : 0.55,
        child: Wrap(
          spacing: 8, runSpacing: 8,
          children: _subjectOptions.map((tag) {
            final selected = _selectedTags.contains(tag);
            return CapsuleTag(
              label: tag,
              selected: selected,
              onTap: _editable
                  ? () {
                      setState(() {
                        if (selected) { _selectedTags.remove(tag); } else { _selectedTags.add(tag); }
                      });
                    }
                  : null,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStarRating() {
    return IgnorePointer(
      ignoring: !_editable,
      child: Opacity(
        opacity: _editable ? 1.0 : 0.55,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            final filled = i < _starRating;
            return GestureDetector(
              onTap: _editable ? () => setState(() => _starRating = i + 1) : null,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: filled
                        ? const RadialGradient(colors: [AppColors.yellowGreenLight, AppColors.yellowGreen])
                        : null,
                    color: filled ? null : AppColors.wisteria.withValues(alpha: 0.5),
                    boxShadow: filled
                        ? [BoxShadow(color: AppColors.yellowGreen.withValues(alpha: 0.35), blurRadius: 6, offset: const Offset(0, 2))]
                        : null,
                  ),
                  child: Center(
                    child: Text('🎾', style: TextStyle(fontSize: 18, color: filled ? null : AppColors.ultraViolet.withValues(alpha: 0.25))),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildJournalBox() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: _editable ? const Color(0xFFFDFBF7) : AppColors.wisteriaLight,
        borderRadius: BorderRadius.circular(TennisTheme.radiusMD),
        border: Border.all(color: AppColors.wisteria, width: 1.5),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _LinedPaperPainter()),
          ),
          TextField(
            controller: _journalController,
            readOnly: !_editable,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: _editable ? AppColors.ultraViolet : AppColors.ultraViolet.withValues(alpha: 0.45),
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText: _editable
                  ? (_isZh ? '记录今天的训练感受...' : 'How did today\'s session feel?')
                  : (_isZh ? '此页已封存...' : 'This page is sealed...'),
              hintStyle: TextStyle(fontSize: 13, color: AppColors.ultraViolet.withValues(alpha: 0.3)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // MODULE 3 — Coach Feedback (centered)
  // ═══════════════════════════════════════════════

  Widget _buildCoachFeedbackModule() {
    final coach = context.watch<CoachProvider>();
    final isBound = coach.isBound;
    final hasFeedback = isBound && coach.feedbacks.isNotEmpty;

    return _ModuleCard(
      icon: Icons.headset_mic,
      title: _isZh ? '教练反馈' : 'Coach Feedback',
      accentColor: AppColors.ultraViolet,
      child: isBound && hasFeedback
          ? Center(
              child: CoachFeedbackWidget(
                coachProvider: coach,
                logId: null,
              ),
            )
          : _buildUnreviewedPlaceholder(isBound),
    );
  }

  Widget _buildUnreviewedPlaceholder(bool isBound) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isBound ? Icons.hourglass_empty : Icons.person_add_alt,
              size: 36,
              color: AppColors.ultraViolet.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 10),
            Text(
              isBound
                  ? (_isZh ? '教练正在提着球筐赶来的路上... 🏃‍♂️' : 'Coach is on the way with the ball basket... 🏃‍♂️')
                  : (_isZh ? '绑定教练后即可获得专属反馈' : 'Bind a coach to receive personalized feedback'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: AppColors.ultraViolet.withValues(alpha: 0.45),
              ),
            ),
            if (!isBound) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/coach-binding'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.yellowGreen,
                    borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
                  ),
                  child: Text(
                    _isZh ? '绑定教练' : 'Bind Coach',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.pakistanGreen),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// Shared module card wrapper
// ═══════════════════════════════════════════════
class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Color? accentColor;

  const _ModuleCard({required this.icon, required this.title, required this.child, this.accentColor});

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.ultraViolet;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(TennisTheme.radiusLG),
        border: Border.all(color: AppColors.wisteria.withValues(alpha: 0.6), width: 1),
        boxShadow: [
          BoxShadow(color: AppColors.ultraViolet.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: accent),
              ),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: accent)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// Lined-paper painter
// ═══════════════════════════════════════════════
class _LinedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.wisteria.withValues(alpha: 0.25)
      ..strokeWidth = 0.8;
    const lineHeight = 22.4;
    var y = lineHeight;
    while (y < size.height) {
      canvas.drawLine(Offset(12, y), Offset(size.width - 12, y), linePaint);
      y += lineHeight;
    }
    final marginPaint = Paint()
      ..color = AppColors.coralRed.withValues(alpha: 0.18)
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(28, 0), Offset(28, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
