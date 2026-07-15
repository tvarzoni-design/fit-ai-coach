class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final String priority;
  final bool read;
  final DateTime? sentAt;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.type = 'info',
    this.priority = 'low',
    this.read = false,
    this.sentAt,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
      priority: json['priority'] ?? 'low',
      read: json['read'] ?? false,
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  bool get isUnread => !read;
}
