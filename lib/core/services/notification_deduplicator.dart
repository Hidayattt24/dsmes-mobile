import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationDeduplicator {
  NotificationDeduplicator._();

  static const String prefKey = 'notification_dedup_cache_v1';
  static const Duration defaultTtl = Duration(hours: 48);
  static const int maxCacheEntries = 100;

  static final Map<String, int> _memoryCache = <String, int>{};

  /// Resolves the deduplication key following:
  /// 1. occurrence_id
  /// 2. reminder_id + scheduled_at
  /// 3. message_id
  static String resolveKey(Map<String, dynamic> data, {String? messageId}) {
    final occurrenceId = data['occurrence_id']?.toString().trim();
    if (occurrenceId != null && occurrenceId.isNotEmpty) {
      return occurrenceId;
    }

    final reminderId = data['reminder_id']?.toString().trim();
    final scheduledAt = data['scheduled_at']?.toString().trim();
    if (reminderId != null &&
        reminderId.isNotEmpty &&
        scheduledAt != null &&
        scheduledAt.isNotEmpty) {
      return '${reminderId}_$scheduledAt';
    }

    final msgId = (messageId ?? data['message_id']?.toString())?.trim();
    if (msgId != null && msgId.isNotEmpty) {
      return msgId;
    }

    if (reminderId != null && reminderId.isNotEmpty) {
      return 'reminder_$reminderId';
    }

    return '';
  }

  /// Converts key to a consistent positive 32-bit integer notification ID.
  static int resolveNotificationId(String key) {
    if (key.isEmpty) return 0;
    return key.hashCode.abs();
  }

  /// Logs decision conforming to the diagnostic specification.
  static void logDecision({
    required String source,
    required String occurrenceId,
    required String decision,
  }) {
    debugPrint(
      '[NOTIFICATION][DEDUPLICATION] source=$source occurrence_id=$occurrenceId decision=$decision',
    );
  }

  /// Checks if key has already been processed within TTL.
  static Future<bool> isDuplicate(
    String key, {
    Duration ttl = defaultTtl,
    SharedPreferences? prefs,
  }) async {
    if (key.isEmpty) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final cutoff = now - ttl.inMilliseconds;

    // Check memory cache first
    final memTimestamp = _memoryCache[key];
    if (memTimestamp != null) {
      if (memTimestamp >= cutoff) {
        return true;
      } else {
        _memoryCache.remove(key);
      }
    }

    // Check persistent storage
    try {
      final p = prefs ?? await SharedPreferences.getInstance();
      final raw = p.getString(prefKey);
      if (raw != null && raw.isNotEmpty) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final ts = map[key];
        if (ts is int && ts >= cutoff) {
          _memoryCache[key] = ts;
          return true;
        }
      }
    } catch (e) {
      debugPrint('[NOTIFICATION][DEDUPLICATION] isDuplicate error: $e');
    }

    return false;
  }

  /// Marks key as processed and persists to storage with TTL pruning.
  static Future<void> markProcessed(
    String key, {
    Duration ttl = defaultTtl,
    SharedPreferences? prefs,
  }) async {
    if (key.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final cutoff = now - ttl.inMilliseconds;

    _memoryCache[key] = now;

    try {
      final p = prefs ?? await SharedPreferences.getInstance();
      final raw = p.getString(prefKey);
      Map<String, dynamic> map = <String, dynamic>{};
      if (raw != null && raw.isNotEmpty) {
        try {
          map = jsonDecode(raw) as Map<String, dynamic>;
        } catch (_) {
          map = <String, dynamic>{};
        }
      }

      // Prune expired
      map.removeWhere((_, value) => (value is! int) || value < cutoff);

      // Add current
      map[key] = now;

      // Limit size
      if (map.length > maxCacheEntries) {
        final sortedKeys =
            map.keys.toList()
              ..sort((a, b) => (map[a] as int).compareTo(map[b] as int));
        final keysToRemove = sortedKeys.take(map.length - maxCacheEntries);
        for (final k in keysToRemove) {
          map.remove(k);
          _memoryCache.remove(k);
        }
      }

      await p.setString(prefKey, jsonEncode(map));
    } catch (e) {
      debugPrint('[NOTIFICATION][DEDUPLICATION] markProcessed error: $e');
    }
  }

  /// Clears in-memory and persistent cache (useful for tests or logout).
  static Future<void> clear({SharedPreferences? prefs}) async {
    _memoryCache.clear();
    try {
      final p = prefs ?? await SharedPreferences.getInstance();
      await p.remove(prefKey);
    } catch (_) {}
  }
}
