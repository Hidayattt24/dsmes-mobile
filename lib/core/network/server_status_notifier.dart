import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ServerHealth {
  online,
  offline,
  serverDown,
}

class ServerStatusState {
  final ServerHealth health;
  final String? message;
  final DateTime? lastChecked;

  const ServerStatusState({
    this.health = ServerHealth.online,
    this.message,
    this.lastChecked,
  });

  bool get isOnline => health == ServerHealth.online;
  bool get isOffline => health == ServerHealth.offline;
  bool get isServerDown => health == ServerHealth.serverDown;

  ServerStatusState copyWith({
    ServerHealth? health,
    String? message,
    DateTime? lastChecked,
  }) {
    return ServerStatusState(
      health: health ?? this.health,
      message: message ?? this.message,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }
}

class ServerStatusNotifier extends StateNotifier<ServerStatusState> {
  ServerStatusNotifier() : super(const ServerStatusState());

  void markOnline() {
    if (state.health != ServerHealth.online) {
      state = ServerStatusState(
        health: ServerHealth.online,
        lastChecked: DateTime.now(),
      );
    }
  }

  void markOffline([String? message]) {
    state = ServerStatusState(
      health: ServerHealth.offline,
      message: message ?? 'Koneksi internet terputus. Bekerja dalam mode offline.',
      lastChecked: DateTime.now(),
    );
  }

  void markServerDown([String? message]) {
    state = ServerStatusState(
      health: ServerHealth.serverDown,
      message: message ?? 'Server sedang tidak dapat dijangkau. Menampilkan data lokal.',
      lastChecked: DateTime.now(),
    );
  }
}

final serverStatusProvider =
    StateNotifierProvider<ServerStatusNotifier, ServerStatusState>((ref) {
  return ServerStatusNotifier();
});

/// Interceptor to automatically detect network/server outage from any Dio request.
class ServerStatusInterceptor extends Interceptor {
  final Ref _ref;

  ServerStatusInterceptor(this._ref);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode != null && response.statusCode! < 500) {
      _ref.read(serverStatusProvider.notifier).markOnline();
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final notifier = _ref.read(serverStatusProvider.notifier);

    switch (err.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.sendTimeout:
        notifier.markOffline();
        break;
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        notifier.markServerDown('Koneksi ke server timeout.');
        break;
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode;
        if (status != null && status >= 500) {
          notifier.markServerDown('Server sedang dalam pemeliharaan ($status).');
        }
        break;
      default:
        break;
    }

    handler.next(err);
  }
}
