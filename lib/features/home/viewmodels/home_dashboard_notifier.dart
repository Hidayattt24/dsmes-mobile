import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/blood_sugar_repository.dart';
import '../blood_sugar/models/blood_sugar_log_model.dart';
import '../models/home_dashboard_model.dart';

class HomeDashboardState {
  final HomeDashboardModel? dashboardData;
  final BloodSugarLogModel? latestBloodSugar;
  final List<BloodSugarLogModel> bloodSugarLogs;
  final bool isLoading;
  final String? errorMessage;

  const HomeDashboardState({
    this.dashboardData,
    this.latestBloodSugar,
    this.bloodSugarLogs = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  HomeDashboardState copyWith({
    HomeDashboardModel? dashboardData,
    BloodSugarLogModel? latestBloodSugar,
    List<BloodSugarLogModel>? bloodSugarLogs,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeDashboardState(
      dashboardData: dashboardData ?? this.dashboardData,
      latestBloodSugar: latestBloodSugar ?? this.latestBloodSugar,
      bloodSugarLogs: bloodSugarLogs ?? this.bloodSugarLogs,
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

      final results = await Future.wait([
        authRepo.getPatientProfile(),
        bloodSugarRepo.getBloodSugarHistory(limit: 20),
      ]);

      final profileJson = results[0] as Map<String, dynamic>;
      final bloodSugarLogs = results[1] as List<BloodSugarLogModel>;

      final dashboardData = HomeDashboardModel.fromJson(profileJson);
      final latestBs = bloodSugarLogs.isNotEmpty ? bloodSugarLogs.first : null;

      return HomeDashboardState(
        dashboardData: dashboardData,
        latestBloodSugar: latestBs,
        bloodSugarLogs: bloodSugarLogs,
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
