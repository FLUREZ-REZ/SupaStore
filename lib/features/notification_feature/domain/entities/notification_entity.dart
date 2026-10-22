
class NotificationEntity {
  final String id;
  final String userId;
  final String? orderId;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    this.orderId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationEntity.fromMap(
      Map<String, dynamic> map,
      ) {
    return NotificationEntity(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      orderId: map['order_id'] as String?,
      type: map['type'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      isRead: map['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
    );
  }
}
