import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class YouTubePreviewCard extends StatefulWidget {
  const YouTubePreviewCard({
    super.key,
    required this.videoTitle,
    required this.videoDuration,
    required this.channelName,
    required this.imageUrl,
    this.videoUrl,
  });

  final String videoTitle;
  final String videoDuration;
  final String channelName;
  final String imageUrl;
  final String? videoUrl;

  @override
  State<YouTubePreviewCard> createState() => _YouTubePreviewCardState();
}

class _YouTubePreviewCardState extends State<YouTubePreviewCard> {
  bool _isPlaying = false;
  bool _isPaused = false;
  double _currentProgress = 0.25; // 25% initial playback position for MVP demo

  void _togglePlayPause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _seek(double value) {
    setState(() {
      _currentProgress = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: _isPlaying ? _buildActiveInAppPlayer() : _buildPreviewState(),
        ),
      ),
    );
  }

  // State 1: YouTube Preview Card
  Widget _buildPreviewState() {
    return Stack(
      children: [
        // Thumbnail Image
        Positioned.fill(
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.surfaceContainerHighest,
              child: const Icon(Icons.video_library_rounded, size: 48),
            ),
          ),
        ),

        // Dark Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.85),
                  Colors.black.withValues(alpha: 0.20),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Top Badge: "VIDEO EDUKASI"
        Positioned(
          top: AppSpacing.sm,
          left: AppSpacing.sm,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF0000), // YouTube Red
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'VIDEO EDUKASI',
                  style: AppTextStyles.labelMd.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Center YouTube Play Button Overlay
        Center(
          child: GestureDetector(
            onTap: () => setState(() => _isPlaying = true),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFFF0000), // YouTube Red
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),
        ),

        // Bottom Details (Title, Channel, Duration)
        Positioned(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.sm,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.videoTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLg.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      widget.channelName,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Duration Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.videoDuration,
                  style: AppTextStyles.labelMd.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // State 2: Active In-App YouTube Player Mode
  Widget _buildActiveInAppPlayer() {
    return Stack(
      children: [
        // Simulated Video Playback Canvas
        Positioned.fill(
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        // Dimming filter for video interface
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: _isPaused ? 0.6 : 0.25),
          ),
        ),

        // Top Bar: Active status & Close player
        Positioned(
          top: AppSpacing.xs,
          left: AppSpacing.sm,
          right: AppSpacing.sm,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Memutar di Aplikasi',
                    style: AppTextStyles.labelMd.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                onPressed: () => setState(() => _isPlaying = false),
              ),
            ],
          ),
        ),

        // Center Control Bar: Re-wind, Play/Pause, Fast-Forward
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 32),
                onPressed: () {
                  _seek((_currentProgress - 0.1).clamp(0.0, 1.0));
                },
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 32),
                onPressed: () {
                  _seek((_currentProgress + 0.1).clamp(0.0, 1.0));
                },
              ),
            ],
          ),
        ),

        // Bottom Scrubber Bar & Controls
        Positioned(
          left: AppSpacing.sm,
          right: AppSpacing.sm,
          bottom: AppSpacing.xs,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  activeTrackColor: Colors.red,
                  inactiveTrackColor: Colors.white30,
                  thumbColor: Colors.red,
                ),
                child: Slider(
                  value: _currentProgress,
                  onChanged: _seek,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '02:12 / ${widget.videoDuration}',
                      style: AppTextStyles.labelMd.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                    const Icon(
                      Icons.fullscreen_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
