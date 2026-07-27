class BloodSugarLogModel {
  final String id;
  final String patientId;
  final int glucoseValue;
  final String measurementType;
  final String measurementTypeLabel;
  final String measuredAt;
  final String status;
  final String classificationLabel;
  final String severity;
  final int referenceMin;
  final int referenceMax;
  final String referenceRangeText;
  final String recommendation;
  final String colorIndicator;
  final String createdAt;
  final String updatedAt;

  const BloodSugarLogModel({
    required this.id,
    required this.patientId,
    required this.glucoseValue,
    required this.measurementType,
    required this.measurementTypeLabel,
    required this.measuredAt,
    required this.status,
    required this.classificationLabel,
    required this.severity,
    required this.referenceMin,
    required this.referenceMax,
    required this.referenceRangeText,
    required this.recommendation,
    required this.colorIndicator,
    required this.createdAt,
    required this.updatedAt,
  });

  String get formattedTimeAndType {
    final dt = DateTime.tryParse(measuredAt);
    if (dt == null) return '$measurementTypeLabel • $referenceRangeText';

    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final hourStr = dt.hour.toString().padLeft(2, '0');
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final timeStr = '$hourStr:$minuteStr WIB';

    if (isToday) {
      return 'Hari ini, $timeStr • $measurementTypeLabel';
    }
    final dayStr = dt.day.toString().padLeft(2, '0');
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final monthStr = monthNames[dt.month - 1];
    return '$dayStr $monthStr ${dt.year}, $timeStr • $measurementTypeLabel';
  }

  factory BloodSugarLogModel.fromJson(Map<String, dynamic> json) {
    return BloodSugarLogModel(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      glucoseValue: (json['glucose_value'] as num?)?.toInt() ?? 0,
      measurementType: json['measurement_time_type'] as String? ?? 'random',
      measurementTypeLabel: json['measurement_time_label'] as String? ?? 'Sewaktu',
      measuredAt: json['measured_at'] as String? ?? '',
      status: json['status'] as String? ?? 'normal',
      classificationLabel: json['classification_label'] as String? ?? 'Normal',
      severity: json['severity'] as String? ?? 'normal',
      referenceMin: (json['reference_min'] as num?)?.toInt() ?? 70,
      referenceMax: (json['reference_max'] as num?)?.toInt() ?? 140,
      referenceRangeText: json['reference_range_text'] as String? ?? '< 140 mg/dL',
      recommendation: json['recommendation'] as String? ?? '',
      colorIndicator: json['color_indicator'] as String? ?? '#10B981',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}
