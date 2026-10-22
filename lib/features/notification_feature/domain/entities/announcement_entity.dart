
class AnnouncementEntity {
  final String id;
  final String authorId;
  final String title;
  final String body;
  final DateTime publishedAt;
  final DateTime createdAt;
  final bool isRead;

  const AnnouncementEntity({
    required this.id,
    required this.authorId,
    required this.title,
    required this.body,
    required this.publishedAt,
    required this.createdAt,
    required this.isRead,
  });

  factory AnnouncementEntity.fromMap(
      Map<String, dynamic> map, {
        required bool isRead,
      }) {
    return AnnouncementEntity(
      id: map['id'] as String,
      authorId: map['author_id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      publishedAt: DateTime.parse(
        map['published_at'] as String,
      ),
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
      isRead: isRead,
    );
  }
}
