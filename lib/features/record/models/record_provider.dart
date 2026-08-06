import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/repositories/blood_sugar_repository.dart';
import '../../../data/repositories/history_repository.dart';
import '../../../data/repositories/measurement_repository.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../home/history/models/history_item_model.dart';
import '../../home/history/viewmodels/history_provider.dart';
import '../../home/viewmodels/home_dashboard_notifier.dart';
import '../../home/reminders/models/reminder_model.dart';
import 'record_entry.dart';

class RecordPageState {
  final DateTime? selectedDate;
  final RecordType selectedFilter;
  final int completedCount;
  final int totalCount;
  final String bloodSugarValue;
  final String bloodSugarSubtitle;
  final String foodValue;
  final String foodSubtitle;
  final String activityName;
  final int activityDuration;
  final String activityIntensity;
  final String medicationName;
  final String medicationDosage;
  final String medicationSchedule;
  final bool isMedicationTaken;
  final List<TimelineRecordItem> todayTimelineItems;
  final List<HistoryItemModel> allHistoryItems;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  const RecordPageState({
    this.selectedDate,
    this.selectedFilter = RecordType.all,
    this.completedCount = 0,
    this.totalCount = 4,
    this.bloodSugarValue = '-',
    this.bloodSugarSubtitle = 'Belum dicatat',
    this.foodValue = '0',
    this.foodSubtitle = 'Belum dicatat',
    this.activityName = 'Jalan Santai',
    this.activityDuration = 0,
    this.activityIntensity = 'Ringan',
    this.medicationName = 'Metformin',
    this.medicationDosage = '500 mg',
    this.medicationSchedule = '08:00',
    this.isMedicationTaken = false,
    this.todayTimelineItems = const [],
    this.allHistoryItems = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  double get progressPercentage =>
      totalCount > 0 ? (completedCount / totalCount).clamp(0.0, 1.0) : 0.0;

  int get progressPercentageInt => (progressPercentage * 100).round();

  RecordPageState copyWith({
    DateTime? selectedDate,
    RecordType? selectedFilter,
    int? completedCount,
    int? totalCount,
    String? bloodSugarValue,
    String? bloodSugarSubtitle,
    String? foodValue,
    String? foodSubtitle,
    String? activityName,
    int? activityDuration,
    String? activityIntensity,
    String? medicationName,
    String? medicationDosage,
    String? medicationSchedule,
    bool? isMedicationTaken,
    List<TimelineRecordItem>? todayTimelineItems,
    List<HistoryItemModel>? allHistoryItems,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RecordPageState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      completedCount: completedCount ?? this.completedCount,
      totalCount: totalCount ?? this.totalCount,
      bloodSugarValue: bloodSugarValue ?? this.bloodSugarValue,
      bloodSugarSubtitle: bloodSugarSubtitle ?? this.bloodSugarSubtitle,
      foodValue: foodValue ?? this.foodValue,
      foodSubtitle: foodSubtitle ?? this.foodSubtitle,
      activityName: activityName ?? this.activityName,
      activityDuration: activityDuration ?? this.activityDuration,
      activityIntensity: activityIntensity ?? this.activityIntensity,
      medicationName: medicationName ?? this.medicationName,
      medicationDosage: medicationDosage ?? this.medicationDosage,
      medicationSchedule: medicationSchedule ?? this.medicationSchedule,
      isMedicationTaken: isMedicationTaken ?? this.isMedicationTaken,
      todayTimelineItems: todayTimelineItems ?? this.todayTimelineItems,
      allHistoryItems: allHistoryItems ?? this.allHistoryItems,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class RecordNotifier extends StateNotifier<RecordPageState> {
  final Ref _ref;

  RecordNotifier(this._ref) : super(const RecordPageState());

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final historyRepo = _ref.read(historyRepositoryProvider);
      final reminderRepo = _ref.read(reminderRepositoryProvider);

      final results = await Future.wait([
        historyRepo.getPatientHistory(page: 1, limit: 100),
        reminderRepo.list(),
      ]);

      final historyResult = results[0] as HistoryListResult;
      final reminders = results[1] as List<ReminderModel>;

      final allItems = historyResult.items;

      // Build timeline from history
      final targetDate = state.selectedDate ?? DateTime.now();
      final todayItems = _buildTimelineItems(allItems, targetDate);

      // Compute summary for target date
      final todayAgg = _computeTodaySummary(allItems, targetDate);

      // Compute medication info from history + reminders
      final medReminder = reminders.where((r) => r.category == 'medis_obat').toList();
      String medName = 'Obat';
      String medDosage = '';
      String medSchedule = '08:00';
      bool isMedTaken = false;

      // Prioritize latest actual medication log from history
      final targetDateStr = _dateKey(targetDate);
      final medLogs = allItems.where((item) => item.activityType == 'medication').toList();

      if (medLogs.isNotEmpty) {
        final latestMed = medLogs.first;
        if (latestMed.title.isNotEmpty) medName = latestMed.title;
        if (latestMed.notes.isNotEmpty) {
          medDosage = latestMed.notes;
        } else if (latestMed.subtitle.isNotEmpty && !['selesai', 'pending', 'terlewat'].contains(latestMed.subtitle)) {
          medDosage = latestMed.subtitle;
        }
        if (latestMed.parsedMeasuredAt != null) {
          final dt = latestMed.parsedMeasuredAt!;
          medSchedule = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        }
      } else if (medReminder.isNotEmpty) {
        medName = medReminder.first.activityName;
        medSchedule = medReminder.first.formattedTime;
        medDosage = medReminder.first.notes;
      }

      for (final item in medLogs) {
        final dt = item.parsedMeasuredAt;
        if (dt == null) continue;
        if (_dateKey(dt) != targetDateStr) continue;
        if (item.status == 'selesai' || item.status == 'Sudah Minum') {
          isMedTaken = true;
        }
      }

      state = RecordPageState(
        selectedDate: state.selectedDate ?? DateTime.now(),
        selectedFilter: state.selectedFilter,
        completedCount: todayAgg.completedCount,
        totalCount: todayAgg.totalCount > 0 ? todayAgg.totalCount : 4,
        bloodSugarValue: todayAgg.bloodSugarValue,
        bloodSugarSubtitle: todayAgg.bloodSugarSubtitle,
        foodValue: todayAgg.foodValue,
        foodSubtitle: todayAgg.foodSubtitle,
        activityName: todayAgg.activityName,
        activityDuration: todayAgg.activityDuration,
        activityIntensity: todayAgg.activityIntensity,
        medicationName: medName,
        medicationDosage: medDosage,
        medicationSchedule: medSchedule,
        isMedicationTaken: isMedTaken,
        todayTimelineItems: todayItems,
        allHistoryItems: allItems,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _formatError(e),
      );
    }
  }

  _TodaySummary _computeTodaySummary(List<HistoryItemModel> allItems, DateTime today) {
    final todayStr = _dateKey(today);
    String bsValue = '-';
    String bsSubtitle = 'Belum dicatat';
    String foodVal = '0';
    String foodSub = 'Belum dicatat';
    String actName = 'Belum dicatat';
    int actDuration = 0;
    String actIntensity = '';
    int completedCount = 0;
    int totalCount = 0;

    final categories = <String>{};
    bool medCompleted = false;
    for (final item in allItems) {
      final dt = item.parsedMeasuredAt;
      if (dt == null) continue;
      if (_dateKey(dt) != todayStr) continue;

      categories.add(item.activityType);

      switch (item.activityType) {
        case 'blood_sugar':
          bsValue = item.value;
          bsSubtitle = item.subtitle;
          break;
        case 'meal':
          foodVal = item.value;
          foodSub = item.title;
          break;
        case 'activity':
          actName = item.title;
          actDuration = (item.metadata['activity_minutes'] as num?)?.toInt() ?? 30;
          actIntensity = item.category;
          break;
        case 'medication':
          if (item.status == 'selesai') medCompleted = true;
          break;
      }
    }

    if (categories.contains('blood_sugar')) completedCount++;
    if (categories.contains('meal')) completedCount++;
    if (categories.contains('activity')) completedCount++;
    if (categories.contains('medication') && medCompleted) completedCount++;
    totalCount = categories.length;

    return _TodaySummary(
      bloodSugarValue: bsValue,
      bloodSugarSubtitle: bsSubtitle,
      foodValue: foodVal,
      foodSubtitle: foodSub,
      activityName: actName,
      activityDuration: actDuration,
      activityIntensity: actIntensity,
      completedCount: completedCount,
      totalCount: 4,
    );
  }

  List<TimelineRecordItem> _buildTimelineItems(List<HistoryItemModel> items, DateTime date) {
    final dateStr = _dateKey(date);
    final filtered = items.where((item) {
      final dt = item.parsedMeasuredAt;
      return dt != null && _dateKey(dt) == dateStr;
    }).toList();

    return filtered.map((item) {
      final icon = _iconForType(item.activityType);
      final (outer, inner) = _colorsForType(item.activityType);

      String subtitle = item.subtitle;
      if (item.activityType == 'blood_sugar') {
        subtitle = '${item.value} mg/dL • ${item.subtitle}';
      }

      final badgeText = _badgeForActivity(item.activityType, item.status);

      return TimelineRecordItem(
        id: item.id,
        type: _recordTypeFromActivity(item.activityType),
        title: item.title,
        subtitle: subtitle,
        time: _formatTime(item.parsedMeasuredAt),
        dateText: _formatDate(item.parsedMeasuredAt!),
        icon: icon,
        dotOuterColor: outer,
        dotInnerColor: inner,
        badgeText: badgeText,
      );
    }).toList();
  }

  String _dateKey(DateTime dt) => '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String? _badgeForActivity(String activityType, String status) {
    if (activityType == 'medication') {
      switch (status) {
        case 'selesai':
          return 'Sudah Minum';
        case 'pending':
          return 'Belum Minum';
        case 'terlewat':
          return 'Terlewat';
        default:
          return status;
      }
    }
    if (activityType == 'activity') {
      if (status == 'Completed') return 'Selesai';
      if (status == 'Pending' || status == 'Skipped') return 'Belum Melakukan';
    }
    return status.isNotEmpty ? status : null;
  }

  RecordType _recordTypeFromActivity(String activityType) {
    switch (activityType) {
      case 'blood_sugar':
        return RecordType.bloodSugar;
      case 'meal':
        return RecordType.food;
      case 'activity':
        return RecordType.activity;
      case 'medication':
        return RecordType.medication;
      default:
        return RecordType.all;
    }
  }

  IconData _iconForType(String activityType) {
    switch (activityType) {
      case 'blood_sugar':
        return Icons.water_drop_outlined;
      case 'meal':
        return Icons.restaurant_outlined;
      case 'activity':
        return Icons.directions_walk_outlined;
      case 'medication':
        return Icons.medication_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  (Color, Color) _colorsForType(String activityType) {
    switch (activityType) {
      case 'blood_sugar':
        return (const Color(0xFFFFEBEE), const Color(0xFFD32F2F));
      case 'meal':
        return (const Color(0xFFFFF3E0), const Color(0xFFE65100));
      case 'activity':
        return (const Color(0xFFE8F5E9), const Color(0xFF388E3C));
      case 'medication':
        return (const Color(0xFFF3E5F5), const Color(0xFF6B21A8));
      default:
        return (const Color(0xFFE0E0E0), const Color(0xFF757575));
    }
  }

  void setSelectedDate(DateTime date) {
    final dateAgg = _computeTodaySummary(state.allHistoryItems, date);
    final filtered = _buildTimelineItems(state.allHistoryItems, date);
    state = state.copyWith(
      selectedDate: date,
      completedCount: dateAgg.completedCount,
      totalCount: 4,
      todayTimelineItems: filtered,
    );
  }

  void setSelectedFilter(RecordType filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  Future<bool> submitBloodSugar({
    required int glucoseValue,
    required String measurementType,
    required DateTime measuredAt,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final repo = _ref.read(bloodSugarRepositoryProvider);
      await repo.logBloodSugar(
        glucoseValue: glucoseValue,
        measurementType: measurementType,
        measuredAt: measuredAt,
      );
      state = state.copyWith(isSubmitting: false);
      await loadData();
      _ref.read(historyProvider.notifier).refresh();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _formatError(e),
      );
      return false;
    }
  }

  Future<bool> submitActivity({
    required String activityName,
    required int duration,
    required String intensity,
    String notes = '',
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final dio = _ref.read(dioClientProvider);
      await dio.post('/patient/activities/log', data: {
        'activity_name': activityName,
        'duration_minutes': duration,
        'intensity': intensity,
        'notes': notes,
        'logged_at': DateTime.now().toUtc().toIso8601String(),
      });
      state = state.copyWith(isSubmitting: false);
      await loadData();
      _ref.read(historyProvider.notifier).refresh();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _formatError(e),
      );
      return false;
    }
  }

  Future<bool> submitMedication({
    required String medicationName,
    required String dosage,
    required String schedule,
    required bool isTaken,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final formattedSched = schedule.length == 5 ? '$schedule:00' : schedule;
      final reminderRepo = _ref.read(reminderRepositoryProvider);
      final reminders = await reminderRepo.list();

      // Match by name first, fall back to any medis_obat reminder
      final byName = reminders.where((r) =>
          r.category == 'medis_obat' &&
          r.activityName.toLowerCase() == medicationName.toLowerCase()).toList();
      String reminderId;
      if (byName.isNotEmpty) {
        reminderId = byName.first.id;
        final existingRem = byName.first;
        if (existingRem.notes != dosage || existingRem.scheduledTime != formattedSched) {
          await reminderRepo.update(
            reminderId,
            activityName: medicationName,
            category: 'medis_obat',
            scheduledTime: formattedSched,
            notes: dosage,
            activeDays: existingRem.activeDays.isEmpty ? [1, 2, 3, 4, 5, 6, 7] : existingRem.activeDays,
          );
        }
      } else {
        // Create a new reminder for this medication name
        final created = await reminderRepo.create(
          activityName: medicationName,
          category: 'medis_obat',
          scheduledTime: formattedSched,
          notes: dosage,
          activeDays: [1, 2, 3, 4, 5, 6, 7],
        );
        reminderId = created.id;
      }

      final dio = _ref.read(dioClientProvider);
      await dio.post('/patient/medications/log', data: {
        'reminder_id': reminderId,
        'status': isTaken ? 'selesai' : 'pending',
        'log_date': DateTime.now().toIso8601String().substring(0, 10),
      });
      state = state.copyWith(isSubmitting: false);
      await loadData();
      _ref.read(historyProvider.notifier).refresh();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _formatError(e),
      );
      return false;
    }
  }

  Future<bool> createMeasurement({
    double? weightKg,
    double? heightCm,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    double? waistCircumferenceCm,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final repo = _ref.read(measurementRepositoryProvider);
      await repo.createMeasurement(
        weightKg: weightKg,
        heightCm: heightCm,
        bloodPressureSystolic: bloodPressureSystolic,
        bloodPressureDiastolic: bloodPressureDiastolic,
        waistCircumferenceCm: waistCircumferenceCm,
      );
      state = state.copyWith(isSubmitting: false);
      await loadData();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _formatError(e),
      );
      return false;
    }
  }

  Future<bool> deleteHistoryItem(RecordType type, String id) async {
    try {
      final dio = _ref.read(dioClientProvider);
      final typeStr = switch (type) {
        RecordType.bloodSugar => 'blood_sugar',
        RecordType.food => 'meal',
        RecordType.activity => 'activity',
        RecordType.medication => 'medication',
        RecordType.all => 'all',
      };
      await dio.delete('/patient/history/$typeStr/$id');
      await loadData();
      _ref.read(historyProvider.notifier).refresh();
      _ref.read(homeDashboardProvider.notifier).refresh();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: _formatError(e));
      return false;
    }
  }

  Future<bool> deleteBloodSugar(String id) async {
    return deleteHistoryItem(RecordType.bloodSugar, id);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<bool> updateBloodSugar({
    required String id,
    required int glucoseValue,
    required String measurementType,
    required String measuredAt,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final dio = _ref.read(dioClientProvider);
      await dio.put('/patient/blood-sugar/$id', data: {
        'glucose_value': glucoseValue,
        'measurement_time_type': measurementType,
        'measured_at': measuredAt,
      });
      state = state.copyWith(isSubmitting: false);
      await loadData();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _formatError(e),
      );
      return false;
    }
  }

  String _formatError(Object e) {
    if (e is ApiException) return e.message;
    return e.toString().replaceFirst('Exception: ', '');
  }
}

class _TodaySummary {
  final String bloodSugarValue;
  final String bloodSugarSubtitle;
  final String foodValue;
  final String foodSubtitle;
  final String activityName;
  final int activityDuration;
  final String activityIntensity;
  final int completedCount;
  final int totalCount;

  const _TodaySummary({
    required this.bloodSugarValue,
    required this.bloodSugarSubtitle,
    required this.foodValue,
    required this.foodSubtitle,
    required this.activityName,
    required this.activityDuration,
    required this.activityIntensity,
    required this.completedCount,
    required this.totalCount,
  });
}

final recordProvider = StateNotifierProvider<RecordNotifier, RecordPageState>((ref) {
  return RecordNotifier(ref);
});
