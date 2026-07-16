import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/onboarding_form_state.dart';

class OnboardingNotifier extends Notifier<OnboardingFormState> {
  @override
  OnboardingFormState build() => const OnboardingFormState();

  // ── Navigation ─────────────────────────────────────────────────────────────

  void nextStep() {
    if (!state.canProceedCurrentStep) return;
    if (state.currentStep < 13) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    assert(step >= 1 && step <= 13, 'Step must be between 1 and 13');
    state = state.copyWith(currentStep: step);
  }

  // ── Step 1: Full Name ─────────────────────────────────────────────────────

  void onFullNameChanged(String value) {
    state = state.copyWith(fullName: value);
  }

  // ── Step 2: Email ──────────────────────────────────────────────────────────

  void onEmailChanged(String value) {
    state = state.copyWith(email: value);
  }

  // ── Step 3: Phone Number ──────────────────────────────────────────────────

  void onPhoneChanged(String value) {
    state = state.copyWith(phoneNumber: value);
  }

  // ── Step 4: Password ──────────────────────────────────────────────────────

  void onPasswordChanged(String value) {
    state = state.copyWith(password: value);
  }

  // ── Step 5: Confirm Password ──────────────────────────────────────────────

  void onConfirmPasswordChanged(String value) {
    state = state.copyWith(confirmPassword: value);
  }

  // ── Step 7: Gender ────────────────────────────────────────────────────────

  void onGenderSelected(String gender) {
    state = state.copyWith(gender: gender);
  }

  // ── Step 8: Birth Date ────────────────────────────────────────────────────

  void onBirthDateSelected(DateTime date) {
    state = state.copyWith(birthDate: date);
  }

  // ── Step 9: Blood Type ────────────────────────────────────────────────────

  void onBloodTypeSelected(String bloodType) {
    state = state.copyWith(bloodType: bloodType);
  }

  // ── Step 10: Height ───────────────────────────────────────────────────────

  void onHeightKeyTapped(String key) {
    final current = state.heightCm;
    if (key == '.' && current.contains('.')) return;
    if (current.length >= 5) return;
    final updated = current == '0' && key != '.' ? key : current + key;
    state = state.copyWith(heightCm: updated);
  }

  void onHeightBackspace() {
    final current = state.heightCm;
    if (current.isEmpty) return;
    state = state.copyWith(heightCm: current.substring(0, current.length - 1));
  }

  // ── Step 11: Weight ───────────────────────────────────────────────────────

  void onWeightKeyTapped(String key) {
    final current = state.weightKg;
    if (key == '.' && current.contains('.')) return;
    if (current.length >= 5) return;
    final updated = current == '0' && key != '.' ? key : current + key;
    state = state.copyWith(weightKg: updated);
  }

  void onWeightBackspace() {
    final current = state.weightKg;
    if (current.isEmpty) return;
    state = state.copyWith(weightKg: current.substring(0, current.length - 1));
  }

  // ── Step 12: Activity Level ───────────────────────────────────────────────

  void onActivitySelected(String level) {
    state = state.copyWith(activityLevel: level);
  }

  // ── Step 13: Submit ───────────────────────────────────────────────────────

  Future<void> finishOnboarding() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(isLoading: false);
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingFormState>(
  OnboardingNotifier.new,
);
