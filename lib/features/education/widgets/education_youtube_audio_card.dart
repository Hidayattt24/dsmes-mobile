import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Card audio player khusus untuk materi audio yang di-host di YouTube.
/// Menampilkan antarmuka pemutar audio bersih (tanpa kotak video hitam).
class EducationYoutubeAudioCard extends StatefulWidget {
  const EducationYoutubeAudioCard({
    super.key,
    required this.videoUrl,
    required this.title,
    this.isListened = false,
    this.onAudioProgress,
    this.onAudioEnded,
  });

  final String videoUrl;
  final String title;
  final bool isListened;
  final void Function(int listenDuration, int lastPosition)? onAudioProgress;
  final VoidCallback? onAudioEnded;

  @override
  State<EducationYoutubeAudioCard> createState() => _EducationYoutubeAudioCardState();
}

class _EducationYoutubeAudioCardState extends State<EducationYoutubeAudioCard> {
  YoutubePlayerController? _controller;
  String? _fetchedTitle;

  bool _isInit = false;
  bool _hasError = false;
  bool _isCompletedManual = false;
  bool _completionTriggered = false;
  bool _isSavingCompletion = false;

  double _playbackSpeed = 1.0;
  Timer? _telemetryTimer;

  @override
  void initState() {
    super.initState();
    _isCompletedManual = widget.isListened;
    _initializePlayer();
  }

  @override
  void didUpdateWidget(EducationYoutubeAudioCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListened != oldWidget.isListened) {
      setState(() => _isCompletedManual = widget.isListened);
    }
    if (widget.videoUrl != oldWidget.videoUrl) {
      _initializePlayer();
    }
  }

  void _initializePlayer() {
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId == null || videoId.isEmpty) {
      setState(() => _hasError = true);
      return;
    }

    _fetchOEmbedTitle(videoId);

    _controller?.dispose();
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        hideControls: true,
        controlsVisibleAtStart: false,
        enableCaption: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
      ),
    );

    _controller!.addListener(_onPlayerStateChanged);
  }

  Future<void> _fetchOEmbedTitle(String videoId) async {
    try {
      final dio = Dio();
      final res = await dio.get(
        'https://www.youtube.com/oembed',
        queryParameters: {
          'url': 'https://www.youtube.com/watch?v=$videoId',
          'format': 'json',
        },
      );
      if (res.statusCode == 200 && res.data != null && mounted) {
        final title = res.data['title'] as String?;
        if (title != null && title.trim().isNotEmpty) {
          setState(() => _fetchedTitle = title.trim());
        }
      }
    } catch (_) {
      // Keep silent fallback
    }
  }

  void _onPlayerStateChanged() {
    final controller = _controller;
    if (controller == null || !mounted) return;

    final value = controller.value;
    if (value.isReady && !_isInit) {
      setState(() {
        _isInit = true;
        _hasError = false;
      });
    }

    if (value.hasError && !_hasError) {
      setState(() => _hasError = true);
    }

    if (value.isPlaying) {
      _startTelemetryTimer();
    } else {
      _stopTelemetryTimer();
    }

    // Auto mark completion if reached end
    if (value.playerState == PlayerState.ended) {
      _onPlaybackFinished();
    }
  }

  void _startTelemetryTimer() {
    _telemetryTimer?.cancel();
    _telemetryTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final controller = _controller;
      if (!mounted || controller == null || !controller.value.isPlaying) return;

      final currentPos = controller.value.position.inSeconds;
      widget.onAudioProgress?.call(5, currentPos);

      final totalSec = controller.value.metaData.duration.inSeconds;
      if (totalSec > 0 &&
          currentPos >= (totalSec * 0.8) &&
          !_completionTriggered) {
        _completionTriggered = true;
        _saveCompletion(showFeedback: false);
      }
    });
  }

  void _stopTelemetryTimer() {
    _telemetryTimer?.cancel();
    _telemetryTimer = null;
  }

  void _onPlaybackFinished() {
    final controller = _controller;
    if (controller == null) return;

    final dur = controller.value.metaData.duration;
    if (dur <= Duration.zero) return;

    if (!_completionTriggered) {
      _completionTriggered = true;
      _saveCompletion(showFeedback: false);
    }
  }

  Future<void> _saveCompletion({required bool showFeedback}) async {
    if (_isSavingCompletion) return;

    setState(() => _isSavingCompletion = true);

    try {
      widget.onAudioEnded?.call();
      if (!mounted) return;
      setState(() {
        _isSavingCompletion = false;
        _isCompletedManual = true;
      });
      if (showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Audio edukasi berhasil ditandai selesai didengarkan! 🎉',
            ),
            backgroundColor: Color(0xFF16A34A),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSavingCompletion = false);
      }
    }
  }

  void _togglePlayPause() {
    final controller = _controller;
    if (controller == null) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      if (controller.value.playerState == PlayerState.ended) {
        controller.seekTo(Duration.zero);
      }
      controller.play();
    }
  }

  void _seekBy(int seconds) {
    final controller = _controller;
    if (controller == null) return;

    final cur = controller.value.position;
    final max = controller.value.metaData.duration;
    final target = cur + Duration(seconds: seconds);
    if (target < Duration.zero) {
      controller.seekTo(Duration.zero);
    } else if (max > Duration.zero && target > max) {
      controller.seekTo(max);
    } else {
      controller.seekTo(target);
    }
  }

  void _toggleSpeed() {
    final controller = _controller;
    if (controller == null) return;

    final speeds = [1.0, 1.25, 1.5, 2.0];
    final nextIdx = (speeds.indexOf(_playbackSpeed) + 1) % speeds.length;
    final nextSpeed = speeds[nextIdx];
    controller.setPlaybackRate(nextSpeed);
    setState(() => _playbackSpeed = nextSpeed);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _playbackStatus(YoutubePlayerValue value) {
    if (!value.isReady) {
      return 'Memuat audio...';
    }
    if (value.playerState == PlayerState.buffering) {
      return 'Menyiapkan audio...';
    }
    if (value.playerState == PlayerState.ended) {
      return 'Selesai diputar';
    }
    return value.isPlaying ? 'Sedang diputar' : 'Siap diputar';
  }

  @override
  void dispose() {
    _stopTelemetryTimer();
    _controller?.removeListener(_onPlayerStateChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || _controller == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Gagal memuat audio YouTube materi edukasi.',
                style: AppTextStyles.bodySm.copyWith(
                  color: const Color(0xFFB91C1C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final displayTitle = _fetchedTitle ??
        (widget.title.trim().isNotEmpty ? widget.title : 'Audio Edukasi');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hidden YouTube Player (Invisible to eye, active in tree) ──
          SizedBox(
            width: 1,
            height: 1,
            child: Opacity(
              opacity: 0.01,
              child: YoutubePlayer(
                controller: _controller!,
                showVideoProgressIndicator: false,
              ),
            ),
          ),

          // ── Header Row: Badge & Status ─────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.headphones_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 5),
                    Text(
                      'AUDIO EDUKASI',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isListened || _isCompletedManual)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF166534)),
                      const SizedBox(width: 4),
                      Text(
                        'Didengarkan',
                        style: AppTextStyles.labelSm.copyWith(
                          color: const Color(0xFF166534),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Title ──────────────────────────────────────────────────
          Text(
            displayTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleMd.copyWith(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 4),

          // ── Subtitle Status ────────────────────────────────────────
          ValueListenableBuilder<YoutubePlayerValue>(
            valueListenable: _controller!,
            builder: (context, value, child) {
              return Text(
                _playbackStatus(value),
                style: AppTextStyles.bodySm.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          // ── Slider & Duration ──────────────────────────────────────
          ValueListenableBuilder<YoutubePlayerValue>(
            valueListenable: _controller!,
            builder: (context, value, child) {
              final position = value.position;
              final duration = value.metaData.duration;
              final maxSec = duration.inSeconds.toDouble();
              final posSec = position.inSeconds.toDouble().clamp(0.0, maxSec > 0 ? maxSec : 1.0);

              return Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: const Color(0xFFE2E8F0),
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withValues(alpha: 0.15),
                    ),
                    child: Slider(
                      value: maxSec > 0 ? posSec : 0.0,
                      max: maxSec > 0 ? maxSec : 1.0,
                      onChanged: (val) {
                        _controller?.seekTo(Duration(seconds: val.toInt()));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style: AppTextStyles.bodySm.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          duration > Duration.zero ? _formatDuration(duration) : '--:--',
                          style: AppTextStyles.bodySm.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 10),

          // ── Control Buttons Row ────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Speed control
              IconButton(
                onPressed: _toggleSpeed,
                icon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Text(
                    '${_playbackSpeed}x',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
                tooltip: 'Kecepatan putar',
              ),

              const SizedBox(width: 8),

              // Replay 10s
              IconButton(
                onPressed: () => _seekBy(-10),
                icon: const Icon(Icons.replay_10_rounded, color: Color(0xFF475569), size: 28),
                tooltip: 'Mundur 10 detik',
              ),

              const SizedBox(width: 8),

              // Play / Pause Circle Button
              ValueListenableBuilder<YoutubePlayerValue>(
                valueListenable: _controller!,
                builder: (context, value, child) {
                  final isPlaying = value.isPlaying;
                  final isBuffering = !value.isReady || value.playerState == PlayerState.buffering;

                  return GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: isBuffering
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(width: 8),

              // Forward 10s
              IconButton(
                onPressed: () => _seekBy(10),
                icon: const Icon(Icons.forward_10_rounded, color: Color(0xFF475569), size: 28),
                tooltip: 'Maju 10 detik',
              ),

              const SizedBox(width: 8),

              // Stop / Reset
              IconButton(
                onPressed: () {
                  _controller?.pause();
                  _controller?.seekTo(Duration.zero);
                },
                icon: const Icon(Icons.stop_rounded, color: Color(0xFF64748B), size: 24),
                tooltip: 'Stop',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Mark Audio Listened Button ─────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: (widget.isListened || _isCompletedManual)
                    ? const Color(0xFF16A34A)
                    : AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSavingCompletion
                  ? null
                  : () => _saveCompletion(showFeedback: true),
              icon: _isSavingCompletion
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      (widget.isListened || _isCompletedManual)
                          ? Icons.check_circle_rounded
                          : Icons.headphones_rounded,
                      size: 18,
                    ),
              label: Text(
                _isSavingCompletion
                    ? 'Menyimpan...'
                    : (widget.isListened || _isCompletedManual)
                        ? 'Selesai Didengarkan'
                        : 'Tandai Selesai Mendengarkan Audio',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
