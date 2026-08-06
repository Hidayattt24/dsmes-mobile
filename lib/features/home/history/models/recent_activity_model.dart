import 'package:flutter/material.dart';

enum ActivityCategory {
  bloodSugar,
  meal,
  physicalActivity,
  medication,
  questionnaire,
  education,
  other,
}

class RecentActivityItem {
  final String id;
  final ActivityCategory category;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? statusLabel;
  final Color? statusColor;
  final String? badgeText;

  const RecentActivityItem({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.timestamp,
    this.statusLabel,
    this.statusColor,
    this.badgeText,
  });

  IconData get icon {
    return switch (category) {
      ActivityCategory.bloodSugar => Icons.water_drop_outlined,
      ActivityCategory.meal => Icons.restaurant_rounded,
      ActivityCategory.physicalActivity => Icons.directions_run_rounded,
      ActivityCategory.medication => Icons.medication_outlined,
      ActivityCategory.questionnaire => Icons.assignment_outlined,
      ActivityCategory.education => Icons.menu_book_rounded,
      ActivityCategory.other => Icons.history_rounded,
    };
  }

  Color get iconColor {
    return switch (category) {
      ActivityCategory.bloodSugar => const Color(0xFF00695C),
      ActivityCategory.meal => const Color(0xFFE65100),
      ActivityCategory.physicalActivity => const Color(0xFF0284C7),
      ActivityCategory.medication => const Color(0xFF6B21A8),
      ActivityCategory.questionnaire => const Color(0xFF0F766E),
      ActivityCategory.education => const Color(0xFF15803D),
      ActivityCategory.other => const Color(0xFF475569),
    };
  }

  Color get iconBgColor {
    return switch (category) {
      ActivityCategory.bloodSugar => const Color(0xFFE6F2F1),
      ActivityCategory.meal => const Color(0xFFFFF3E0),
      ActivityCategory.physicalActivity => const Color(0xFFE0F2FE),
      ActivityCategory.medication => const Color(0xFFF3E8FF),
      ActivityCategory.questionnaire => const Color(0xFFCCFBF1),
      ActivityCategory.education => const Color(0xFFDCFCE7),
      ActivityCategory.other => const Color(0xFFF1F5F9),
    };
  }
}
