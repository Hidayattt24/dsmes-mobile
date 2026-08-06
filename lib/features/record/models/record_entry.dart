import 'package:flutter/material.dart';

enum RecordType {
  all,
  bloodSugar,
  food,
  activity,
  medication,
}

extension RecordTypeExtension on RecordType {
  String get label {
    return switch (this) {
      RecordType.all => 'Semua',
      RecordType.bloodSugar => 'Gula Darah',
      RecordType.food => 'Makanan',
      RecordType.activity => 'Aktivitas',
      RecordType.medication => 'Obat',
    };
  }
}

@immutable
class TimelineRecordItem {
  final String id;
  final RecordType type;
  final String title;
  final String subtitle;
  final String time;
  final String dateText;
  final IconData icon;
  final Color dotOuterColor;
  final Color dotInnerColor;
  final String? badgeText;
  final Color? badgeBgColor;
  final Color? badgeTextColor;

  const TimelineRecordItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.dateText,
    required this.icon,
    required this.dotOuterColor,
    required this.dotInnerColor,
    this.badgeText,
    this.badgeBgColor,
    this.badgeTextColor,
  });
}


