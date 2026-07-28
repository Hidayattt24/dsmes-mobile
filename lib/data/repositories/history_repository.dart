import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../../features/home/history/models/history_item_model.dart';

abstract class IHistoryRepository {
  Future<HistoryListResult> getPatientHistory({
    int page = 1,
    int limit = 50,
  });
}

class HistoryListResult {
  final List<HistoryItemModel> items;
  final int total;
  final int page;
  final int totalPages;

  const HistoryListResult({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPages,
  });
}

class HistoryRepository implements IHistoryRepository {
  final Dio _dio;

  HistoryRepository(this._dio);

  @override
  Future<HistoryListResult> getPatientHistory({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/patient/history',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      final responseData = response.data as Map<String, dynamic>;
      final itemsData = responseData['data'] as List<dynamic>? ?? [];
      final meta = responseData['meta'] as Map<String, dynamic>? ?? {};

      final items = itemsData
          .cast<Map<String, dynamic>>()
          .map(HistoryItemModel.fromJson)
          .toList();

      return HistoryListResult(
        items: items,
        total: (meta['total'] as num?)?.toInt() ?? items.length,
        page: (meta['page'] as num?)?.toInt() ?? page,
        totalPages: (meta['total_pages'] as num?)?.toInt() ?? 1,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final historyRepositoryProvider = Provider<IHistoryRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return HistoryRepository(dio);
});
