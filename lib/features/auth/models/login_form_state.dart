import 'package:flutter/material.dart';

/// Immutable state for the login form.
@immutable
class LoginFormState {
  const LoginFormState({
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.isRemembered = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final String email;
  final String password;
  final bool isPasswordVisible;
  final bool isRemembered;
  final bool isLoading;
  final String? errorMessage;

  bool get isValid => email.isNotEmpty && password.length >= 8;

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? isPasswordVisible,
    bool? isRemembered,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isRemembered: isRemembered ?? this.isRemembered,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
