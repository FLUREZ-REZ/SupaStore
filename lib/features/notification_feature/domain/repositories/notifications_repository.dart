import '../entities/announcement_entity.dart';
import '../entities/notification_entity.dart';

abstract class NotificationsRepository {
  Future<List<NotificationEntity>> getNotifications();

  Future<List<AnnouncementEntity>> getAnnouncements();

  Future<void> markNotificationAsRead(
      String notificationId,
      );

  Future<void> markAnnouncementAsRead(
      String announcementId,
      );

  Future<void> publishAnnouncement({
    required String title,
    required String body,
  });
}
