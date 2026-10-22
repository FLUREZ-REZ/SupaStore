class AdminAnnouncementEntity {
  final String id;
  final String authorId;
  final String title;
  final String body;
  final DateTime publishedAt;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isPublished;

  const AdminAnnouncementEntity({
    required this.id,
    required this.authorId,
    required this.title,
    required this.body,
    required this.publishedAt,
    required this.createdAt,
    required this.expiresAt,
    required this.isPublished,
  });

  bool get isExpired {
    final expiry = expiresAt;

    return expiry != null &&
        !expiry.isAfter(DateTime.now().toUtc());
  }

  bool get isScheduled {
    return publishedAt.toUtc().isAfter(
      DateTime.now().toUtc(),
    );
  }

  bool get isActive {
    return isPublished && !isExpired && !isScheduled;
  }

  factory AdminAnnouncementEntity.fromMap(
      Map<String, dynamic> map,
      ) {
    return AdminAnnouncementEntity(
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
      expiresAt: map['expires_at'] == null
          ? null
          : DateTime.parse(
        map['expires_at'] as String,
      ),
      isPublished: map['is_published'] as bool? ?? false,
    );
  }
}