import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_smart_image.dart';

/// Enhanced YouTube player card with:
/// • Auto-hide overlay controls (play/pause, seek ±10s)
/// • Minimize button to trigger parent's mini-player
/// • Shared-controller support via [externalController] + [onControllerReady]
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
    this.externalController,
    this.onControllerReady,
    this.onMinimize,
  });

  final String videoTitle;
  final String videoDuration;
  final String channelName;
  final String imageUrl;
  final String? videoUrl;
  final bool isWatched;

  /// Called periodically while video is playing.
  /// [watchedSeconds] = cumulative seconds watched, [lastTimestamp] = current position.
  final void Function(int watchedSeconds, int lastTimestamp)? onWatchProgress;

  /// Called when the video finishes (ended state) or user marks watched manually.
  final VoidCallback? onVideoEnded;

  /// If provided, this controller is used instead of creating a new one.
  /// The parent is responsible for disposing it.
  final YoutubePlayerController? externalController;

  /// Called once the internal controller is ready, so the parent can store
  /// a reference for the mini-player.
  final void Function(YoutubePlayerController controller)? onControllerReady;

  /// Called when the user taps the minimize (⬇) button.
  final VoidCallback? onMinimize;

  @override
  State<YouTubePreviewCard> createState() => _YouTubePreviewCardState();
}

class _YouTubePreviewCardState extends State<YouTubePreviewCard>
    with SingleTickerProviderStateMixin {
  // ── Player ────────────────────────────────────────────────────────────────
  YoutubePlayerController? _controller;
  bool get _ownsController => widget.externalController == null;
  String? _extractedVideoId;

  // ── Watch tracking ────────────────────────────────────────────────────────
  int _watchedSeconds = 0;
  Timer? _watchTimer;
  bool _isWatchedManual = false;

  // ── Metadata ──────────────────────────────────────────────────────────────
  String? _fetchedTitle;
  String? _fetchedAuthor;

  // ── Controls overlay ──────────────────────────────────────────────────────
  bool _showControls = false;
  Timer? _controlsHideTimer;

  // ── Fullscreen ────────────────────────────────────────────────────────────
  bool _isFullscreen = false;

  // ── Entry animation ───────────────────────────────────────────────────────
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  @override
  void initState() {
    super.initState();
    _isWatchedManual = widget.isWatched;

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _initPlayer();
    _entryCtrl.forward();
  }

  @override
  void didUpdateWidget(YouTubePreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isWatched != oldWidget.isWatched) {
      setState(() => _isWatchedManual = widget.isWatched);
    }
  }

  // ── Initialise player ────────────────────────────────────────────────────
  void _initPlayer() {
    if (widget.externalController != null) {
      _controller = widget.externalController;
      _extractedVideoId =
          widget.externalController!.metadata.videoId.isNotEmpty
              ? widget.externalController!.metadata.videoId
              : (widget.videoUrl != null
                  ? YoutubePlayer.convertUrlToId(widget.videoUrl!)
                  : null);
      _controller!.addListener(_videoListener);
      return;
    }

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
          // We handle fullscreen ourselves
          showLiveFullscreenButton: false,
          hideControls: true, // use our custom overlay
        ),
      )..addListener(_videoListener);

      // Notify parent so it can share the controller with mini-player
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller != null) {
          widget.onControllerReady?.call(_controller!);
        }
      });
    }
  }

  // ── Metadata fetch ───────────────────────────────────────────────────────
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
      if (response.statusCode == 200 && response.data != null && mounted) {
        final data = response.data;
        setState(() {
          _fetchedTitle = data['title'] as String?;
          _fetchedAuthor = data['author_name'] as String?;
        });
      }
    } catch (_) {}
  }

  // ── Video listener ───────────────────────────────────────────────────────
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

  // ── Custom controls visibility ───────────────────────────────────────────
  void _onTapPlayer() {
    if (!_showControls) {
      setState(() => _showControls = true);
      _scheduleHideControls();
    } else {
      _togglePlayPause();
      _scheduleHideControls();
    }
  }

  void _scheduleHideControls() {
    _controlsHideTimer?.cancel();
    _controlsHideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    final state = _controller!.value.playerState;
    if (state == PlayerState.playing) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
  }

  void _seekBackward() {
    if (_controller == null) return;
    final pos = _controller!.value.position;
    final target = pos - const Duration(seconds: 10);
    _controller!.seekTo(target < Duration.zero ? Duration.zero : target);
    _scheduleHideControls();
  }

  void _seekForward() {
    if (_controller == null) return;
    final pos = _controller!.value.position;
    _controller!.seekTo(pos + const Duration(seconds: 10));
    _scheduleHideControls();
  }

  // ── Fullscreen ───────────────────────────────────────────────────────────
  Future<void> _enterFullscreen() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (mounted) setState(() => _isFullscreen = true);
  }

  Future<void> _exitFullscreen() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (mounted) setState(() => _isFullscreen = false);
  }

  // ── Dispose ──────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _stopWatchTimer();
    _controlsHideTimer?.cancel();
    _entryCtrl.dispose();

    _controller?.removeListener(_videoListener);
    // Only dispose if we own the controller
    if (_ownsController) {
      _controller?.dispose();
    }

    // Restore orientation / system UI when card leaves the tree
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // ── Thumbnail helper ─────────────────────────────────────────────────────
  String get _thumbnailUrl {
    if (widget.imageUrl.trim().isNotEmpty) return widget.imageUrl;
    if (_extractedVideoId != null && _extractedVideoId!.isNotEmpty) {
      return 'https://img.youtube.com/vi/$_extractedVideoId/hqdefault.jpg';
    }
    return '';
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_controller == null || _extractedVideoId == null) {
      return FadeTransition(
        opacity: _entryFade,
        child: SlideTransition(
          position: _entrySlide,
          child: _buildCardShell(_buildFallbackThumbnail()),
        ),
      );
    }

    return YoutubePlayerBuilder(
      onEnterFullScreen: _enterFullscreen,
      onExitFullScreen: _exitFullscreen,
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
        onReady: () {
          if (mounted) widget.onControllerReady?.call(_controller!);
        },
      ),
      builder: (context, player) {
        return FadeTransition(
          opacity: _entryFade,
          child: SlideTransition(
            position: _entrySlide,
            child:
                _isFullscreen
                    ? _buildFullscreenShell(player)
                    : _buildCardShell(_buildInteractivePlayer(player)),
          ),
        );
      },
    );
  }

  // ── Fullscreen shell ─────────────────────────────────────────────────────
  Widget _buildFullscreenShell(Widget player) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _onTapPlayer,
        child: Stack(
          children: [
            Center(child: player),
            // Controls overlay
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: _buildControlsOverlay(isFullscreen: true),
            ),
          ],
        ),
      ),
    );
  }

  // ── Card shell (normal mode) ─────────────────────────────────────────────
  Widget _buildCardShell(Widget mediaWidget) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Video area ──────────────────────────────────────────────
            Container(
              color: Colors.black,
              child: AspectRatio(aspectRatio: 16 / 9, child: mediaWidget),
            ),

            // ── Info row ────────────────────────────────────────────────
            _buildInfoRow(),

            // ── Action row: Minimize + Fullscreen ───────────────────────
            _buildActionButtonsRow(),

            // ── Watched button ──────────────────────────────────────────
            _buildWatchedButton(),
          ],
        ),
      ),
    );
  }

  // ── Interactive player with gesture overlay ──────────────────────────────
  Widget _buildInteractivePlayer(Widget player) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTapPlayer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          player,
          // Controls overlay (normal mode)
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: _buildControlsOverlay(isFullscreen: false),
          ),
        ],
      ),
    );
  }

  // ── Controls overlay ─────────────────────────────────────────────────────
  Widget _buildControlsOverlay({required bool isFullscreen}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.15),
            Colors.black.withValues(alpha: 0.65),
          ],
        ),
      ),
      child: Stack(
        children: [
          // ── Centre: seek + play/pause ─────────────────────────────────
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ControlButton(
                  icon: Icons.replay_10_rounded,
                  tooltip: 'Mundur 10 detik',
                  onTap: _seekBackward,
                ),
                const SizedBox(width: 24),
                _PlayPauseButton(controller: _controller),
                const SizedBox(width: 24),
                _ControlButton(
                  icon: Icons.forward_10_rounded,
                  tooltip: 'Maju 10 detik',
                  onTap: _seekForward,
                ),
              ],
            ),
          ),

          // ── Top-right: Mini Player ─────────────────────────────────────
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                if (widget.onMinimize != null && !isFullscreen)
                  _ControlButton(
                    icon: Icons.picture_in_picture_alt_rounded,
                    tooltip: 'Mini player',
                    onTap: widget.onMinimize!,
                    size: 18,
                  ),
              ],
            ),
          ),

          // ── Bottom: position + duration ──────────────────────────────
          Positioned(
            left: 12,
            right: 12,
            bottom: 8,
            child: ValueListenableBuilder<YoutubePlayerValue>(
              valueListenable: _controller!,
              builder: (context, value, child) {
                final pos = value.position;
                final dur = value.metaData.duration;
                return Row(
                  children: [
                    Text(
                      _formatDuration(pos),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/ ${_formatDuration(dur)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 11,
                        shadows: const [
                          Shadow(color: Colors.black54, blurRadius: 4),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Info row ─────────────────────────────────────────────────────────────
  Widget _buildInfoRow() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        6,
      ),
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
                const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 12,
                ),
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
                  _fetchedTitle ??
                      (widget.videoTitle.trim().isNotEmpty
                          ? widget.videoTitle
                          : 'Video Edukasi DIBA'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headlineMd.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  _fetchedAuthor ??
                      (widget.channelName.trim().isNotEmpty
                          ? widget.channelName
                          : 'DIBA Official'),
                  style: AppTextStyles.bodyMd.copyWith(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Action buttons row (Mini Player) ─────────────────────────────────────
  Widget _buildActionButtonsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: Row(
        children: [
          // Minimize → mini player
          if (widget.onMinimize != null)
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.onSurfaceVariant,
                  side: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.6),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: widget.onMinimize,
                icon: const Icon(
                  Icons.picture_in_picture_alt_rounded,
                  size: 16,
                ),
                label: const Text(
                  'Mini Player',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (widget.onMinimize != null) const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ── Watched button ───────────────────────────────────────────────────────
  void _replayVideo() {
    final controller = _controller;
    if (controller == null) return;

    controller.seekTo(Duration.zero);
    controller.play();
    setState(() => _showControls = true);
    _scheduleHideControls();
  }

  Widget _buildWatchedButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: ElevatedButton.icon(
            key: ValueKey(_isWatchedManual),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isWatchedManual
                      ? AppColors.primary
                      : AppColors.primaryContainer,
              foregroundColor: Colors.white,
              elevation: _isWatchedManual ? 2 : 2,
              shadowColor: AppColors.primaryContainer.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed:
                _isWatchedManual
                    ? _replayVideo
                    : () {
                      setState(() => _isWatchedManual = true);
                      widget.onVideoEnded?.call();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Video edukasi berhasil ditandai selesai menonton! 🎉',
                          ),
                          backgroundColor: AppColors.primaryContainer,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
            icon: Icon(
              _isWatchedManual
                  ? Icons.replay_rounded
                  : Icons.play_circle_fill_rounded,
              size: 20,
              color: Colors.white,
            ),
            label: Text(
              _isWatchedManual
                  ? 'Tonton Ulang Video'
                  : 'Tandai Selesai Menonton Video',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Fallback thumbnail ───────────────────────────────────────────────────
  Widget _buildFallbackThumbnail() {
    return Stack(
      fit: StackFit.expand,
      children: [
        AppSmartImage(
          imageUrl: _thumbnailUrl,
          fit: BoxFit.cover,
          fallbackIcon: Icons.play_circle_fill_rounded,
        ),
        Container(color: Colors.black.withValues(alpha: 0.3)),
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

  // ── Helpers ──────────────────────────────────────────────────────────────
  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────

/// Circular semi-transparent icon button for the controls overlay.
class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.size = 20,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }
}

/// Animated play / pause button that listens to the controller state.
class _PlayPauseButton extends StatefulWidget {
  const _PlayPauseButton({required this.controller});

  final YoutubePlayerController? controller;

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _iconCtrl;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    widget.controller?.addListener(_onUpdate);
  }

  void _onUpdate() {
    if (!mounted) return;
    final playing = widget.controller?.value.playerState == PlayerState.playing;
    if (playing != _isPlaying) {
      setState(() => _isPlaying = playing);
      playing ? _iconCtrl.forward() : _iconCtrl.reverse();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onUpdate);
    _iconCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    if (widget.controller == null) return;
    if (_isPlaying) {
      widget.controller!.pause();
    } else {
      widget.controller!.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
            ),
          ],
        ),
        child: AnimatedIcon(
          icon: AnimatedIcons.play_pause,
          progress: _iconCtrl,
          color: Colors.black87,
          size: 30,
        ),
      ),
    );
  }
}
