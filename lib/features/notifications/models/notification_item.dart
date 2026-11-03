enum NotificationType { warning, medication, education, targetAchieved }

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String timestamp;
  final NotificationType type;
  final bool isUnread;
  final String group;
  final String? articleId;
  final String? iconName;
  final String? activityName;
  final String? category;
  final String? reminderId;
  final String actionType;
  final String? occurrenceId;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    required this.isUnread,
    required this.group,
    this.articleId,
    this.iconName,
    this.activityName,
    this.category,
    this.reminderId,
    this.actionType = 'reminder_management',
    this.occurrenceId,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? description,
    String? timestamp,
    NotificationType? type,
    bool? isUnread,
    String? group,
    String? articleId,
    String? iconName,
    String? activityName,
    String? category,
    String? reminderId,
    String? actionType,
    String? occurrenceId,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isUnread: isUnread ?? this.isUnread,
      group: group ?? this.group,
      articleId: articleId ?? this.articleId,
      iconName: iconName ?? this.iconName,
      activityName: activityName ?? this.activityName,
      category: category ?? this.category,
      reminderId: reminderId ?? this.reminderId,
      actionType: actionType ?? this.actionType,
      occurrenceId: occurrenceId ?? this.occurrenceId,
    );
  }
}
