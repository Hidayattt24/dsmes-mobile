import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

typedef AudioCompletionCallback =
    Future<void> Function(int listenDuration, int lastPosition);

Uri resolveEducationAudioUri(String audioUrl, String apiBaseUrl) {
  final cleanAudio = audioUrl.trim();
  if (cleanAudio.isEmpty) {
    throw const FormatException('Alamat audio tidak valid');
  }

  String resolvedApi = apiBaseUrl.trim();
  if (resolvedApi.isEmpty) {
    resolvedApi = 'https://api.dsmesacehproject.com/api/v1';
  }

  final api = Uri.tryParse(resolvedApi);
  if (api == null || !api.hasScheme || api.host.isEmpty) {
    throw const FormatException('Alamat API tidak valid');
  }

  final source = Uri.tryParse(cleanAudio);
  if (source == null) {
    throw const FormatException('Alamat audio tidak valid');
  }

  // If source already has a full valid remote URL
  if (source.hasScheme && source.host.isNotEmpty) {
    // If pointing to dsmesacehproject.com (frontend web), route to api.dsmesacehproject.com where Go backend serves static files
    if (source.host == 'dsmesacehproject.com' && source.path.startsWith('/uploads')) {
      return source.replace(host: 'api.dsmesacehproject.com');
    }

    // If pointing to localhost/127.0.0.1
    if (source.host == 'localhost' || source.host == '127.0.0.1') {
      if (api.host != 'localhost' && api.host != '127.0.0.1') {
        final origin = api.replace(path: '', query: null, fragment: null);
        final path = source.path.startsWith('/') ? source.path : '/${source.path}';
        return origin.replace(
          path: path,
          query: source.hasQuery ? source.query : null,
        );
      }
    }
    return source;
  }

  // Relative path (e.g. /uploads/audio/xxx.m4a)
  final origin = api.replace(path: '', query: null, fragment: null);
  final path = source.path.startsWith('/') ? source.path : '/${source.path}';
  return origin.replace(
    path: path,
    query: source.hasQuery ? source.query : null,
  );
}

class EducationAudioPlayerCard extends StatefulWidget {
  const EducationAudioPlayerCard({
    super.key,
    required this.audioUrl,
    required this.title,
    this.isListened = false,
    this.onAudioProgress,
    this.onAudioEnded,
  });

  final String audioUrl;
  final String title;
  final bool isListened;
  final void Function(int listenDuration, int lastPosition)? onAudioProgress;
  final AudioCompletionCallback? onAudioEnded;

  @override
  State<EducationAudioPlayerCard> createState() =>
      _EducationAudioPlayerCardState();
}

class _EducationAudioPlayerCardState extends State<EducationAudioPlayerCard> {
  late AudioPlayer _player;
  StreamSubscription<PlayerState>? _stateSubscription;
  StreamSubscription<PlaybackEvent>? _eventSubscription;
  bool _isInit = false;
  bool _hasError = false;
  AudioSession? _audioSession;
  double _playbackSpeed = 1.0;

  // Telemetry tracking
  Timer? _telemetryTimer;
  bool _completionTriggered = false;
  bool _isCompletedManual = false;
  bool _isSavingCompletion = false;
  String? _completionError;
  int _sourceVersion = 0;

  @override
  void initState() {
    super.initState();
    _isCompletedManual = widget.isListened;
    _createPlayer();
  }

  @override
  void didUpdateWidget(EducationAudioPlayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListened != oldWidget.isListened) {
      setState(() {
        _isCompletedManual = widget.isListened;
        if (widget.isListened) _completionError = null;
      });
    }
    if (widget.audioUrl != oldWidget.audioUrl) {
      _createPlayer();
    }
  }

  void _createPlayer() {
    _sourceVersion++;
    final version = _sourceVersion;
    _stopTelemetryTimer();
    _stateSubscription?.cancel();
    _eventSubscription?.cancel();
    if (_sourceVersion > 1) _player.dispose();
    _player = AudioPlayer();
    _isInit = false;
    _hasError = false;
    _completionTriggered = false;
    _isSavingCompletion = false;
    _completionError = null;
    _stateSubscription = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      if (state.playing) {
        _startTelemetryTimer();
      } else {
        _stopTelemetryTimer();
      }
      if (state.processingState == ProcessingState.completed) {
        _onPlaybackFinished();
      }
    });
    _eventSubscription = _player.playbackEventStream.listen(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        if (version == _sourceVersion) _showPlaybackError(error);
      },
    );
    _initAudio(version, _player);
  }

  Future<void> _initAudio(int version, AudioPlayer player) async {
    try {
      String baseUrl = AppConstants.baseUrl;
      if (baseUrl.trim().isEmpty) {
        baseUrl = 'https://api.dsmesacehproject.com/api/v1';
      }
      final uri = resolveEducationAudioUri(
        widget.audioUrl,
        baseUrl,
      );
      debugPrint(
        'EducationAudioPlayerCard loading audio from $uri',
      );
      final duration = await player.setUrl(uri.toString());
      if (duration == null || duration <= Duration.zero) {
        debugPrint(
          'EducationAudioPlayerCard: duration is zero or null for $uri',
        );
      }
      if (mounted && version == _sourceVersion) {
        setState(() {
          _isInit = true;
          _hasError = false;
        });
      }
    } catch (e) {
      if (version == _sourceVersion) _showPlaybackError(e);
    }
  }

  void _showPlaybackError(Object error) {
    debugPrint('EducationAudioPlayerCard playback error: $error');
    if (!mounted || _hasError) return;
    _stopTelemetryTimer();
    setState(() {
      _hasError = true;
      _isInit = false;
    });
  }

  Future<void> _togglePlayback() async {
    if (_hasError) {
      _createPlayer();
      return;
    }
    if (!_isInit) return;
    final version = _sourceVersion;
    void handleError(Object error) {
      if (version == _sourceVersion) _showPlaybackError(error);
    }

    if (_player.playing) {
      await _player.pause().catchError(handleError);
    } else {
      try {
        if (_player.processingState == ProcessingState.completed) {
          await _player.seek(Duration.zero);
        }
        await _player.play().catchError(handleError);
      } catch (error) {
        handleError(error);
      }
    }
  }

  void _startTelemetryTimer() {
    _telemetryTimer?.cancel();
    _telemetryTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_player.playing) return;
      final currentPos = _player.position.inSeconds;
      widget.onAudioProgress?.call(5, currentPos);

      // If user listened to 80% or more, consider marked
      final totalSec = _player.duration?.inSeconds ?? 0;
      if (totalSec > 0 &&
          currentPos >= (totalSec * 0.8) &&
          !_completionTriggered) {
        _completionTriggered = true;
        unawaited(_saveCompletion(showFeedback: false));
      }
    });
  }

  void _stopTelemetryTimer() {
    _telemetryTimer?.cancel();
    _telemetryTimer = null;
  }

  void _onPlaybackFinished() {
    final dur = _player.duration;
    if (dur == null || dur <= Duration.zero) {
      // Stream completed with 0 or null duration (empty/failed stream), do not treat as completion!
      return;
    }
    final pos = _player.position;
    if (pos < (dur - const Duration(seconds: 2)) &&
        pos.inSeconds < (dur.inSeconds * 0.8)) {
      return;
    }

    if (!_completionTriggered) {
      _completionTriggered = true;
      unawaited(_saveCompletion(showFeedback: false));
    }
  }

  Future<void> _saveCompletion({required bool showFeedback}) async {
    if (_isSavingCompletion || widget.isListened || _isCompletedManual) return;

    setState(() {
      _isSavingCompletion = true;
      _completionError = null;
    });

    try {
      final callback = widget.onAudioEnded;
      if (callback != null) {
        // Listening intervals have already been reported periodically. This
        // request only commits completion and the latest playback position.
        await callback(0, _player.position.inSeconds);
      }
      if (!mounted) return;
      setState(() {
        _isSavingCompletion = false;
        _isCompletedManual = true;
        _completionError = null;
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
    } catch (error) {
      debugPrint('EducationAudioPlayerCard completion error: $error');
      if (!mounted) return;
      setState(() {
        _isSavingCompletion = false;
        _completionTriggered = false;
        _completionError =
            'Status belum tersimpan. Periksa koneksi lalu coba lagi.';
      });
      if (showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan status audio. Silakan coba lagi.'),
            backgroundColor: Color(0xFFB91C1C),
          ),
        );
      }
    }
  }

  void _toggleSpeed() {
    final speeds = [1.0, 1.25, 1.5, 2.0];
    final nextIdx = (speeds.indexOf(_playbackSpeed) + 1) % speeds.length;
    final nextSpeed = speeds[nextIdx];
    _player.setSpeed(nextSpeed);
    setState(() {
      _playbackSpeed = nextSpeed;
    });
  }

  void _seekBy(int seconds) {
    final cur = _player.position;
    final max = _player.duration ?? Duration.zero;
    final target = cur + Duration(seconds: seconds);
    if (target < Duration.zero) {
      _player.seek(Duration.zero);
    } else if (target > max) {
      _player.seek(max);
    } else {
      _player.seek(target);
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _playbackStatus(PlayerState? state, Duration? duration) {
    if (!_isInit || state?.processingState == ProcessingState.loading) {
      return 'Memuat audio...';
    }
    if (state?.processingState == ProcessingState.buffering) {
      return 'Menyiapkan audio...';
    }
    if (state?.processingState == ProcessingState.completed) {
      if (duration != null && duration > Duration.zero) {
        return 'Selesai diputar';
      }
      return 'Siap diputar';
    }
    return state?.playing == true ? 'Sedang diputar' : 'Siap diputar';
  }

  @override
  void dispose() {
    _sourceVersion++;
    _stopTelemetryTimer();
    _stateSubscription?.cancel();
    _eventSubscription?.cancel();
    _player.dispose();
    final session = _audioSession;
    if (session != null) {
      unawaited(session.setActive(false).then<void>((_) {}));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audio tidak dapat diputar.',
              style: TextStyle(color: Color(0xFFB91C1C)),
            ),
            TextButton.icon(
              onPressed: () => setState(_createPlayer),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B67FC).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Badge & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.headphones_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 13,
                        color: Color(0xFF166534),
                      ),
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

          // Title
          Text(
            widget.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleMd.copyWith(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 4),
          StreamBuilder<Duration?>(
            stream: _player.durationStream,
            builder: (context, durationSnapshot) {
              return StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) => Text(
                  _playbackStatus(snapshot.data, durationSnapshot.data),
                  style: AppTextStyles.bodySm.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          // Stream-based Slider & Duration
          StreamBuilder<Duration?>(
            stream: _player.durationStream,
            builder: (context, durationSnapshot) {
              final duration = durationSnapshot.data ?? Duration.zero;
              return StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final maxSec = duration.inSeconds.toDouble();
                  final posSec = position.inSeconds.toDouble().clamp(
                    0.0,
                    maxSec > 0 ? maxSec : 1.0,
                  );

                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14,
                          ),
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: const Color(0xFFE2E8F0),
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primary.withValues(
                            alpha: 0.15,
                          ),
                        ),
                        child: Slider(
                          value: maxSec > 0 ? posSec : 0.0,
                          max: maxSec > 0 ? maxSec : 1.0,
                          onChanged: (val) {
                            _player.seek(Duration(seconds: val.toInt()));
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
                              duration == Duration.zero
                                  ? '--:--'
                                  : _formatDuration(duration),
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
              );
            },
          ),

          const SizedBox(height: 10),

          // Control Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Speed control
              IconButton(
                onPressed: _toggleSpeed,
                icon: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
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
                icon: const Icon(
                  Icons.replay_10_rounded,
                  color: Color(0xFF475569),
                  size: 28,
                ),
                tooltip: 'Mundur 10 detik',
              ),

              const SizedBox(width: 8),

              // Play / Pause Stream
              StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  final isPlaying = state?.playing ?? false;
                  final isBuffering =
                      state?.processingState == ProcessingState.buffering ||
                      state?.processingState == ProcessingState.loading ||
                      !_isInit;

                  return GestureDetector(
                    onTap: () => unawaited(_togglePlayback()),
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
                        child:
                            isBuffering
                                ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                                : Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
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
                icon: const Icon(
                  Icons.forward_10_rounded,
                  color: Color(0xFF475569),
                  size: 28,
                ),
                tooltip: 'Maju 10 detik',
              ),

              const SizedBox(width: 8),

              // Stop / Reset
              IconButton(
                onPressed: () {
                  _player.seek(Duration.zero);
                  _player.pause();
                },
                icon: const Icon(
                  Icons.stop_rounded,
                  color: Color(0xFF64748B),
                  size: 24,
                ),
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
                backgroundColor:
                    (widget.isListened || _isCompletedManual)
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
                  : () => unawaited(_saveCompletion(showFeedback: true)),
              icon:
                  _isSavingCompletion
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
          if (_completionError != null) ...[
            const SizedBox(height: 8),
            Text(
              _completionError!,
              style: AppTextStyles.bodySm.copyWith(
                color: const Color(0xFFB91C1C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
