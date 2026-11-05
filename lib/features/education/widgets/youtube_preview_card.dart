import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
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
    this.isShorts = false,
    this.isWatched = false,
    this.isAudioMode = false,
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
  final bool isShorts;
  final bool isWatched;
  final bool isAudioMode;

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

  int _playerErrorCode = 0;

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
          hideControls: false,
          controlsVisibleAtStart: true,
          showLiveFullscreenButton: true,
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
    if (!mounted || _controller == null) return;
    final value = _controller!.value;
    final state = value.playerState;

    if (value.errorCode != _playerErrorCode) {
      setState(() => _playerErrorCode = value.errorCode);
    }

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

  bool get _isShorts =>
      widget.isShorts ||
      (Uri.tryParse(widget.videoUrl ?? '')?.pathSegments.contains('shorts') ??
          false);

  Future<void> _openInYoutube() async {
    final id = _extractedVideoId;
    if (id == null) return;
    final url = Uri.tryParse(widget.videoUrl ?? '');
    final target =
        url != null && url.hasScheme
            ? url
            : Uri.parse('https://www.youtube.com/watch?v=$id');
    await launchUrl(target, mode: LaunchMode.externalApplication);
  }

  // ── Fullscreen ───────────────────────────────────────────────────────────
  Future<void> _enterFullscreen() async {
    await SystemChrome.setPreferredOrientations(
      _isShorts
          ? [DeviceOrientation.portraitUp]
          : [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
    );
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
        aspectRatio: _isShorts ? 9 / 16 : 16 / 9,
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
                    : _buildCardShell(_buildPlayerWithErrorFallback(player)),
          ),
        );
      },
    );
  }

  // ── Fullscreen shell ─────────────────────────────────────────────────────
  Widget _buildFullscreenShell(Widget player) {
    return Scaffold(backgroundColor: Colors.black, body: Center(child: player));
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
              width: double.infinity,
              constraints:
                  _isShorts ? const BoxConstraints(maxHeight: 460) : null,
              child: Center(
                child: AspectRatio(
                  aspectRatio: _isShorts ? 9 / 16 : 16 / 9,
                  child: mediaWidget,
                ),
              ),
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

  Widget _buildPlayerWithErrorFallback(Widget player) {
    if (_playerErrorCode == 0) return player;
    return ColoredBox(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Video tidak dapat diputar di aplikasi.',
              style: TextStyle(color: Colors.white),
            ),
            TextButton.icon(
              onPressed: _openInYoutube,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Buka di YouTube'),
            ),
          ],
        ),
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
              color: widget.isAudioMode
                  ? const Color(0xFF7E22CE)
                  : const Color(0xFFFF0000),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isAudioMode
                      ? Icons.headphones_rounded
                      : Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.isAudioMode
                      ? 'AUDIO EDUKASI'
                      : (_isShorts ? 'SHORTS' : 'YOUTUBE'),
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
  }

  Widget _buildWatchedButton() {
    final activeBg = widget.isAudioMode
        ? const Color(0xFF7E22CE)
        : AppColors.primaryContainer;
    const doneBg = Color(0xFF16A34A);

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
              backgroundColor: _isWatchedManual ? doneBg : activeBg,
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: activeBg.withValues(alpha: 0.3),
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
                        SnackBar(
                          content: Text(
                            widget.isAudioMode
                                ? 'Audio edukasi berhasil ditandai selesai didengarkan! 🎉'
                                : 'Video edukasi berhasil ditandai selesai menonton! 🎉',
                          ),
                          backgroundColor:
                              widget.isAudioMode
                                  ? const Color(0xFF7E22CE)
                                  : AppColors.primaryContainer,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
            icon: Icon(
              _isWatchedManual
                  ? Icons.replay_rounded
                  : (widget.isAudioMode
                      ? Icons.headphones_rounded
                      : Icons.play_circle_fill_rounded),
              size: 20,
              color: Colors.white,
            ),
            label: Text(
              _isWatchedManual
                  ? (widget.isAudioMode ? 'Putar Ulang Audio' : 'Tonton Ulang Video')
                  : (widget.isAudioMode
                      ? 'Tandai Selesai Mendengarkan Audio'
                      : 'Tandai Selesai Menonton Video'),
              style: const TextStyle(
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
}
