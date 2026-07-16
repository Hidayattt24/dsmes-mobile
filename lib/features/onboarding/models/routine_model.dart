import 'package:flutter/material.dart';

@immutable
class RoutineModel {
  const RoutineModel({
    required this.id,
    required this.name,
    required this.iconName,
    this.scheduleText = '',
    this.isPredefined = false,
    this.customTimes = const [],
  });

  final String id;
  final String name;
  final String iconName;
  final String scheduleText;
  final bool isPredefined;
  final List<TimeOfDay> customTimes;

  RoutineModel copyWith({
    String? id,
    String? name,
    String? iconName,
    String? scheduleText,
    bool? isPredefined,
    List<TimeOfDay>? customTimes,
  }) {
    return RoutineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      scheduleText: scheduleText ?? this.scheduleText,
      isPredefined: isPredefined ?? this.isPredefined,
      customTimes: customTimes ?? this.customTimes,
    );
  }
}
