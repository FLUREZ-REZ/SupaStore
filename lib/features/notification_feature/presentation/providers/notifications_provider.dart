import 'package:flutter/foundation.dart';
import 'package:supastore/features/notification_feature/domain/entities/admin_announcement_entity.dart';
import 'package:supastore/features/notification_feature/domain/entities/admin_announcements_lists.dart';
import 'package:supastore/features/notification_feature/domain/entities/announcement_entity.dart';
import 'package:supastore/features/notification_feature/domain/entities/notification_entity.dart';
import 'package:supastore/features/notification_feature/domain/repositories/notifications_repository.dart';

class NotificationsProvider extends ChangeNotifier {
  final NotificationsRepository repository;

  final Set<String> _deletingAnnouncementIds = {};

  Set<String> get deletingAnnouncementIds =>
      Set.unmodifiable(_deletingAnnouncementIds);

  bool isDeletingAnnouncement(String announcementId) =>
      _deletingAnnouncementIds.contains(announcementId);

  String? _deleteAnnouncementErrorMessage;

  String? get deleteAnnouncementErrorMessage =>
      _deleteAnnouncementErrorMessage;


  NotificationsProvider({
    required this.repository,
  });

  // اعلان‌های کاربران
  List<NotificationEntity> _notifications = [];
  List<AnnouncementEntity> _announcements = [];

  // اطلاعیه‌های مدیریتی
  List<AdminAnnouncementEntity> _adminAnnouncements = [];

  bool _isLoading = false;
  bool _isPublishing = false;

  bool _isLoadingAdminAnnouncements = false;
  bool _isLoadingMoreAdminAnnouncements = false;

  bool _adminAnnouncementsHasMore = true;
  int _adminAnnouncementsPage = 0;

  static const int _adminAnnouncementsPageSize = 10;

  String? _errorMessage;
  String? _adminAnnouncementsErrorMessage;

  // Getters اعلان‌های کاربران

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

  // Getters فهرست مدیریتی

  List<AdminAnnouncementEntity> get adminAnnouncements =>
      List.unmodifiable(_adminAnnouncements);

  bool get isLoadingAdminAnnouncements =>
      _isLoadingAdminAnnouncements;

  bool get isLoadingMoreAdminAnnouncements =>
      _isLoadingMoreAdminAnnouncements;

  bool get adminAnnouncementsHasMore =>
      _adminAnnouncementsHasMore;

  String? get adminAnnouncementsErrorMessage =>
      _adminAnnouncementsErrorMessage;

  // دریافت اعلان‌های عادی کاربران

  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait<Object>([
        repository.getNotifications(),
        repository.getAnnouncements(),
      ]);

      _notifications = results[0] as List<NotificationEntity>;
      _announcements = results[1] as List<AnnouncementEntity>;
    } catch (e) {
      _errorMessage = 'دریافت اعلان‌ها ناموفق بود.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // بارگذاری صفحه اول اطلاعیه‌های مدیریتی

  Future<void> loadAdminAnnouncements({
    bool refresh = false,
  }) async {
    if (_isLoadingAdminAnnouncements) {
      return;
    }

    if (_isLoadingMoreAdminAnnouncements) {
      return;
    }

    if (!refresh &&
        _adminAnnouncements.isNotEmpty &&
        !_adminAnnouncementsHasMore) {
      return;
    }

    _isLoadingAdminAnnouncements = true;
    _adminAnnouncementsErrorMessage = null;

    if (refresh) {
      _adminAnnouncements = [];
      _adminAnnouncementsPage = 0;
      _adminAnnouncementsHasMore = true;
    }

    notifyListeners();

    try {
      final AdminAnnouncementsPage result =
      await repository.getAdminAnnouncements(
        page: 0,
        pageSize: _adminAnnouncementsPageSize,
      );

      _adminAnnouncements = result.items;
      _adminAnnouncementsPage = 0;
      _adminAnnouncementsHasMore = result.hasMore;
    } catch (e) {
      _adminAnnouncementsErrorMessage =
      'دریافت فهرست اطلاعیه‌ها ناموفق بود.';
    } finally {
      _isLoadingAdminAnnouncements = false;
      notifyListeners();
    }
  }

  // بارگذاری صفحه بعدی

  Future<void> loadMoreAdminAnnouncements() async {
    if (_isLoadingAdminAnnouncements ||
        _isLoadingMoreAdminAnnouncements ||
        !_adminAnnouncementsHasMore) {
      return;
    }

    _isLoadingMoreAdminAnnouncements = true;
    _adminAnnouncementsErrorMessage = null;
    notifyListeners();

    try {
      final nextPage = _adminAnnouncementsPage + 1;

      final AdminAnnouncementsPage result =
      await repository.getAdminAnnouncements(
        page: nextPage,
        pageSize: _adminAnnouncementsPageSize,
      );

      _adminAnnouncements.addAll(result.items);
      _adminAnnouncementsPage = nextPage;
      _adminAnnouncementsHasMore = result.hasMore;
    } catch (e) {
      _adminAnnouncementsErrorMessage =
      'بارگذاری اطلاعیه‌های بیشتر ناموفق بود.';
    } finally {
      _isLoadingMoreAdminAnnouncements = false;
      notifyListeners();
    }
  }

  // علامت‌گذاری اعلان عادی به‌عنوان خوانده‌شده

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
      await repository.markNotificationAsRead(notificationId);
      return true;
    } catch (e) {
      _notifications[index] = previous;
      _errorMessage = 'تغییر وضعیت اعلان ناموفق بود.';
      notifyListeners();
      return false;
    }
  }

  // علامت‌گذاری اطلاعیه کاربر به‌عنوان خوانده‌شده

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
      expiresAt: previous.expiresAt,
      isRead: true,
    );

    _errorMessage = null;
    notifyListeners();

    try {
      await repository.markAnnouncementAsRead(announcementId);
      return true;
    } catch (e) {
      _announcements[index] = previous;
      _errorMessage = 'ثبت وضعیت اطلاعیه ناموفق بود.';
      notifyListeners();
      return false;
    }
  }

  // انتشار اطلاعیه جدید

  Future<bool> publishAnnouncement({
    required String title,
    required String body,
    DateTime? expiresAt,
  }) async {
    if (title.trim().isEmpty || body.trim().isEmpty) {
      _errorMessage = 'عنوان و متن اطلاعیه الزامی است.';
      notifyListeners();
      return false;
    }

    if (title.trim().length > 200) {
      _errorMessage =
      'عنوان اطلاعیه حداکثر ۲۰۰ کاراکتر است.';
      notifyListeners();
      return false;
    }

    if (body.trim().length > 10000) {
      _errorMessage =
      'متن اطلاعیه بیش از حد طولانی است.';
      notifyListeners();
      return false;
    }

    if (expiresAt != null &&
        !expiresAt.toUtc().isAfter(DateTime.now().toUtc())) {
      _errorMessage = 'تاریخ انقضا باید در آینده باشد.';
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
        expiresAt: expiresAt,
      );

      await loadNotifications();

      // فهرست ادمین نیز پس از انتشار تازه شود.
      await loadAdminAnnouncements(refresh: true);

      return _errorMessage == null &&
          _adminAnnouncementsErrorMessage == null;
    } catch (e) {
      _errorMessage = 'انتشار اطلاعیه ناموفق بود.';
      notifyListeners();
      return false;
    } finally {
      _isPublishing = false;
      notifyListeners();
    }
  }

  // پاک‌کردن خطای اعلان‌های کاربران

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // پاک‌کردن خطای فهرست ادمین

  void clearAdminAnnouncementsError() {
    _adminAnnouncementsErrorMessage = null;
    notifyListeners();
  }

  Future<bool> deleteAnnouncement(String announcementId) async {
    if (_deletingAnnouncementIds.contains(announcementId)) {
      return false;
    }

    final index = _adminAnnouncements.indexWhere(
          (item) => item.id == announcementId,
    );

    if (index == -1) {
      _deleteAnnouncementErrorMessage =
      'اطلاعیه موردنظر در فهرست پیدا نشد.';
      notifyListeners();
      return false;
    }

    _deletingAnnouncementIds.add(announcementId);
    _deleteAnnouncementErrorMessage = null;
    notifyListeners();

    try {
      await repository.deleteAnnouncement(announcementId);

      _adminAnnouncements.removeWhere(
            (item) => item.id == announcementId,
      );

      notifyListeners();

      // یک ردیف از صفحه بعدی جایگزین ردیف حذف‌شده می‌شود.
      if (_adminAnnouncementsHasMore) {
        await _reloadAdminAnnouncementsAfterDelete();
      }

      return true;
    } catch (e) {
      _deleteAnnouncementErrorMessage =
      'حذف اطلاعیه ناموفق بود. دسترسی دیتابیس را بررسی کنید.';
      notifyListeners();
      return false;
    } finally {
      _deletingAnnouncementIds.remove(announcementId);
      notifyListeners();
    }
  }

  Future<void> _reloadAdminAnnouncementsAfterDelete() async {
    try {
      final result = await repository.getAdminAnnouncements(
        page: _adminAnnouncementsPage,
        pageSize: _adminAnnouncementsPageSize,
      );

      _adminAnnouncements.addAll(result.items);
      _adminAnnouncementsHasMore = result.hasMore;
    } catch (_) {
      // حذف موفق باقی می‌ماند؛ بارگذاری مجدد در صورت نیاز دستی انجام می‌شود.
      _adminAnnouncementsErrorMessage =
      'اطلاعیه حذف شد، اما بارگذاری موارد بیشتر ناموفق بود.';
    }
  }

}