import 'dart:typed_data';
import 'dart:ui' show ImageFilter;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/daily_status.dart';
import '../../providers/daily_status_provider.dart';

class DailyCheckInCard extends StatelessWidget {
  final DailyStatusProvider provider;
  final bool isZh;

  const DailyCheckInCard({
    super.key,
    required this.provider,
    required this.isZh,
  });

  @override
  Widget build(BuildContext context) {
    final todayStatus = provider.todayStatus;
    final hasCheckedIn = provider.hasCheckedInToday;
    final streak = provider.streak.currentStreak;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.wb_sunny_rounded,
                size: 22, color: AppColors.yellowGreen),
            const SizedBox(width: 8),
            Text(
              isZh ? '今日状态' : 'Daily Status',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.ultraViolet,
              ),
            ),
            const Spacer(),
            _StreakBadge(streak: streak, isZh: isZh),
          ],
        ),
        const SizedBox(height: 14),

        GestureDetector(
          onTap: hasCheckedIn ? null : () => _showCheckInDialog(context, isZh),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.ultraViolet,
              borderRadius: BorderRadius.circular(TennisTheme.radiusLG),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ultraViolet.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(2, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: hasCheckedIn
                        ? AppColors.yellowGreen.withValues(alpha: 0.10)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(TennisTheme.radiusLG - 1),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: hasCheckedIn
                            ? _CheckedInContent(
                                todayStatus: todayStatus!,
                                isZh: isZh,
                                onTapEmoji: todayStatus.imageBytes != null
                                    ? () => _showImageViewer(
                                          context,
                                          imageBytes: todayStatus.imageBytes!,
                                          mood: todayStatus.mood,
                                          streak: streak,
                                          isZh: isZh,
                                        )
                                    : null,
                              )
                            : _CheckInPrompt(isZh: isZh),
                      ),

                      if (hasCheckedIn)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: _DayStamp(streak: streak, isZh: isZh),
                        ),

                      if (hasCheckedIn && (todayStatus?.isLivePhoto ?? false))
                        Positioned(
                          bottom: 12,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(
                                  TennisTheme.radiusFull),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.play_circle_fill,
                                    size: 14, color: AppColors.yellowGreen),
                                const SizedBox(width: 4),
                                const Text(
                                  'Live Photo',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.yellowGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(TennisTheme.radiusLG - 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        hasCheckedIn
                            ? (isZh ? '已打卡' : 'Checked in')
                            : (isZh ? '点击打卡' : 'Tap to check in'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: hasCheckedIn
                              ? AppColors.yellowGreen
                              : Colors.white,
                        ),
                      ),
                      const Spacer(),
                      if (!hasCheckedIn)
                        const Icon(Icons.add_circle_outline,
                            size: 18, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }

  void _showImageViewer(
    BuildContext context, {
    required Uint8List imageBytes,
    required Mood mood,
    required int streak,
    required bool isZh,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation1, animation2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, a1, a2, widget) {
        final curved = CurvedAnimation(parent: a1, curve: Curves.easeOutBack);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5 * a1.value, sigmaY: 5 * a1.value),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.82, end: 1.0).animate(curved),
            child: FadeTransition(
              opacity: a1,
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    constraints: const BoxConstraints(maxWidth: 360),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDFBF7),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Polaroid photo area ──
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.memory(
                            imageBytes,
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Mood caption ──
                        Text(
                          '${mood.emoji}  ${isZh ? _moodLabelText(mood) : mood.name}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ultraViolet,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ── Day stamp + close ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Hand-drawn style day stamp
                            Transform.rotate(
                              angle: -0.15,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.yellowGreen,
                                  borderRadius: BorderRadius.circular(
                                      TennisTheme.radiusSM),
                                ),
                                child: Text(
                                  'DAY $streak 🌿',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.pakistanGreen,
                                  ),
                                ),
                              ),
                            ),
                            // Close button
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.coralRed
                                      .withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 20,
                                  color: AppColors.coralRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _moodLabelText(Mood mood) {
    return switch (mood) {
      Mood.happy => '超棒',
      Mood.good => '不错',
      Mood.ok => '还行',
      Mood.tired => '累了',
    };
  }

  void _showCheckInDialog(BuildContext context, bool isZh) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _CheckInBottomSheet(
        isZh: isZh,
        onCheckIn: ({String? photoPath, Uint8List? imageBytes, bool isLivePhoto = false, Mood mood = Mood.good}) {
          provider.checkIn(
            photoPath: photoPath,
            imageBytes: imageBytes,
            isLivePhoto: isLivePhoto,
            mood: mood,
          );
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

// ── Streak Badge ──
class _StreakBadge extends StatelessWidget {
  final int streak;
  final bool isZh;

  const _StreakBadge({required this.streak, required this.isZh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.yellowGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
        border: Border.all(
            color: AppColors.yellowGreen.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            isZh ? '连续 $streak 天' : '$streak days',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Checked-in content (mood emoji sticker, tappable to view uploaded photo) ──
class _CheckedInContent extends StatelessWidget {
  final DailyStatus todayStatus;
  final bool isZh;
  final VoidCallback? onTapEmoji;

  const _CheckedInContent({
    required this.todayStatus,
    required this.isZh,
    this.onTapEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = todayStatus.imageBytes != null;

    return GestureDetector(
      onTap: hasPhoto ? onTapEmoji : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mood emoji — the "sticker" shrinking effect when photo exists
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasPhoto
                  ? AppColors.yellowGreen.withValues(alpha: 0.12)
                  : Colors.transparent,
              border: hasPhoto
                  ? Border.all(
                      color: AppColors.yellowGreen.withValues(alpha: 0.45),
                      width: 2,
                    )
                  : null,
            ),
            child: Text(
              todayStatus.mood.emoji,
              style: TextStyle(
                fontSize: hasPhoto ? 42 : 52,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (hasPhoto)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.zoom_in_rounded,
                    size: 16, color: AppColors.yellowGreen),
                const SizedBox(width: 4),
                Text(
                  isZh ? '轻触查看原图' : 'Tap to view photo',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.yellowGreen,
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.yellowGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
              ),
              child: const Text(
                '✓ Checked in',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.yellowGreen,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Check-in prompt — high contrast ──
class _CheckInPrompt extends StatelessWidget {
  final bool isZh;

  const _CheckInPrompt({required this.isZh});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.yellowGreen.withValues(alpha: 0.15),
            border: Border.all(
              color: AppColors.yellowGreen.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.add_a_photo_rounded,
            size: 30,
            color: AppColors.yellowGreen,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          isZh ? '记录今天的网球心情吧 📸' : 'Capture your tennis vibe today 📸',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isZh ? '点此添加今日状态' : 'Tap to add daily status',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.yellowGreen,
          ),
        ),
      ],
    );
  }
}

// ── Day Stamp ──
class _DayStamp extends StatelessWidget {
  final int streak;
  final bool isZh;

  const _DayStamp({required this.streak, required this.isZh});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.yellowGreen,
          borderRadius: BorderRadius.circular(TennisTheme.radiusSM),
          boxShadow: [
            BoxShadow(
              color: AppColors.yellowGreen.withValues(alpha: 0.5),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'DAY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppColors.pakistanGreen.withValues(alpha: 0.7),
                letterSpacing: 2,
              ),
            ),
            Text(
              '$streak',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.pakistanGreen,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mood Strip — high contrast ──
class _MoodStrip extends StatelessWidget {
  final Mood mood;
  final bool isZh;

  const _MoodStrip({required this.mood, required this.isZh});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          isZh ? '今日心情' : 'Today\'s mood',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
          ),
          child: Text(
            '${mood.emoji}  ${mood.name}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Bottom sheet for check-in ──
class _CheckInBottomSheet extends StatefulWidget {
  final bool isZh;
  final Function({String? photoPath, Uint8List? imageBytes, bool isLivePhoto, Mood mood}) onCheckIn;

  const _CheckInBottomSheet({
    required this.isZh,
    required this.onCheckIn,
  });

  @override
  State<_CheckInBottomSheet> createState() => _CheckInBottomSheetState();
}

class _CheckInBottomSheetState extends State<_CheckInBottomSheet> {
  Mood _selectedMood = Mood.good;
  Uint8List? _imageBytes;
  String? _imagePath;
  bool _isPicking = false;

  Future<void> _pickImageAllPlatforms() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.bytes != null && file.bytes!.isNotEmpty) {
          setState(() {
            _imageBytes = file.bytes;
            _imagePath = file.path;
          });
        } else if (kIsWeb) {
          // Web withData failed — bytes was null/empty (possible with very large files).
          // Show a clear hint instead of silent failure.
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.isZh
                    ? '文件过大，请选择小于 10MB 的图片'
                    : 'File too large, pick an image under 10MB'),
              ),
            );
          }
        } else {
          // Native fallback — shouldn't normally happen, but surface it.
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.isZh
                    ? '无法读取图片数据，请重试'
                    : 'Could not read image data, please retry'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isZh
                ? '选图失败，请重试'
                : 'Failed to pick image, please retry'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.wisteriaLight, AppColors.wisteria],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TennisTheme.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.wisteria.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            widget.isZh ? '今日打卡' : 'Daily Check-in',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.ultraViolet,
            ),
          ),
          const SizedBox(height: 20),

          // Upload photo area
          GestureDetector(
            onTap: _pickImageAllPlatforms,
            child: Container(
              width: 120,
              height: 120,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.ultraViolet.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(TennisTheme.radiusMD),
                border: Border.all(
                  color: AppColors.yellowGreen.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: _isPicking
                  ? const Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.yellowGreen,
                        ),
                      ),
                    )
                  : _imageBytes != null
                      ? Image.memory(
                          _imageBytes!,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                size: 36,
                                color: AppColors.wisteria.withValues(alpha: 0.6)),
                            const SizedBox(height: 8),
                            Text(
                              widget.isZh ? '上传照片' : 'Add Photo',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.wisteria.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
            ),
          ),

          // Change / remove photo hint
          if (_imageBytes != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () => setState(() {
                  _imageBytes = null;
                  _imagePath = null;
                }),
                child: Text(
                  widget.isZh ? '移除照片' : 'Remove photo',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.coralRed,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Mood selector
          const Text(
            'How are you feeling?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.ultraViolet,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: Mood.values.map((mood) {
              final selected = _selectedMood == mood;
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = mood),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.yellowGreen.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(TennisTheme.radiusFull),
                    border: Border.all(
                      color: selected
                          ? AppColors.yellowGreen
                          : AppColors.wisteria.withValues(alpha: 0.3),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(mood.emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      Text(
                        widget.isZh
                            ? _moodLabelZh(mood)
                            : mood.name[0].toUpperCase() +
                                mood.name.substring(1),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? AppColors.ultraViolet
                              : AppColors.ultraViolet.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onCheckIn(
                mood: _selectedMood,
                imageBytes: _imageBytes,
                photoPath: _imagePath,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellowGreen,
                foregroundColor: AppColors.pakistanGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(TennisTheme.radiusFull),
                ),
              ),
              child: Text(
                widget.isZh ? '确认打卡 ✨' : 'Check In ✨',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _moodLabelZh(Mood mood) {
    return switch (mood) {
      Mood.happy => '超棒',
      Mood.good => '不错',
      Mood.ok => '还行',
      Mood.tired => '累了',
    };
  }
}
