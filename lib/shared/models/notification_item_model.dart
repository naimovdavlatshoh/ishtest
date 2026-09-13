class NotificationItemModel {
  final int id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final String createdAt;

  NotificationItemModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id'] as int,
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  NotificationItemModel copyWith({bool? isRead}) {
    return NotificationItemModel(
      id: id,
      type: type,
      title: title,
      body: body,
      data: data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
