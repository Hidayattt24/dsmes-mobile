import 'package:flutter/foundation.dart';

enum SyncStatus {
  pending,
  syncing,
  synced,
  failedValidation,
  failedAuth,
  failedPermanent,
}

enum SyncDataType {
  bloodSugar,
  activity,
  medication,
  meal,
  questionnaire,
}

@immutable
class SyncQueueItem {
  final String clientId;
  final String userId;
  final SyncDataType dataType;
  final String endpoint;
  final String method;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final SyncStatus status;
  final int retryCount;
  final String? lastError;

  const SyncQueueItem({
    required this.clientId,
    required this.userId,
    required this.dataType,
    required this.endpoint,
    required this.method,
    required this.payload,
    required this.createdAt,
    this.status = SyncStatus.pending,
    this.retryCount = 0,
    this.lastError,
  });

  SyncQueueItem copyWith({
    String? clientId,
    String? userId,
    SyncDataType? dataType,
    String? endpoint,
    String? method,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    SyncStatus? status,
    int? retryCount,
    String? lastError,
    bool clearError = false,
  }) {
    return SyncQueueItem(
      clientId: clientId ?? this.clientId,
      userId: userId ?? this.userId,
      dataType: dataType ?? this.dataType,
      endpoint: endpoint ?? this.endpoint,
      method: method ?? this.method,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'user_id': userId,
      'data_type': dataType.name,
      'endpoint': endpoint,
      'method': method,
      'payload': payload,
      'created_at': createdAt.toIso8601String(),
      'status': status.name,
      'retry_count': retryCount,
      'last_error': lastError,
    };
  }

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      clientId: json['client_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      dataType: SyncDataType.values.firstWhere(
        (e) => e.name == json['data_type'],
        orElse: () => SyncDataType.bloodSugar,
      ),
      endpoint: json['endpoint'] as String? ?? '',
      method: json['method'] as String? ?? 'POST',
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? {}),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      status: SyncStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SyncStatus.pending,
      ),
      retryCount: (json['retry_count'] as num?)?.toInt() ?? 0,
      lastError: json['last_error'] as String?,
    );
  }
}
