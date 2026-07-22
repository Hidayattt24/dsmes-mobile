import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum RecordType {
  all,
  bloodSugar,
  food,
  activity,
  medication,
}

extension RecordTypeExtension on RecordType {
  String get label {
    return switch (this) {
      RecordType.all => 'Semua',
      RecordType.bloodSugar => 'Gula Darah',
      RecordType.food => 'Makanan',
      RecordType.activity => 'Aktivitas',
      RecordType.medication => 'Obat',
    };
  }
}

@immutable
class TimelineRecordItem {
  final String id;
  final RecordType type;
  final String title;
  final String subtitle;
  final String time;
  final String dateText;
  final IconData icon;
  final Color dotOuterColor;
  final Color dotInnerColor;
  final String? badgeText;
  final Color? badgeBgColor;
  final Color? badgeTextColor;

  const TimelineRecordItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.dateText,
    required this.icon,
    required this.dotOuterColor,
    required this.dotInnerColor,
    this.badgeText,
    this.badgeBgColor,
    this.badgeTextColor,
  });
}

@immutable
class RecordState {
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

  const RecordState({
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
  });

  double get progressPercentage =>
      totalCount > 0 ? (completedCount / totalCount).clamp(0.0, 1.0) : 0.0;

  int get progressPercentageInt => (progressPercentage * 100).round();

  RecordState copyWith({
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
  }) {
    return RecordState(
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
    );
  }
}

/// Mock prototype dataset for history browsing
abstract class MockRecordHistoryData {
  MockRecordHistoryData._();

  static final DateTime today = DateTime(2026, 7, 23);
  static final DateTime yesterday = DateTime(2026, 7, 22);
  static final DateTime lastTuesday = DateTime(2026, 7, 21);
  static final DateTime threeDaysAgo = DateTime(2026, 7, 20);
  static final DateTime fourDaysAgo = DateTime(2026, 7, 19);

  static final List<TimelineRecordItem> yesterdayRecords = [
    const TimelineRecordItem(
      id: 'y_1',
      type: RecordType.medication,
      title: 'Minum Obat',
      subtitle: 'Metformin 500mg',
      time: '08:00',
      dateText: '22 Jul 2026',
      icon: Icons.medication_outlined,
      dotOuterColor: AppColors.surfaceContainerHighest,
      dotInnerColor: AppColors.outline,
      badgeText: 'Tepat Waktu',
      badgeBgColor: AppColors.secondaryContainer,
      badgeTextColor: AppColors.onSecondaryContainer,
    ),
    const TimelineRecordItem(
      id: 'y_2',
      type: RecordType.food,
      title: 'Sarapan',
      subtitle: '520 kcal • Nasi uduk, telur',
      time: '09:00',
      dateText: '22 Jul 2026',
      icon: Icons.restaurant_outlined,
      dotOuterColor: AppColors.tertiaryFixed,
      dotInnerColor: AppColors.tertiary,
    ),
    const TimelineRecordItem(
      id: 'y_3',
      type: RecordType.bloodSugar,
      title: 'Gula Darah',
      subtitle: '120 mg/dL • Sebelum Sarapan',
      time: '11:30',
      dateText: '22 Jul 2026',
      icon: Icons.water_drop_outlined,
      dotOuterColor: AppColors.errorContainer,
      dotInnerColor: AppColors.error,
      badgeText: 'Normal',
      badgeBgColor: AppColors.secondaryContainer,
      badgeTextColor: AppColors.onSecondaryContainer,
    ),
    const TimelineRecordItem(
      id: 'y_4',
      type: RecordType.activity,
      title: 'Jalan Santai',
      subtitle: '30 Menit • Sore hari',
      time: '16:00',
      dateText: '22 Jul 2026',
      icon: Icons.directions_walk_outlined,
      dotOuterColor: AppColors.secondaryFixed,
      dotInnerColor: AppColors.secondary,
      badgeText: 'Ringan',
      badgeBgColor: AppColors.primaryContainer,
      badgeTextColor: AppColors.onPrimaryContainer,
    ),
  ];

  static final List<TimelineRecordItem> lastTuesdayRecords = [
    const TimelineRecordItem(
      id: 't_1',
      type: RecordType.bloodSugar,
      title: 'Gula Darah Puasa',
      subtitle: '118 mg/dL • Setelah bangun tidur',
      time: '07:00',
      dateText: '21 Jul 2026',
      icon: Icons.water_drop_outlined,
      dotOuterColor: AppColors.errorContainer,
      dotInnerColor: AppColors.error,
      badgeText: 'Normal',
      badgeBgColor: AppColors.secondaryContainer,
      badgeTextColor: AppColors.onSecondaryContainer,
    ),
    const TimelineRecordItem(
      id: 't_2',
      type: RecordType.medication,
      title: 'Minum Obat',
      subtitle: 'Metformin 500mg',
      time: '08:00',
      dateText: '21 Jul 2026',
      icon: Icons.medication_outlined,
      dotOuterColor: AppColors.surfaceContainerHighest,
      dotInnerColor: AppColors.outline,
      badgeText: 'Tepat Waktu',
      badgeBgColor: AppColors.secondaryContainer,
      badgeTextColor: AppColors.onSecondaryContainer,
    ),
    const TimelineRecordItem(
      id: 't_3',
      type: RecordType.activity,
      title: 'Bersepeda',
      subtitle: '45 Menit • Pagi hari',
      time: '17:00',
      dateText: '21 Jul 2026',
      icon: Icons.directions_bike_outlined,
      dotOuterColor: AppColors.secondaryFixed,
      dotInnerColor: AppColors.secondary,
      badgeText: 'Sedang',
      badgeBgColor: AppColors.primaryContainer,
      badgeTextColor: AppColors.onPrimaryContainer,
    ),
  ];

  static final List<TimelineRecordItem> threeDaysAgoRecords = [
    const TimelineRecordItem(
      id: 'th_1',
      type: RecordType.bloodSugar,
      title: 'Gula Darah Puasa',
      subtitle: '115 mg/dL',
      time: '07:30',
      dateText: '20 Jul 2026',
      icon: Icons.water_drop_outlined,
      dotOuterColor: AppColors.errorContainer,
      dotInnerColor: AppColors.error,
      badgeText: 'Normal',
      badgeBgColor: AppColors.secondaryContainer,
      badgeTextColor: AppColors.onSecondaryContainer,
    ),
    const TimelineRecordItem(
      id: 'th_2',
      type: RecordType.medication,
      title: 'Minum Obat',
      subtitle: 'Metformin 500mg',
      time: '08:00',
      dateText: '20 Jul 2026',
      icon: Icons.medication_outlined,
      dotOuterColor: AppColors.surfaceContainerHighest,
      dotInnerColor: AppColors.outline,
      badgeText: 'Tepat Waktu',
      badgeBgColor: AppColors.secondaryContainer,
      badgeTextColor: AppColors.onSecondaryContainer,
    ),
    const TimelineRecordItem(
      id: 'th_3',
      type: RecordType.food,
      title: 'Makan Siang',
      subtitle: '650 kcal • Ayam Bakar, Nasi Merah',
      time: '12:30',
      dateText: '20 Jul 2026',
      icon: Icons.restaurant_outlined,
      dotOuterColor: AppColors.tertiaryFixed,
      dotInnerColor: AppColors.tertiary,
    ),
  ];

  static List<TimelineRecordItem> getRecordsForDate(DateTime date) {
    if (isSameDate(date, yesterday)) return yesterdayRecords;
    if (isSameDate(date, lastTuesday)) return lastTuesdayRecords;
    if (isSameDate(date, threeDaysAgo)) return threeDaysAgoRecords;
    return const [];
  }

  static bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
