import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_smart_image.dart';

class YouTubePreviewCard extends StatefulWidget {
  const YouTubePreviewCard({
    super.key,
    required this.videoTitle,
    required this.videoDuration,
    required this.channelName,
    required this.imageUrl,
    this.videoUrl,
    this.isWatched = false,
    this.onWatchProgress,
    this.onVideoEnded,
  });

  final String videoTitle;
  final String videoDuration;
  final String channelName;
  final String imageUrl;
  final String? videoUrl;
  final bool isWatched;

  /// Called while video is playing.
  /// [watchedSeconds] = total seconds watched, [lastTimestamp] = current position in seconds.
  final void Function(int watchedSeconds, int lastTimestamp)? onWatchProgress;

  /// Called when the video finishes playing.
  final VoidCallback? onVideoEnded;

  @override
  State<YouTubePreviewCard> createState() => _YouTubePreviewCardState();
}

class _YouTubePreviewCardState extends State<YouTubePreviewCard> {
  YoutubePlayerController? _controller;
  String? _extractedVideoId;
  int _watchedSeconds = 0;
  Timer? _watchTimer;
  bool _isWatchedManual = false;
  String? _fetchedTitle;
  String? _fetchedAuthor;

  @override
  void initState() {
    super.initState();
    _isWatchedManual = widget.isWatched;
    _initPlayer();
  }

  @override
  void didUpdateWidget(YouTubePreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isWatched != oldWidget.isWatched) {
      setState(() {
        _isWatchedManual = widget.isWatched;
      });
    }
  }

  void _initPlayer() {
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _extractedVideoId = YoutubePlayer.convertUrlToId(widget.videoUrl!);
    }

    if (_extractedVideoId != null && _extractedVideoId!.isNotEmpty) {
      _fetchYoutubeMetadata();
      _controller = YoutubePlayerController(
        initialVideoId: _extractedVideoId!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          showLiveFullscreenButton: false,
        ),
      )..addListener(_videoListener);
    }
  }

  Future<void> _fetchYoutubeMetadata() async {
    if (_extractedVideoId == null || _extractedVideoId!.isEmpty) return;
    try {
      final response = await Dio().get(
        'https://www.youtube.com/oembed',
        queryParameters: {
          'url': 'https://www.youtube.com/watch?v=$_extractedVideoId',
          'format': 'json',
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (mounted) {
          setState(() {
            _fetchedTitle = data['title'] as String?;
            _fetchedAuthor = data['author_name'] as String?;
          });
        }
      }
    } catch (_) {
      // Fallback silently if offline
    }
  }

  void _videoListener() {
    if (_controller == null) return;
    final state = _controller!.value.playerState;

    if (state == PlayerState.playing) {
      _startWatchTimer();
    } else {
      _stopWatchTimer();
    }

    if (state == PlayerState.ended) {
      widget.onVideoEnded?.call();
    }
  }

  void _startWatchTimer() {
    if (_watchTimer != null && _watchTimer!.isActive) return;
    _watchTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _controller == null) return;
      _watchedSeconds += 5;
      final currentPos = _controller!.value.position.inSeconds;
      widget.onWatchProgress?.call(_watchedSeconds, currentPos);
    });
  }

  void _stopWatchTimer() {
    _watchTimer?.cancel();
    _watchTimer = null;
  }

  @override
  void dispose() {
    _stopWatchTimer();
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  String get _thumbnailUrl {
    if (widget.imageUrl.trim().isNotEmpty) {
      return widget.imageUrl;
    }
    if (_extractedVideoId != null && _extractedVideoId!.isNotEmpty) {
      return 'https://img.youtube.com/vi/$_extractedVideoId/hqdefault.jpg';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _extractedVideoId == null) {
      return _buildCardContent(_buildFallbackThumbnail());
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
      ),
      builder: (context, player) {
        return _buildCardContent(player);
      },
    );
  }

  Widget _buildCardContent(Widget mediaWidget) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.black,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: mediaWidget,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.surfaceContainerLowest,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF0000),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'YOUTUBE',
                          style: AppTextStyles.labelMd.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fetchedTitle ?? (widget.videoTitle.trim().isNotEmpty ? widget.videoTitle : 'Video Edukasi DSMES'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.headlineMd.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          _fetchedAuthor ?? (widget.channelName.trim().isNotEmpty ? widget.channelName : 'DSMES Official'),
                          style: AppTextStyles.bodyMd.copyWith(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Button to mark video watched explicitly (Uses AppColors design system tokens)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isWatchedManual
                        ? AppColors.secondaryContainer
                        : AppColors.primaryContainer,
                    foregroundColor: _isWatchedManual
                        ? AppColors.onSecondaryContainer
                        : Colors.white,
                    disabledBackgroundColor: AppColors.secondaryContainer,
                    disabledForegroundColor: AppColors.onSecondaryContainer,
                    elevation: _isWatchedManual ? 0 : 2,
                    shadowColor: AppColors.primaryContainer.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isWatchedManual
                      ? null
                      : () {
                          setState(() {
                            _isWatchedManual = true;
                          });
                          widget.onVideoEnded?.call();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Video edukasi berhasil ditandai selesai menonton! 🎉'),
                              backgroundColor: AppColors.primaryContainer,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                  icon: Icon(
                    _isWatchedManual
                        ? Icons.check_circle_rounded
                        : Icons.play_circle_fill_rounded,
                    size: 20,
                    color: _isWatchedManual
                        ? AppColors.onSecondaryContainer
                        : Colors.white,
                  ),
                  label: Text(
                    _isWatchedManual
                        ? 'Sudah Selesai Menonton Video ✓'
                        : 'Tandai Selesai Menonton Video',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _isWatchedManual
                          ? AppColors.onSecondaryContainer
                          : Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackThumbnail() {
    return Stack(
      children: [
        Positioned.fill(
          child: AppSmartImage(
            imageUrl: _thumbnailUrl,
            fit: BoxFit.cover,
            fallbackIcon: Icons.play_circle_fill_rounded,
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ),
        const Center(
          child: Icon(
            Icons.play_circle_fill_rounded,
            color: Colors.white70,
            size: 56,
          ),
        ),
      ],
    );
  }
}
