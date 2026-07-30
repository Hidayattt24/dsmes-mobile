class MeasurementModel {
  final String id;
  final String patientId;
  final double? weightKg;
  final double? heightCm;
  final double? bmi;
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;
  final int? bloodSugar;
  final double? waistCircumferenceCm;
  final int? dailyCalorieTarget;
  final String notes;
  final String recordedByName;
  final String recordedByRole;
  final String measuredAt;
  final String createdAt;

  const MeasurementModel({
    required this.id,
    required this.patientId,
    this.weightKg,
    this.heightCm,
    this.bmi,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.bloodSugar,
    this.waistCircumferenceCm,
    this.dailyCalorieTarget,
    this.notes = '',
    this.recordedByName = '',
    this.recordedByRole = '',
    required this.measuredAt,
    required this.createdAt,
  });

  factory MeasurementModel.fromJson(Map<String, dynamic> json) {
    return MeasurementModel(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      bloodPressureSystolic: (json['blood_pressure_systolic'] as num?)?.toInt(),
      bloodPressureDiastolic:
          (json['blood_pressure_diastolic'] as num?)?.toInt(),
      bloodSugar: (json['blood_sugar'] as num?)?.toInt(),
      waistCircumferenceCm:
          (json['waist_circumference_cm'] as num?)?.toDouble(),
      dailyCalorieTarget: (json['daily_calorie_target'] as num?)?.toInt(),
      notes: json['notes'] as String? ?? '',
      recordedByName: json['recorded_by_name'] as String? ?? '',
      recordedByRole: json['recorded_by_role'] as String? ?? '',
      measuredAt: json['measured_at'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}
