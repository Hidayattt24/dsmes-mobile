import 'package:flutter/material.dart';

@immutable
class ReminderModel {
  final String id;
  final String activityName;
  final String reminderType;
  final String category;
  final String scheduledTime;
  final bool isActive;
  final String notes;
  final String iconName;
  final int repeatIntervalDays;
  final List<int> activeDays;

  const ReminderModel({
    required this.id,
    required this.activityName,
    required this.reminderType,
    required this.category,
    required this.scheduledTime,
    required this.isActive,
    required this.notes,
    required this.iconName,
    required this.repeatIntervalDays,
    required this.activeDays,
  });

  String get formattedTime {
    final parts = scheduledTime.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return scheduledTime;
  }

  String get categoryLabel {
    switch (category) {
      case 'medis_obat':
        return 'Medis & Obat';
      case 'nutrisi_air':
        return 'Nutrisi & Air';
      case 'aktivitas_fisik':
        return 'Aktivitas Fisik';
      case 'lainnya':
        return 'Lainnya';
      default:
        return category;
    }
  }

  String get activeDaysLabel {
    if (activeDays.length == 7) return 'Setiap hari';
    if (activeDays.length == 5 && !activeDays.contains(6) && !activeDays.contains(7)) {
      return 'Senin - Jumat';
    }
    if (activeDays.length == 2 && activeDays.contains(6) && activeDays.contains(7)) {
      return 'Sabtu - Minggu';
    }
    const dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return activeDays.map((d) => dayNames[d - 1]).join(', ');
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String? ?? '',
      activityName: json['activity_name'] as String? ?? '',
      reminderType: json['reminder_type'] as String? ?? 'personal',
      category: json['category'] as String? ?? 'lainnya',
      scheduledTime: json['scheduled_time'] as String? ?? '08:00:00',
      isActive: json['is_active'] as bool? ?? false,
      notes: json['notes'] as String? ?? '',
      iconName: json['icon_name'] as String? ?? 'default',
      repeatIntervalDays: (json['repeat_interval_days'] as num?)?.toInt() ?? 1,
      activeDays: (json['active_days'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [1, 2, 3, 4, 5, 6, 7],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_name': activityName,
      'category': category,
      'scheduled_time': scheduledTime,
      'notes': notes,
      'icon_name': iconName,
      'repeat_interval_days': repeatIntervalDays,
      'active_days': activeDays,
    };
  }

  ReminderModel copyWith({
    String? id,
    String? activityName,
    String? reminderType,
    String? category,
    String? scheduledTime,
    bool? isActive,
    String? notes,
    String? iconName,
    int? repeatIntervalDays,
    List<int>? activeDays,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      activityName: activityName ?? this.activityName,
      reminderType: reminderType ?? this.reminderType,
      category: category ?? this.category,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      iconName: iconName ?? this.iconName,
      repeatIntervalDays: repeatIntervalDays ?? this.repeatIntervalDays,
      activeDays: activeDays ?? this.activeDays,
    );
  }
}
