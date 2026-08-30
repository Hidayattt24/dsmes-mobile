import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/facility_repository.dart';
import '../../questionnaire/viewmodels/questionnaire_notifier.dart';
import '../models/onboarding_form_state.dart';



class OnboardingNotifier extends Notifier<OnboardingFormState> {
  @override
  OnboardingFormState build() => const OnboardingFormState();

  // ── Navigation ─────────────────────────────────────────────────────────────

  void nextStep() {
    if (!state.canProceedCurrentStep) return;
    if (state.currentStep < 19) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    assert(step >= 1 && step <= 19, 'Step must be between 1 and 19');
    state = state.copyWith(currentStep: step);
  }

  // ── Step 1: Full Name ─────────────────────────────────────────────────────

  void onFullNameChanged(String value) {
    state = state.copyWith(fullName: value);
  }

  // ── Step 2: Nickname ──────────────────────────────────────────────────────

  void onNicknameChanged(String value) {
    state = state.copyWith(nickname: value);
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

  // ── Step 8: Residence ─────────────────────────────────────────────────────

  void onDistrictChanged(String value) {
    state = state.copyWith(district: value);
  }

  void onAddressChanged(String value) {
    state = state.copyWith(address: value);
  }

  // ── Step 9: Health Facility ───────────────────────────────────────────────

  void onHealthFacilityChanged(String value) {
    state = state.copyWith(healthFacility: value);
  }

  Future<void> loadHealthFacilities() async {
    if (state.isFacilityLoading || state.facilityLoaded) return;
    state = state.copyWith(isFacilityLoading: true, facilityError: null);
    try {
      final facilities =
          await ref.read(facilityRepositoryProvider).fetchHealthFacilities();
      state = state.copyWith(
        healthFacilities: facilities,
        isFacilityLoading: false,
        facilityLoaded: true,
      );
    } catch (_) {
      state = state.copyWith(
        isFacilityLoading: false,
        facilityLoaded: true,
        facilityError: 'Gagal memuat daftar puskesmas.',
      );
    }
  }

  // ── Step 10: Living Arrangement ───────────────────────────────────────────

  void onLivingArrangementSelected(String value) {
    state = state.copyWith(livingArrangement: value);
  }

  // ── Step 11: Education ────────────────────────────────────────────────────

  void onEducationSelected(String value) {
    state = state.copyWith(educationLevel: value);
  }

  // ── Step 12: Diabetes Duration ────────────────────────────────────────────

  void onDiabetesDurationSelected(String value) {
    state = state.copyWith(diabetesDuration: value);
  }

  // ── Step 6: Submit Account Registration ──────────────────────────────────

  Future<bool> finishAccountRegistration() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authRepositoryProvider).register(state);

      // Reset questionnaire state for the newly created account so the
      // Pre-Test guard reflects THIS user (not a previous session's data).
      ref.invalidate(preTestHistoryProvider);
      ref.invalidate(allQuestionnaireHistoryProvider);
      ref.invalidate(questionnaireListProvider);
      ref.read(quizSubmissionProvider.notifier).reset();

      state = state.copyWith(isLoading: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal membuat akun. Silakan coba lagi.',
      );
      return false;
    }
  }

  // ── Step 13: Submit Health Profile Setup & Calculate Summary ─────────────

  Future<bool> setupHealthProfileFromBackend() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res =
          await ref.read(authRepositoryProvider).setupHealthProfile(state);
      state = state.copyWith(
        calorieResult: res,
        isLoading: false,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menyimpan profil kesehatan. Silakan coba lagi.',
      );
      return false;
    }
  }

  // ── Step 12: Submit Sociodemographic Profile ──────────────────────────────

  Future<bool> submitSociodemographic() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authRepositoryProvider).setupSociodemographic(state);
      state = state.copyWith(isLoading: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menyimpan data diri. Silakan coba lagi.',
      );
      return false;
    }
  }
}



final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingFormState>(
  OnboardingNotifier.new,
);
