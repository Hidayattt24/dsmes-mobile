import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/history_repository.dart';
import '../models/history_item_model.dart';

class HistoryState {
  final List<HistoryItemModel> allItems;
  final Map<String, DailyHistoryAggregate> dailyAggregates;
  final bool isLoading;
  final String? errorMessage;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  const HistoryState({
    this.allItems = const [],
    this.dailyAggregates = const {},
    this.isLoading = true,
    this.errorMessage,
    this.totalItems = 0,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = false,
  });

  HistoryState copyWith({
    List<HistoryItemModel>? allItems,
    Map<String, DailyHistoryAggregate>? dailyAggregates,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    int? totalItems,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
  }) {
    return HistoryState(
      allItems: allItems ?? this.allItems,
      dailyAggregates: dailyAggregates ?? this.dailyAggregates,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      totalItems: totalItems ?? this.totalItems,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  DailyHistoryAggregate? getAggregateForDate(DateTime date) {
    final d = date.toLocal();
    final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return dailyAggregates[key];
  }

  List<HistoryItemModel> get recentItemsLimited {
    if (allItems.length > 5) {
      return allItems.sublist(0, 5);
    }
    return allItems;
  }
}

class HistoryNotifier extends AsyncNotifier<HistoryState> {
  @override
  Future<HistoryState> build() async {
    return _fetchData();
  }

  Future<HistoryState> _fetchData({int page = 1}) async {
    final repo = ref.read(historyRepositoryProvider);
    final result = await repo.getPatientHistory(page: page, limit: 100);

    final allItems = result.items;
    final aggregates = _groupByDate(allItems);

    return HistoryState(
      allItems: allItems,
      dailyAggregates: aggregates,
      isLoading: false,
      totalItems: result.total,
      currentPage: result.page,
      totalPages: result.totalPages,
      hasMore: result.page < result.totalPages,
    );
  }

  Map<String, DailyHistoryAggregate> _groupByDate(List<HistoryItemModel> items) {
    final grouped = <String, List<HistoryItemModel>>{};
    for (final item in items) {
      final dt = item.parsedMeasuredAt;
      if (dt == null) continue;
      final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }
    return grouped.map((key, value) => MapEntry(
          key,
          DailyHistoryAggregate(
            date: DateTime.parse(key),
            items: value,
          ),
        ));
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchData());
  }

  Future<void> loadMore() async {
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.hasMore || currentState.isLoading) return;

    final nextPage = currentState.currentPage + 1;
    try {
      final repo = ref.read(historyRepositoryProvider);
      final result = await repo.getPatientHistory(page: nextPage, limit: 100);

      final allItems = [...currentState.allItems, ...result.items];
      final aggregates = _groupByDate(allItems);

      state = AsyncValue.data(HistoryState(
        allItems: allItems,
        dailyAggregates: aggregates,
        isLoading: false,
        totalItems: result.total,
        currentPage: result.page,
        totalPages: result.totalPages,
        hasMore: result.page < result.totalPages,
      ));
    } catch (_) {
      // Silently fail for loadMore
    }
  }
}

final historyProvider = AsyncNotifierProvider<HistoryNotifier, HistoryState>(
  HistoryNotifier.new,
);
