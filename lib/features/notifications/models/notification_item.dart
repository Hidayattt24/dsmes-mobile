enum NotificationType {
  warning,
  medication,
  education,
  targetAchieved,
}

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String timestamp;
  final NotificationType type;
  final bool isUnread;
  final String group;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    required this.isUnread,
    required this.group,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? description,
    String? timestamp,
    NotificationType? type,
    bool? isUnread,
    String? group,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isUnread: isUnread ?? this.isUnread,
      group: group ?? this.group,
    );
  }
}
