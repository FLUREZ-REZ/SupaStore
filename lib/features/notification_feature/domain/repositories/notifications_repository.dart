import 'package:supastore/features/notification_feature/domain/entities/admin_announcements_lists.dart';

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
    DateTime? expiresAt,
  });

  Future<AdminAnnouncementsPage> getAdminAnnouncements({
    required int page,
    int pageSize = 10,
  });

  Future<void> deleteAnnouncement(String announcementId);

}