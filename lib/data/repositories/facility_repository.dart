import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';

abstract class IFacilityRepository {
  Future<List<String>> fetchHealthFacilities();
}

class FacilityRepository implements IFacilityRepository {
  final Dio _dio;

  FacilityRepository(this._dio);

  @override
  Future<List<String>> fetchHealthFacilities() async {
    try {
      final response = await _dio.get(
        '/health-facilities',
        queryParameters: {'page': 1, 'limit': 100},
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      final names = <String>[];
      for (final item in data) {
        if (item is Map<String, dynamic> && item.containsKey('name')) {
          final name = item['name']?.toString().trim() ?? '';
          if (name.isNotEmpty) {
            names.add(name);
          }
        }
      }
      return names;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final facilityRepositoryProvider = Provider<IFacilityRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return FacilityRepository(dio);
});
