import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../core/theme/app_text_styles.dart';

/// A compact floating mini-player that appears when the user scrolls
/// past the inline YouTube video. Shares the same [YoutubePlayerController]
/// as the full inline player so playback is seamless.
class YouTubeMiniPlayer extends StatefulWidget {
  const YouTubeMiniPlayer({
    super.key,
    required this.controller,
    required this.videoTitle,
    required this.onExpand,
    required this.onClose,
  });

  /// Shared controller from the parent screen.
  final YoutubePlayerController controller;

  /// Short title displayed in the mini player.
  final String videoTitle;

  /// Called when the user taps the expand button or the thumbnail.
  final VoidCallback onExpand;

  /// Called when the user taps the close (✕) button.
  final VoidCallback onClose;

  @override
  State<YouTubeMiniPlayer> createState() => _YouTubeMiniPlayerState();
}

class _YouTubeMiniPlayerState extends State<YouTubeMiniPlayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack);
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();

    _isPlaying = widget.controller.value.playerState == PlayerState.playing;
    widget.controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    final playing = widget.controller.value.playerState == PlayerState.playing;
    if (playing != _isPlaying) {
      setState(() => _isPlaying = playing);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _animCtrl.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
  }

  Future<void> _closeWithAnimation() async {
    await _animCtrl.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        alignment: Alignment.bottomRight,
        child: _buildMiniPlayerCard(),
      ),
    );
  }

  Widget _buildMiniPlayerCard() {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: widget.onExpand,
        child: Container(
          width: 240,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Thumbnail with play/pause overlay ──────────────────────
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: Colors.black,
                        child: Builder(
                          builder: (_) {
                            final videoId = widget.controller.metadata.videoId;
                            if (videoId.isNotEmpty) {
                              return Image.network(
                                'https://img.youtube.com/vi/$videoId/mqdefault.jpg',
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, _, _) => const Center(
                                      child: Icon(
                                        Icons.play_circle_fill_rounded,
                                        color: Colors.white54,
                                        size: 36,
                                      ),
                                    ),
                              );
                            }
                            return const Center(
                              child: Icon(
                                Icons.play_circle_fill_rounded,
                                color: Colors.white54,
                                size: 36,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Dark overlay when playing
                    if (_isPlaying)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.35),
                        ),
                      ),
                    // Play/Pause button
                    GestureDetector(
                      onTap: _togglePlayPause,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          key: ValueKey(_isPlaying),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    // Progress indicator at the bottom of thumbnail
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buildProgressBar(),
                    ),
                  ],
                ),

                // ── Bottom info row ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                  child: Row(
                    children: [
                      // YouTube badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF0000),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Title
                      Expanded(
                        child: Text(
                          widget.videoTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelMd.copyWith(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Expand icon
                      GestureDetector(
                        onTap: widget.onExpand,
                        child: Tooltip(
                          message: 'Perluas video',
                          child: Icon(
                            Icons.picture_in_picture_alt_rounded,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Close button
                      GestureDetector(
                        onTap: _closeWithAnimation,
                        child: Tooltip(
                          message: 'Tutup mini player',
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white70,
                            size: 18,
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
      ),
    );
  }

  Widget _buildProgressBar() {
    return ValueListenableBuilder<YoutubePlayerValue>(
      valueListenable: widget.controller,
      builder: (context, value, child) {
        final duration = value.metaData.duration.inSeconds;
        final position = value.position.inSeconds;
        final progress =
            (duration > 0) ? (position / duration).clamp(0.0, 1.0) : 0.0;
        return LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white24,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF0000)),
          minHeight: 3,
        );
      },
    );
  }
}
