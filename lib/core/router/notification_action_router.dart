import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';

abstract final class NotificationActions {
  static const mealEntry = 'meal_entry';
  static const activityEntry = 'activity_entry';
  static const bloodSugarEntry = 'blood_sugar_entry';
  static const medicationEntry = 'medication_entry';
  static const educationDetail = 'education_detail';
  static const reminderManagement = 'reminder_management';
}

/// Notification destinations always start from the authenticated shell. A
/// detail route is pushed only after the shell has been built and unlocked.
abstract final class NotificationActionRouter {
  static String? _pendingTarget;

  static void open(
    BuildContext context, {
    String? actionType,
    String? articleId,
    String? legacyType,
  }) {
    final action = actionType?.trim();
    final requestId = DateTime.now().microsecondsSinceEpoch;
    String base = '${RouteNames.home}?tab=home&request=$requestId';
    String? target;

    if (action == NotificationActions.educationDetail ||
        legacyType == 'education') {
      base = '${RouteNames.home}?tab=education&request=$requestId';
      if (articleId != null && articleId.trim().isNotEmpty) {
        target =
            '${RouteNames.educationDetail}/${Uri.encodeComponent(articleId.trim())}';
      }
    } else {
      switch (action) {
        case NotificationActions.mealEntry:
          target = RouteNames.mealEntry;
          break;
        case NotificationActions.activityEntry:
          base =
              '${RouteNames.home}?tab=record&action=activity_entry&request=$requestId';
          break;
        case NotificationActions.medicationEntry:
          base =
              '${RouteNames.home}?tab=record&action=medication_entry&request=$requestId';
          break;
        case NotificationActions.bloodSugarEntry:
          target = RouteNames.bloodSugarEntry;
          break;
        default:
          target =
              legacyType == 'blood_sugar'
                  ? RouteNames.bloodSugarEntry
                  : RouteNames.reminders;
          break;
      }
    }

    _pendingTarget = target;
    context.go(base);
  }

  static void flushIfReady(BuildContext context) {
    final target = _pendingTarget;
    if (target == null || !context.mounted) return;
    final router = GoRouter.of(context);
    if (router.routeInformationProvider.value.uri.path != RouteNames.home) {
      return;
    }
    _pendingTarget = null;
    unawaited(router.push(target));
  }

  static void clearPending() => _pendingTarget = null;
}
