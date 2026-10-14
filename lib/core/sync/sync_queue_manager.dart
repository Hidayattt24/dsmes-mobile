import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';
import '../network/auth_interceptor.dart';
import '../storage/local_storage_service.dart';
import 'sync_queue_item.dart';

class SyncQueueManager extends StateNotifier<List<SyncQueueItem>> {
  final LocalStorageService _localStorage;
  final FlutterSecureStorage _secureStorage;
  bool _isProcessing = false;

  static const String queueStorageKey = 'pending_sync_queue';

  SyncQueueManager(this._localStorage, this._secureStorage) : super(const []) {
    unawaited(loadQueue());
  }

  bool get isProcessing => _isProcessing;

  Future<String?> _resolveUserId() async {
    try {
      return await _secureStorage.read(key: AppConstants.keyUserId);
    } catch (_) {
      return null;
    }
  }

  /// Loads queue from encrypted local storage on startup or user switch.
  /// Automatically resets any items stuck in 'syncing' back to 'pending'.
  Future<List<SyncQueueItem>> loadQueue({String? userId}) async {
    final effectiveUserId = userId ?? await _resolveUserId();
    final rawList = await _localStorage.readEncryptedJson(
      queueStorageKey,
      userId: effectiveUserId,
    );

    if (rawList is List) {
      final items = rawList
          .whereType<Map<String, dynamic>>()
          .map(SyncQueueItem.fromJson)
          .map((item) {
            // Crash recovery: if app was killed while syncing, reset to pending
            if (item.status == SyncStatus.syncing) {
              return item.copyWith(status: SyncStatus.pending);
            }
            return item;
          })
          .toList();

      state = items;
      return items;
    }

    state = const [];
    return const [];
  }

  /// Persists current queue state to encrypted local storage.
  Future<void> _persistQueue(List<SyncQueueItem> items, {String? userId}) async {
    final effectiveUserId = userId ?? await _resolveUserId();
    await _localStorage.writeEncryptedJson(
      queueStorageKey,
      items.map((e) => e.toJson()).toList(),
      userId: effectiveUserId,
    );
    state = items;
  }

  /// Adds an offline write item to the persistent queue.
  Future<void> enqueue(SyncQueueItem item) async {
    final effectiveUserId = item.userId.isNotEmpty
        ? item.userId
        : (await _resolveUserId() ?? 'global');

    final updated = [
      ...state.where((i) => i.clientId != item.clientId),
      item.copyWith(userId: effectiveUserId),
    ];

    await _persistQueue(updated, userId: effectiveUserId);
    debugPrint('[SyncQueueManager] Enqueued item: ${item.clientId} for ${item.endpoint}');
  }

  /// Removes a successfully synced item from the queue.
  Future<void> remove(String clientId, {String? userId}) async {
    final effectiveUserId = userId ?? await _resolveUserId();
    final updated = state.where((item) => item.clientId != clientId).toList();
    await _persistQueue(updated, userId: effectiveUserId);
    debugPrint('[SyncQueueManager] Removed synced item: $clientId');
  }

  /// Updates status of an item in the queue.
  Future<void> updateItemStatus(
    String clientId,
    SyncStatus status, {
    String? error,
    String? userId,
  }) async {
    final effectiveUserId = userId ?? await _resolveUserId();
    final updated = state.map((item) {
      if (item.clientId == clientId) {
        return item.copyWith(
          status: status,
          lastError: error,
          retryCount: status == SyncStatus.pending
              ? item.retryCount + 1
              : item.retryCount,
        );
      }
      return item;
    }).toList();

    await _persistQueue(updated, userId: effectiveUserId);
  }

  /// Sequentially executes pending items with single-flight mutex lock.
  Future<int> processQueue(Dio dio, {String? userId}) async {
    if (_isProcessing) {
      debugPrint('[SyncQueueManager] Process already in flight, skipping duplicate call.');
      return 0;
    }

    _isProcessing = true;
    int successCount = 0;

    try {
      final effectiveUserId = userId ?? await _resolveUserId();
      final items = await loadQueue(userId: effectiveUserId);
      final pendingItems = items
          .where((i) => i.status == SyncStatus.pending)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      if (pendingItems.isEmpty) {
        return 0;
      }

      debugPrint('[SyncQueueManager] Processing ${pendingItems.length} pending items.');

      for (final item in pendingItems) {
        await updateItemStatus(
          item.clientId,
          SyncStatus.syncing,
          userId: effectiveUserId,
        );

        final payload = Map<String, dynamic>.from(item.payload);
        // Ensure client_id is explicitly sent for backend idempotency tracking
        payload['client_id'] = item.clientId;

        try {
          Response response;
          final options = Options(
            headers: {'X-Client-Id': item.clientId},
            sendTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          );

          if (item.method.toUpperCase() == 'POST') {
            response = await dio.post(
              item.endpoint,
              data: payload,
              options: options,
            );
          } else if (item.method.toUpperCase() == 'PUT') {
            response = await dio.put(
              item.endpoint,
              data: payload,
              options: options,
            );
          } else if (item.method.toUpperCase() == 'DELETE') {
            response = await dio.delete(
              item.endpoint,
              data: payload,
              options: options,
            );
          } else {
            response = await dio.request(
              item.endpoint,
              data: payload,
              options: options.copyWith(method: item.method),
            );
          }

          if (response.statusCode != null &&
              response.statusCode! >= 200 &&
              response.statusCode! < 300) {
            await remove(item.clientId, userId: effectiveUserId);
            successCount++;
          }
        } on DioException catch (dioErr) {
          final status = dioErr.response?.statusCode;

          if (status == 400 || status == 422) {
            // Validation failed permanently — do not infinite retry
            final msg = dioErr.response?.data?['message'] ?? dioErr.message;
            await updateItemStatus(
              item.clientId,
              SyncStatus.failedValidation,
              error: msg.toString(),
              userId: effectiveUserId,
            );
          } else if (status == 401) {
            // Authentication expired — stop processing until auth refreshed
            await updateItemStatus(
              item.clientId,
              SyncStatus.pending,
              error: 'Session expired during sync',
              userId: effectiveUserId,
            );
            break;
          } else if (status == 403) {
            // Forbidden access
            await updateItemStatus(
              item.clientId,
              SyncStatus.failedAuth,
              error: 'Forbidden access',
              userId: effectiveUserId,
            );
          } else if (status == 429) {
            // Rate limited — halt queue processing
            await updateItemStatus(
              item.clientId,
              SyncStatus.pending,
              error: 'Rate limit hit',
              userId: effectiveUserId,
            );
            break;
          } else {
            // Network outage, 5xx, or socket timeout — keep pending for next cycle
            await updateItemStatus(
              item.clientId,
              SyncStatus.pending,
              error: dioErr.message,
              userId: effectiveUserId,
            );
            break;
          }
        } catch (e) {
          await updateItemStatus(
            item.clientId,
            SyncStatus.pending,
            error: e.toString(),
            userId: effectiveUserId,
          );
          break;
        }
      }
    } finally {
      _isProcessing = false;
    }

    return successCount;
  }
}

final syncQueueManagerProvider =
    StateNotifierProvider<SyncQueueManager, List<SyncQueueItem>>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return SyncQueueManager(localStorage, secureStorage);
});
