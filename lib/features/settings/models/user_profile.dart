import 'package:flutter/material.dart';

/// Model representing user personal information profile.
@immutable
class UserProfile {
  const UserProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.birthDate,
    required this.bloodType,
  });

  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final DateTime birthDate;
  final String bloodType;

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? gender,
    DateTime? birthDate,
    String? bloodType,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      bloodType: bloodType ?? this.bloodType,
    );
  }
}
