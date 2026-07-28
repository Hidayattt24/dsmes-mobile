class HistoryItemModel {
  final String id;
  final String patientId;
  final String activityType;
  final String title;
  final String subtitle;
  final String category;
  final String value;
  final String unit;
  final String status;
  final String notes;
  final String measuredAt;
  final String createdAt;
  final String updatedAt;
  final String recordedBy;
  final String icon;
  final String color;
  final Map<String, dynamic> metadata;

  const HistoryItemModel({
    required this.id,
    required this.patientId,
    required this.activityType,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.value,
    required this.unit,
    required this.status,
    required this.notes,
    required this.measuredAt,
    required this.createdAt,
    required this.updatedAt,
    this.recordedBy = '',
    this.icon = '',
    this.color = '',
    this.metadata = const {},
  });

  DateTime? get parsedMeasuredAt => DateTime.tryParse(measuredAt)?.toLocal();
  DateTime? get parsedCreatedAt => DateTime.tryParse(createdAt)?.toLocal();

  String get activityTypeLabel {
    switch (activityType) {
      case 'blood_sugar':
        return 'Gula Darah';
      case 'meal':
        return 'Makanan';
      case 'activity':
        return 'Aktivitas';
      case 'medication':
        return 'Obat';
      case 'measurement':
        return 'Pengukuran';
      default:
        return 'Lainnya';
    }
  }

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) {
    return HistoryItemModel(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      activityType: json['activity_type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      category: json['category'] as String? ?? '',
      value: json['value'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      status: json['status'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      measuredAt: json['measured_at'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      recordedBy: json['recorded_by'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      color: json['color'] as String? ?? '',
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}

class DailyHistoryAggregate {
  final DateTime date;
  final List<HistoryItemModel> items;

  const DailyHistoryAggregate({
    required this.date,
    required this.items,
  });

  bool get hasBloodSugar => items.any((i) => i.activityType == 'blood_sugar');
  bool get hasMeal => items.any((i) => i.activityType == 'meal');
  bool get hasActivity => items.any((i) => i.activityType == 'activity');
  bool get hasMedication => items.any((i) => i.activityType == 'medication');
  bool get hasMeasurement => items.any((i) => i.activityType == 'measurement');

  int get recordedCategoriesCount {
    int count = 0;
    if (hasBloodSugar) count++;
    if (hasMeal) count++;
    if (hasActivity) count++;
    if (hasMedication) count++;
    return count;
  }

  double get progressRatio => (recordedCategoriesCount / 4.0).clamp(0.0, 1.0);

  bool get isFullyCompleted => recordedCategoriesCount >= 4;
  bool get hasAnyActivity => items.isNotEmpty;

  String? get latestBloodSugarValue {
    final bsItems = items.where((i) => i.activityType == 'blood_sugar').toList();
    if (bsItems.isEmpty) return null;
    bsItems.sort((a, b) => b.parsedMeasuredAt!.compareTo(a.parsedMeasuredAt!));
    return bsItems.first.value;
  }

  String? get latestBloodSugarStatus {
    final bsItems = items.where((i) => i.activityType == 'blood_sugar').toList();
    if (bsItems.isEmpty) return null;
    bsItems.sort((a, b) => b.parsedMeasuredAt!.compareTo(a.parsedMeasuredAt!));
    return bsItems.first.status;
  }

  String? get latestBloodSugarColor {
    final bsItems = items.where((i) => i.activityType == 'blood_sugar').toList();
    if (bsItems.isEmpty) return null;
    bsItems.sort((a, b) => b.parsedMeasuredAt!.compareTo(a.parsedMeasuredAt!));
    return bsItems.first.color;
  }

  int get mealsRecorded => items.where((i) => i.activityType == 'meal').length;
  double get totalCaloriesConsumed {
    double total = 0;
    for (final item in items.where((i) => i.activityType == 'meal')) {
      total += double.tryParse(item.value) ?? 0;
    }
    return total;
  }

  int get totalActivityMinutes {
    int total = 0;
    for (final item in items.where((i) => i.activityType == 'activity')) {
      total += (item.metadata['activity_minutes'] as num?)?.toInt() ?? 0;
    }
    return total;
  }

  bool get medicationCompleted {
    return items.any((i) => i.activityType == 'medication' && i.status == 'selesai');
  }

  bool get medicationPartiallyCompleted {
    return items.any((i) => i.activityType == 'medication');
  }
}
