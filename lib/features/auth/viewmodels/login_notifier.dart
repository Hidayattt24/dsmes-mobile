import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../models/login_form_state.dart';


/// ViewModel for the login form.
///
/// Manages form state, validation, and submission.
/// Holds [TextEditingController] and [GlobalKey<FormState>] per guidelines.
///
/// Business logic is here — NEVER in the Widget.
class LoginNotifier extends Notifier<LoginFormState> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  LoginFormState build() {
    emailController = TextEditingController();
    passwordController = TextEditingController();

    // Dispose controllers when provider is destroyed
    ref.onDispose(() {
      emailController.dispose();
      passwordController.dispose();
    });

    return const LoginFormState();
  }

  LoginFormState get formState => state;

  // ── Field Updates ─────────────────────────────────────────────────────────

  void onEmailChanged(String value) {
    state = state.copyWith(email: value, clearError: true);
  }

  void onPasswordChanged(String value) {
    state = state.copyWith(password: value, clearError: true);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void toggleRememberMe() {
    state = state.copyWith(isRemembered: !state.isRemembered);
  }

  // ── Validation ────────────────────────────────────────────────────────────

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.validationRequired;
    }
    final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return AppStrings.validationEmail;
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationRequired;
    }
    if (value.length < AppConstants.passwordMinLength) {
      return AppStrings.validationPasswordMin;
    }
    return null;
  }

  /// Validates the form and performs login via AuthRepository.
  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await ref.read(authRepositoryProvider).login(
            email: emailController.text.trim(),
            password: passwordController.text,
          );

      state = state.copyWith(isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.errorGeneral,
      );
    }
  }
}


/// Provider for [LoginNotifier].
final loginProvider = NotifierProvider<LoginNotifier, LoginFormState>(
  LoginNotifier.new,
);
