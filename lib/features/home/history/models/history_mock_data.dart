import 'package:intl/intl.dart';

enum HealthActivityStatus {
  completed,
  inProgress,
  noActivity,
}

class HealthActivityRecord {
  final DateTime date;
  final double? bloodSugar;
  final String? bloodSugarStatus;
  final int mealsRecorded;
  final int caloriesConsumed;
  final int caloriesTarget;
  final int physicalActivityMinutes;
  final bool medicationCompleted;
  final HealthActivityStatus? _explicitStatus;

  const HealthActivityRecord({
    required this.date,
    this.bloodSugar,
    this.bloodSugarStatus,
    this.mealsRecorded = 0,
    this.caloriesConsumed = 0,
    this.caloriesTarget = 2100,
    this.physicalActivityMinutes = 0,
    this.medicationCompleted = false,
    HealthActivityStatus? status,
  }) : _explicitStatus = status;

  int get recordedCategoriesCount {
    int count = 0;
    if (bloodSugar != null) count++;
    if (mealsRecorded > 0 || caloriesConsumed > 0) count++;
    if (physicalActivityMinutes > 0) count++;
    if (medicationCompleted) count++;
    return count;
  }

  double get progressRatio => (recordedCategoriesCount / 4.0).clamp(0.0, 1.0);

  HealthActivityStatus get status {
    if (_explicitStatus != null) return _explicitStatus!;
    final count = recordedCategoriesCount;
    if (count >= 4) return HealthActivityStatus.completed;
    if (count >= 1) return HealthActivityStatus.inProgress;
    return HealthActivityStatus.noActivity;
  }
}

abstract final class MockHistoryData {
  MockHistoryData._();

  static String _formatKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static HealthActivityRecord? getRecord(DateTime date) {
    final key = _formatKey(date);
    return _records[key];
  }

  // Pre-configured mock records
  static final Map<String, HealthActivityRecord> _records = {
    // December 2025
    '2025-12-25': HealthActivityRecord(
      date: DateTime(2025, 12, 25),
      bloodSugar: 115.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 3,
      caloriesConsumed: 1980,
      caloriesTarget: 2100,
      physicalActivityMinutes: 45,
      medicationCompleted: true,
      status: HealthActivityStatus.completed,
    ),
    '2025-12-31': HealthActivityRecord(
      date: DateTime(2025, 12, 31),
      bloodSugar: 130.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 2,
      caloriesConsumed: 1200,
      caloriesTarget: 2100,
      physicalActivityMinutes: 15,
      medicationCompleted: false,
      status: HealthActivityStatus.inProgress,
    ),

    // June 2026 (Day-by-Day Mock Calendar Data from prompt)
    '2026-06-01': HealthActivityRecord(
      date: DateTime(2026, 6, 1),
      bloodSugar: 110.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 3,
      caloriesConsumed: 1850,
      caloriesTarget: 2100,
      physicalActivityMinutes: 30,
      medicationCompleted: true,
      status: HealthActivityStatus.completed,
    ),
    '2026-06-02': HealthActivityRecord(
      date: DateTime(2026, 6, 2),
      bloodSugar: 118.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 3,
      caloriesConsumed: 1900,
      caloriesTarget: 2100,
      physicalActivityMinutes: 35,
      medicationCompleted: true,
      status: HealthActivityStatus.completed,
    ),
    // 2026-06-03: No Activity
    '2026-06-04': HealthActivityRecord(
      date: DateTime(2026, 6, 4),
      bloodSugar: 125.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 2,
      caloriesConsumed: 1350,
      caloriesTarget: 2100,
      physicalActivityMinutes: 15,
      medicationCompleted: false,
      status: HealthActivityStatus.inProgress,
    ),
    '2026-06-05': HealthActivityRecord(
      date: DateTime(2026, 6, 5),
      bloodSugar: 112.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 3,
      caloriesConsumed: 1800,
      caloriesTarget: 2100,
      physicalActivityMinutes: 40,
      medicationCompleted: true,
      status: HealthActivityStatus.completed,
    ),
    // 2026-06-06: No Activity
    '2026-06-07': HealthActivityRecord(
      date: DateTime(2026, 6, 7),
      bloodSugar: 108.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 3,
      caloriesConsumed: 1920,
      caloriesTarget: 2100,
      physicalActivityMinutes: 45,
      medicationCompleted: true,
      status: HealthActivityStatus.completed,
    ),
    // 2026-06-08: No Activity
    '2026-06-09': HealthActivityRecord(
      date: DateTime(2026, 6, 9),
      bloodSugar: 122.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 2,
      caloriesConsumed: 1250,
      caloriesTarget: 2100,
      physicalActivityMinutes: 20,
      medicationCompleted: false,
      status: HealthActivityStatus.inProgress,
    ),
    '2026-06-10': HealthActivityRecord(
      date: DateTime(2026, 6, 10),
      bloodSugar: 115.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 3,
      caloriesConsumed: 1880,
      caloriesTarget: 2100,
      physicalActivityMinutes: 30,
      medicationCompleted: true,
      status: HealthActivityStatus.completed,
    ),
    // 2026-06-11: No Activity
    '2026-06-12': HealthActivityRecord(
      date: DateTime(2026, 6, 12),
      bloodSugar: 120.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 3,
      caloriesConsumed: 1950,
      caloriesTarget: 2100,
      physicalActivityMinutes: 35,
      medicationCompleted: true,
      status: HealthActivityStatus.completed,
    ),
    // 2026-06-13: No Activity
    '2026-06-14': HealthActivityRecord(
      date: DateTime(2026, 6, 14),
      bloodSugar: 109.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 3,
      caloriesConsumed: 1800,
      caloriesTarget: 2100,
      physicalActivityMinutes: 30,
      medicationCompleted: true,
      status: HealthActivityStatus.completed,
    ),
    '2026-06-15': HealthActivityRecord(
      date: DateTime(2026, 6, 15),
      bloodSugar: 126.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 2,
      caloriesConsumed: 1400,
      caloriesTarget: 2100,
      physicalActivityMinutes: 15,
      medicationCompleted: false,
      status: HealthActivityStatus.inProgress,
    ),
    '2026-06-16': HealthActivityRecord(
      date: DateTime(2026, 6, 16),
      bloodSugar: 120.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 2,
      caloriesConsumed: 1850,
      caloriesTarget: 2000,
      physicalActivityMinutes: 30,
      medicationCompleted: true,
      status: HealthActivityStatus.inProgress, // Today / In Progress
    ),
    // 2026-06-17: No Activity
    '2026-06-18': HealthActivityRecord(
      date: DateTime(2026, 6, 18),
      bloodSugar: 117.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 3,
      caloriesConsumed: 1900,
      caloriesTarget: 2100,
      physicalActivityMinutes: 45,
      medicationCompleted: true,
      status: HealthActivityStatus.completed,
    ),
    // 2026-06-19: No Activity
    '2026-06-20': HealthActivityRecord(
      date: DateTime(2026, 6, 20),
      bloodSugar: 111.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 3,
      caloriesConsumed: 1820,
      caloriesTarget: 2100,
      physicalActivityMinutes: 30,
      medicationCompleted: true,
      status: HealthActivityStatus.completed,
    ),
    // 2026-06-21: No Activity
    '2026-06-22': HealthActivityRecord(
      date: DateTime(2026, 6, 22),
      bloodSugar: 114.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 3,
      caloriesConsumed: 1960,
      caloriesTarget: 2100,
      physicalActivityMinutes: 40,
      medicationCompleted: true,
      status: HealthActivityStatus.completed,
    ),
    '2026-06-23': HealthActivityRecord(
      date: DateTime(2026, 6, 23),
      bloodSugar: 128.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 2,
      caloriesConsumed: 1300,
      caloriesTarget: 2100,
      physicalActivityMinutes: 10,
      medicationCompleted: false,
      status: HealthActivityStatus.inProgress,
    ),
    // 2026-06-24: No Activity
    '2026-06-25': HealthActivityRecord(
      date: DateTime(2026, 6, 25),
      bloodSugar: 113.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 3,
      caloriesConsumed: 1890,
      caloriesTarget: 2100,
      physicalActivityMinutes: 35,
      medicationCompleted: true,
      status: HealthActivityStatus.completed,
    ),
    // 2026-06-26: No Activity
    '2026-06-27': HealthActivityRecord(
      date: DateTime(2026, 6, 27),
      bloodSugar: 110.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 3,
      caloriesConsumed: 1850,
      caloriesTarget: 2100,
      physicalActivityMinutes: 30,
      medicationCompleted: true,
      status: HealthActivityStatus.completed,
    ),
    // 2026-06-28: No Activity
    '2026-06-29': HealthActivityRecord(
      date: DateTime(2026, 6, 29),
      bloodSugar: 116.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 3,
      caloriesConsumed: 1920,
      caloriesTarget: 2100,
      physicalActivityMinutes: 40,
      medicationCompleted: true,
      status: HealthActivityStatus.completed,
    ),
    // 2026-06-30: No Activity

    // July 2026
    '2026-07-01': HealthActivityRecord(
      date: DateTime(2026, 7, 1),
      bloodSugar: 120.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 3,
      caloriesConsumed: 1850,
      caloriesTarget: 2000,
      physicalActivityMinutes: 30,
      medicationCompleted: true,
      status: HealthActivityStatus.completed,
    ),
    '2026-07-02': HealthActivityRecord(
      date: DateTime(2026, 7, 2),
      bloodSugar: 115.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 3,
      caloriesConsumed: 1900,
      caloriesTarget: 2100,
      physicalActivityMinutes: 40,
      medicationCompleted: true,
      status: HealthActivityStatus.completed,
    ),
    '2026-07-04': HealthActivityRecord(
      date: DateTime(2026, 7, 4),
      bloodSugar: 128.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 2,
      caloriesConsumed: 1400,
      caloriesTarget: 2100,
      physicalActivityMinutes: 15,
      medicationCompleted: false,
      status: HealthActivityStatus.inProgress,
    ),
    '2026-07-05': HealthActivityRecord(
      date: DateTime(2026, 7, 5),
      bloodSugar: 105.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 3,
      caloriesConsumed: 1800,
      caloriesTarget: 2100,
      physicalActivityMinutes: 60,
      medicationCompleted: true,
      status: HealthActivityStatus.completed,
    ),
    '2026-07-07': HealthActivityRecord(
      date: DateTime(2026, 7, 7),
      bloodSugar: 140.0,
      bloodSugarStatus: 'Tinggi',
      mealsRecorded: 2,
      caloriesConsumed: 1100,
      caloriesTarget: 2100,
      physicalActivityMinutes: 10,
      medicationCompleted: false,
      status: HealthActivityStatus.inProgress,
    ),
    '2026-07-09': HealthActivityRecord(
      date: DateTime(2026, 7, 9),
      bloodSugar: 118.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 3,
      caloriesConsumed: 2000,
      caloriesTarget: 2100,
      physicalActivityMinutes: 30,
      medicationCompleted: true,
      status: HealthActivityStatus.completed,
    ),
    '2026-07-20': HealthActivityRecord(
      date: DateTime(2026, 7, 20),
      bloodSugar: 112.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 3,
      caloriesConsumed: 1850,
      caloriesTarget: 2100,
      physicalActivityMinutes: 30,
      medicationCompleted: true,
      status: HealthActivityStatus.completed,
    ),
    '2026-07-21': HealthActivityRecord(
      date: DateTime(2026, 7, 21),
      bloodSugar: 128.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 3,
      caloriesConsumed: 1700,
      caloriesTarget: 2100,
      physicalActivityMinutes: 35,
      medicationCompleted: true,
      status: HealthActivityStatus.completed,
    ),
    '2026-07-22': HealthActivityRecord(
      date: DateTime(2026, 7, 22),
      bloodSugar: 118.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 2,
      caloriesConsumed: 950,
      caloriesTarget: 2100,
      physicalActivityMinutes: 15,
      medicationCompleted: false,
      status: HealthActivityStatus.inProgress,
    ),
    '2026-07-23': HealthActivityRecord(
      date: DateTime(2026, 7, 23),
      bloodSugar: 120.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 2,
      caloriesConsumed: 1200,
      caloriesTarget: 2100,
      physicalActivityMinutes: 10,
      medicationCompleted: false,
      status: HealthActivityStatus.inProgress,
    ),
    '2026-07-26': HealthActivityRecord(
      date: DateTime(2026, 7, 26),
      bloodSugar: 105.0,
      bloodSugarStatus: 'Normal',
      mealsRecorded: 3,
      caloriesConsumed: 2000,
      caloriesTarget: 2100,
      physicalActivityMinutes: 45,
      medicationCompleted: true,
      status: HealthActivityStatus.completed,
    ),
  };
}
