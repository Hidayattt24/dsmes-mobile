/// DTO for a notification_logs record returned by
/// `GET /patient/notifications` (handled by the reminder module).
class NotificationModel {
  final String id;
  final String? reminderId;
  final String messageText;
  final String notifiedAt;
  final bool isRead;
  final String notifType;
  final String? articleId;
  final String? iconName;
  final String? activityName;
  final String? category;

  const NotificationModel({
    required this.id,
    this.reminderId,
    required this.messageText,
    required this.notifiedAt,
    required this.isRead,
    required this.notifType,
    this.articleId,
    this.iconName,
    this.activityName,
    this.category,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      reminderId: json['reminder_id'] as String?,
      messageText: json['message_text'] as String? ?? '',
      notifiedAt: json['notified_at'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      notifType: json['notif_type'] as String? ?? 'reminder',
      articleId: json['article_id'] as String?,
      iconName: json['icon_name'] as String?,
      activityName: json['activity_name'] as String?,
      category: json['category'] as String?,
    );
  }
}
