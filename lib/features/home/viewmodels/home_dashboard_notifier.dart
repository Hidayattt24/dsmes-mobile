import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/blood_sugar_repository.dart';
import '../blood_sugar/models/blood_sugar_log_model.dart';
import '../history/models/recent_activity_model.dart';
import '../models/home_dashboard_model.dart';

class HomeDashboardState {
  final HomeDashboardModel? dashboardData;
  final BloodSugarLogModel? latestBloodSugar;
  final List<BloodSugarLogModel> bloodSugarLogs;
  final List<RecentActivityItem> recentActivities;
  final bool isLoading;
  final String? errorMessage;

  const HomeDashboardState({
    this.dashboardData,
    this.latestBloodSugar,
    this.bloodSugarLogs = const [],
    this.recentActivities = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  HomeDashboardState copyWith({
    HomeDashboardModel? dashboardData,
    BloodSugarLogModel? latestBloodSugar,
    List<BloodSugarLogModel>? bloodSugarLogs,
    List<RecentActivityItem>? recentActivities,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeDashboardState(
      dashboardData: dashboardData ?? this.dashboardData,
      latestBloodSugar: latestBloodSugar ?? this.latestBloodSugar,
      bloodSugarLogs: bloodSugarLogs ?? this.bloodSugarLogs,
      recentActivities: recentActivities ?? this.recentActivities,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class HomeDashboardNotifier extends AsyncNotifier<HomeDashboardState> {
  @override
  Future<HomeDashboardState> build() async {
    return _fetchData();
  }

  Future<HomeDashboardState> _fetchData() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final bloodSugarRepo = ref.read(bloodSugarRepositoryProvider);

      // Fetch patient profile & blood sugar history concurrently
      final results = await Future.wait([
        authRepo.getPatientProfile(),
        bloodSugarRepo.getBloodSugarHistory(limit: 20),
      ]);

      final profileJson = results[0] as Map<String, dynamic>;
      final bloodSugarLogs = results[1] as List<BloodSugarLogModel>;

      final dashboardData = HomeDashboardModel.fromJson(profileJson);
      final latestBs = bloodSugarLogs.isNotEmpty ? bloodSugarLogs.first : null;

      // Construct recent activities timeline from blood sugar logs
      final activities = <RecentActivityItem>[];
      for (final log in bloodSugarLogs) {
        final dt = DateTime.tryParse(log.measuredAt) ?? DateTime.now();

        Color statusCol = const Color(0xFF10B981);
        if (log.colorIndicator.startsWith('#')) {
          final hex = log.colorIndicator.replaceAll('#', '');
          if (hex.length == 6) {
            statusCol = Color(int.parse('FF$hex', radix: 16));
          }
        }

        activities.add(
          RecentActivityItem(
            id: log.id,
            category: ActivityCategory.bloodSugar,
            title: 'Pemeriksaan Gula Darah',
            description: '${log.glucoseValue} mg/dL • ${log.measurementTypeLabel}',
            timestamp: dt,
            statusLabel: log.classificationLabel,
            statusColor: statusCol,
            badgeText: '${log.glucoseValue} mg/dL',
          ),
        );
      }

      // Sort timeline newest to oldest
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return HomeDashboardState(
        dashboardData: dashboardData,
        latestBloodSugar: latestBs,
        bloodSugarLogs: bloodSugarLogs,
        recentActivities: activities,
        isLoading: false,
      );
    } catch (e) {
      return HomeDashboardState(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchData);
  }
}

final homeDashboardProvider =
    AsyncNotifierProvider<HomeDashboardNotifier, HomeDashboardState>(
  HomeDashboardNotifier.new,
);
