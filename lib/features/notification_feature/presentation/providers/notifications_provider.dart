
import 'package:flutter/foundation.dart';

import '../../domain/entities/announcement_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';

class NotificationsProvider extends ChangeNotifier {
  final NotificationsRepository repository;

  NotificationsProvider({
    required this.repository,
  });

  List<NotificationEntity> _notifications = [];
  List<AnnouncementEntity> _announcements = [];

  bool _isLoading = false;
  bool _isPublishing = false;
  String? _errorMessage;

  List<NotificationEntity> get notifications =>
      List.unmodifiable(_notifications);

  List<AnnouncementEntity> get announcements =>
      List.unmodifiable(_announcements);

  bool get isLoading => _isLoading;

  bool get isPublishing => _isPublishing;

  String? get errorMessage => _errorMessage;

  int get unreadNotificationsCount =>
      _notifications.where((item) => !item.isRead).length;

  int get unreadAnnouncementsCount =>
      _announcements.where((item) => !item.isRead).length;

  int get unreadCount =>
      unreadNotificationsCount + unreadAnnouncementsCount;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // هر دو درخواست هم‌زمان آغاز می‌شوند.
      final notificationsFuture =
      repository.getNotifications();

      final announcementsFuture =
      repository.getAnnouncements();

      final results = await Future.wait<Object>([
        notificationsFuture,
        announcementsFuture,
      ]);

      _notifications =
      results[0] as List<NotificationEntity>;

      _announcements =
      results[1] as List<AnnouncementEntity>;
    } catch (e) {
      _errorMessage = 'دریافت اعلان‌ها ناموفق بود.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markNotificationAsRead(
      String notificationId,
      ) async {
    final index = _notifications.indexWhere(
          (item) => item.id == notificationId,
    );

    if (index == -1 || _notifications[index].isRead) {
      return true;
    }

    final previous = _notifications[index];

    _notifications[index] = NotificationEntity(
      id: previous.id,
      userId: previous.userId,
      orderId: previous.orderId,
      type: previous.type,
      title: previous.title,
      body: previous.body,
      isRead: true,
      createdAt: previous.createdAt,
    );

    _errorMessage = null;
    notifyListeners();

    try {
      await repository.markNotificationAsRead(
        notificationId,
      );
      return true;
    } catch (e) {
      _notifications[index] = previous;
      _errorMessage = 'تغییر وضعیت اعلان ناموفق بود.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAnnouncementAsRead(
      String announcementId,
      ) async {
    final index = _announcements.indexWhere(
          (item) => item.id == announcementId,
    );

    if (index == -1 || _announcements[index].isRead) {
      return true;
    }

    final previous = _announcements[index];

    _announcements[index] = AnnouncementEntity(
      id: previous.id,
      authorId: previous.authorId,
      title: previous.title,
      body: previous.body,
      publishedAt: previous.publishedAt,
      createdAt: previous.createdAt,
      isRead: true,
    );

    _errorMessage = null;
    notifyListeners();

    try {
      await repository.markAnnouncementAsRead(
        announcementId,
      );
      return true;
    } catch (e) {
      _announcements[index] = previous;
      _errorMessage = 'ثبت وضعیت اطلاعیه ناموفق بود.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> publishAnnouncement({
    required String title,
    required String body,
  }) async {
    if (title.trim().isEmpty || body.trim().isEmpty) {
      _errorMessage = 'عنوان و متن اطلاعیه الزامی است.';
      notifyListeners();
      return false;
    }

    _isPublishing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.publishAnnouncement(
        title: title,
        body: body,
      );

      await loadNotifications();
      return _errorMessage == null;
    } catch (e) {
      _errorMessage = 'انتشار اطلاعیه ناموفق بود.';
      return false;
    } finally {
      _isPublishing = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
