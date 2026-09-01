class AppNotification {
  final String id;
  final String title;
  final String message;
  final String time;
  final bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.read,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['notification_id'] ?? json['id'] ?? '').toString(),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      time: json['time'] ?? '',
      read: json['read'] ?? json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'time': time,
      'read': read,
    };
  }
}
