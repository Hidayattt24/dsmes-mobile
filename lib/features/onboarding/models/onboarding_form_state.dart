import 'package:flutter/material.dart';

@immutable
class OnboardingFormState {
  const OnboardingFormState({
    this.currentStep = 1,
    this.fullName = '',
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
    this.isLoading = false,
    this.errorMessage,
  });

  final int currentStep;
  final String fullName;
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
  final bool isLoading;
  final String? errorMessage;

  double get progressPercent => currentStep / 13;

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

  bool get canProceedCurrentStep {
    return switch (currentStep) {
      1 => fullName.trim().isNotEmpty,
      2 => _isValidEmail(email),
      3 => phoneNumber.trim().length >= 10,
      4 => password.length >= 8,
      5 => confirmPassword.isNotEmpty && confirmPassword == password,
      6 => true,
      7 => gender != null,
      8 => birthDate != null,
      9 => bloodType != null,
      10 => heightValue > 50 && heightValue < 250,
      11 => weightValue > 20 && weightValue < 300,
      12 => activityLevel != null,
      13 => true,
      _ => false,
    };
  }

  static bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
    return regex.hasMatch(email.trim());
  }

  OnboardingFormState copyWith({
    int? currentStep,
    String? fullName,
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
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingFormState(
      currentStep: currentStep ?? this.currentStep,
      fullName: fullName ?? this.fullName,
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
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  String get emailError {
    if (email.isEmpty) return 'Email wajib diisi';
    if (!_isValidEmail(email)) return 'Format email tidak valid';
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
