import '../../domain/entities/announcement_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl
    implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<NotificationEntity>> getNotifications() {
    return remoteDataSource.getNotifications();
  }

  @override
  Future<List<AnnouncementEntity>> getAnnouncements() {
    return remoteDataSource.getAnnouncements();
  }

  @override
  Future<void> markNotificationAsRead(
      String notificationId,
      ) {
    return remoteDataSource.markNotificationAsRead(
      notificationId,
    );
  }

  @override
  Future<void> markAnnouncementAsRead(
      String announcementId,
      ) {
    return remoteDataSource.markAnnouncementAsRead(
      announcementId,
    );
  }

  @override
  Future<void> publishAnnouncement({
    required String title,
    required String body,
  }) {
    return remoteDataSource.publishAnnouncement(
      title: title,
      body: body,
    );
  }
}
