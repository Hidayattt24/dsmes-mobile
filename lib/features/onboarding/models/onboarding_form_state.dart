import 'package:flutter/material.dart';

@immutable
class OnboardingFormState {
  const OnboardingFormState({
    this.currentStep = 1,
    this.fullName = '',
    this.nickname = '',
    this.email = '',
    this.phoneNumber = '',
    this.password = '',
    this.confirmPassword = '',
    this.birthDate,
    this.gender,
    this.bloodType,
    this.heightCm = '',
    this.weightKg = '',
    this.activityLevel,
    this.calorieResult,
    this.city = 'Banda Aceh',
    this.district = '',
    this.address = '',
    this.healthFacility = '',
    this.healthFacilities = const [],
    this.isFacilityLoading = false,
    this.facilityLoaded = false,
    this.facilityError,
    this.livingArrangement,
    this.educationLevel,
    this.diabetesDuration,
    this.isLoading = false,
    this.errorMessage,
  });

  final int currentStep;
  final String fullName;
  final String nickname;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final DateTime? birthDate;
  final String? gender;
  final String? bloodType;
  final String heightCm;
  final String weightKg;
  final String? activityLevel;
  final Map<String, dynamic>? calorieResult;
  final String city;
  final String district;
  final String address;
  final String healthFacility;
  final List<String> healthFacilities;
  final bool isFacilityLoading;
  final bool facilityLoaded;
  final String? facilityError;
  final String? livingArrangement;
  final String? educationLevel;
  final String? diabetesDuration;
  final bool isLoading;
  final String? errorMessage;


  double get progressPercent => currentStep / 19;

  int get age {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int years = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      years--;
    }
    return years;
  }

  double get heightValue => double.tryParse(heightCm) ?? 0;
  double get weightValue => double.tryParse(weightKg) ?? 0;

  double get _activityFactor {
    switch (activityLevel) {
      case 'Sangat Rendah':
        return 1.2;
      case 'Ringan':
        return 1.375;
      case 'Sedang':
        return 1.55;
      case 'Aktif':
        return 1.725;
      case 'Sangat Aktif':
        return 1.9;
      default:
        return 1.2;
    }
  }

  double get estimatedTDEE {
    if (heightValue == 0 || weightValue == 0 || age == 0) return 0;
    final double bmr = gender == 'Laki-laki'
        ? 66.5 + (13.75 * weightValue) + (5.003 * heightValue) - (6.755 * age)
        : 655.1 + (9.563 * weightValue) + (1.850 * heightValue) -
            (4.676 * age);
    return bmr * _activityFactor;
  }

  bool canProceedForStep(int step) {
    return switch (step) {
      1 => fullName.trim().isNotEmpty,
      2 => nickname.trim().isNotEmpty,
      3 => email.trim().isEmpty || _isValidEmail(email),
      4 => phoneNumber.trim().length >= 8,
      5 => password.length >= 8,
      6 => confirmPassword.isNotEmpty && confirmPassword == password,
      7 => true,
      8 => district.trim().isNotEmpty && address.trim().isNotEmpty,
      9 => healthFacility.trim().isNotEmpty,
      10 => livingArrangement != null,
      11 => educationLevel != null,
      12 => diabetesDuration != null,
      13 => gender != null,
      14 => birthDate != null,
      15 => bloodType != null,
      16 => heightValue > 50 && heightValue < 250,
      17 => weightValue > 20 && weightValue < 300,
      18 => activityLevel != null,
      19 => true,
      _ => false,
    };
  }

  bool get canProceedCurrentStep => canProceedForStep(currentStep);

  static bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
    return regex.hasMatch(email.trim());
  }

  OnboardingFormState copyWith({
    int? currentStep,
    String? fullName,
    String? nickname,
    String? email,
    String? phoneNumber,
    String? password,
    String? confirmPassword,
    DateTime? birthDate,
    String? gender,
    String? bloodType,
    String? heightCm,
    String? weightKg,
    String? activityLevel,
    Map<String, dynamic>? calorieResult,
    String? city,
    String? district,
    String? address,
    String? healthFacility,
    List<String>? healthFacilities,
    bool? isFacilityLoading,
    bool? facilityLoaded,
    String? facilityError,
    String? livingArrangement,
    String? educationLevel,
    String? diabetesDuration,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingFormState(
      currentStep: currentStep ?? this.currentStep,
      fullName: fullName ?? this.fullName,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      calorieResult: calorieResult ?? this.calorieResult,
      city: city ?? this.city,
      district: district ?? this.district,
      address: address ?? this.address,
      healthFacility: healthFacility ?? this.healthFacility,
      healthFacilities: healthFacilities ?? this.healthFacilities,
      isFacilityLoading: isFacilityLoading ?? this.isFacilityLoading,
      facilityLoaded: facilityLoaded ?? this.facilityLoaded,
      facilityError: facilityError ?? this.facilityError,
      livingArrangement: livingArrangement ?? this.livingArrangement,
      educationLevel: educationLevel ?? this.educationLevel,
      diabetesDuration: diabetesDuration ?? this.diabetesDuration,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  String get emailError {
    if (email.trim().isNotEmpty && !_isValidEmail(email)) return 'Format email tidak valid';
    return '';
  }

  String get passwordStrengthText {
    if (password.length < 8) return 'Minimal 8 karakter';
    final bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    final bool hasLower = password.contains(RegExp(r'[a-z]'));
    final bool hasDigit = password.contains(RegExp(r'[0-9]'));
    final int score = (hasUpper ? 1 : 0) + (hasLower ? 1 : 0) + (hasDigit ? 1 : 0);
    if (password.length >= 12 && score >= 3) return 'Kuat';
    if (password.length >= 8 && score >= 2) return 'Sedang';
    return 'Lemah';
  }
}
