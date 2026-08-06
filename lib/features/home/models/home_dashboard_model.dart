
class HomeDashboardModel {
  final String patientId;
  final String fullName;
  final String nickname;
  final String gender;
  final double heightCm;
  final double weightKg;
  final double? bmi;
  final String? bmiCategory;
  final int dailyCalorieTarget;
  final int? latestBloodSugar;
  final String? latestBloodSugarTime;
  final String? latestBloodSugarStatus;
  final String? latestBloodSugarType;
  final String? latestBloodSugarTypeLabel;
  final String? latestBloodSugarSeverity;
  final String? latestBloodSugarRangeText;
  final String? latestBloodSugarRecommendation;
  final String? latestBloodSugarColor;
  final double? averageBloodSugar;
  final String? profilePhotoUrl;
  final String? latestBloodPressure;
  final String? lastMeasuredDate;

  const HomeDashboardModel({
    required this.patientId,
    required this.fullName,
    required this.nickname,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    this.profilePhotoUrl,
    this.bmi,
    this.bmiCategory,
    this.dailyCalorieTarget = 2000,
    this.latestBloodSugar,
    this.latestBloodSugarTime,
    this.latestBloodSugarStatus,
    this.latestBloodSugarType,
    this.latestBloodSugarTypeLabel,
    this.latestBloodSugarSeverity,
    this.latestBloodSugarRangeText,
    this.latestBloodSugarRecommendation,
    this.latestBloodSugarColor,
    this.averageBloodSugar,
    this.latestBloodPressure,
    this.lastMeasuredDate,
  });

  String get displayName => nickname.isNotEmpty ? nickname : fullName;

  String get greetingText {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      return 'Selamat Pagi,';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang,';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore,';
    } else {
      return 'Selamat Malam,';
    }
  }

  /// Returns the backend-generated recommendation message. If no reading exists
  /// yet, falls back to a generic encouragement. The backend classifier already
  /// accounts for measurement type (GDP/GD2PP/GDS) and patient age.
  String get motivationalMessage {
    if (latestBloodSugarRecommendation != null &&
        latestBloodSugarRecommendation!.isNotEmpty) {
      return latestBloodSugarRecommendation!;
    }
    if (latestBloodSugar == null) {
      return 'Ayo catat gula darah Anda untuk memantau kesehatan hari ini!';
    }
    return 'Pertahankan pemantauan gula darah Anda secara rutin.';
  }

  factory HomeDashboardModel.fromJson(Map<String, dynamic> json) {
    return HomeDashboardModel(
      patientId: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'Pasien',
      nickname: json['nickname'] as String? ?? '',
      gender: json['gender'] as String? ?? 'Laki-laki',
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? 160.0,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? (json['latest_weight'] as num?)?.toDouble() ?? 60.0,
      profilePhotoUrl: json['profile_photo_url'] as String?,
      bmi: (json['bmi'] as num?)?.toDouble(),
      bmiCategory: json['bmi_category'] as String?,
      dailyCalorieTarget: (json['daily_calorie_target'] as num?)?.toInt() ?? 2000,
      latestBloodSugar: (json['latest_blood_sugar'] as num?)?.toInt(),
      latestBloodSugarTime: json['latest_blood_sugar_time'] as String?,
      latestBloodSugarStatus: json['latest_blood_sugar_status'] as String?,
      latestBloodSugarType: json['latest_blood_sugar_type'] as String?,
      latestBloodSugarTypeLabel: json['latest_blood_sugar_type_label'] as String?,
      latestBloodSugarSeverity: json['latest_blood_sugar_severity'] as String?,
      latestBloodSugarRangeText: json['latest_blood_sugar_range_text'] as String?,
      latestBloodSugarRecommendation: json['latest_blood_sugar_recommendation'] as String?,
      latestBloodSugarColor: json['latest_blood_sugar_color'] as String?,
      averageBloodSugar: (json['average_blood_sugar'] as num?)?.toDouble(),
      latestBloodPressure: json['latest_blood_pressure'] as String?,
      lastMeasuredDate: json['last_measured_date'] as String? ?? json['latest_blood_sugar_time'] as String?,
    );
  }
}
