import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import '../network/dio_client.dart';
import '../sync/sync_queue_item.dart';
import '../sync/sync_queue_manager.dart';

final appUsageTrackerProvider = Provider<AppUsageTracker>((ref) {
  final tracker = AppUsageTracker(ref);
  ref.onDispose(() {
    tracker.dispose();
  });
  return tracker;
});

class AppUsageTracker with WidgetsBindingObserver {
  final Ref _ref;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  DateTime? _sessionStart;
  String? _currentSessionId;
  bool _isTracking = false;
  bool _isFlushing = false;
  late final Timer _flushTimer;

  AppUsageTracker(this._ref) {
    WidgetsBinding.instance.addObserver(this);
    startSession();
    _flushTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => unawaited(_flushAndRestartSession()),
    );
  }

  void startSession() {
    if (_isTracking) return;
    _sessionStart = DateTime.now();
    _currentSessionId = const Uuid().v4();
    _isTracking = true;
  }

  Future<void> endSession() async {
    if (!_isTracking || _sessionStart == null || _currentSessionId == null) {
      return;
    }

    final end = DateTime.now();
    final start = _sessionStart!;
    final sessionId = _currentSessionId!;
    final durationSeconds = end.difference(start).inSeconds;

    // Reset session in-memory state immediately so background does not accumulate time
    _isTracking = false;
    _sessionStart = null;
    _currentSessionId = null;

    // Skip trivial sub-second sessions
    if (durationSeconds < 1) return;

    final userId = await _resolveUserId();
    if (userId == null || userId.isEmpty) return;

    final usageDate =
        "${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";
    final clientId = const Uuid().v4();

    final payload = {
      'client_id': clientId,
      'session_id': sessionId,
      'usage_date': usageDate,
      'duration_seconds': durationSeconds,
      'started_at': start.toIso8601String(),
      'ended_at': end.toIso8601String(),
    };

    try {
      final dio = _ref.read(dioClientProvider);
      await dio.post('/patient/app-usage', data: payload);
    } catch (_) {
      // Offline fallback: enqueue to persistent sync queue
      try {
        final syncItem = SyncQueueItem(
          clientId: clientId,
          userId: userId,
          dataType: SyncDataType.appUsage,
          endpoint: '/patient/app-usage',
          method: 'POST',
          payload: payload,
          createdAt: DateTime.now(),
        );
        await _ref.read(syncQueueManagerProvider.notifier).enqueue(syncItem);
      } catch (_) {}
    }
  }

  Future<void> _flushAndRestartSession() async {
    if (_isFlushing || !_isTracking) return;
    _isFlushing = true;
    try {
      await endSession();
      startSession();
    } finally {
      _isFlushing = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      startSession();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      unawaited(endSession());
    }
  }

  Future<String?> _resolveUserId() async {
    try {
      return await _secureStorage.read(key: AppConstants.keyUserId);
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flushTimer.cancel();
    if (_isTracking) {
      endSession();
    }
  }
}
