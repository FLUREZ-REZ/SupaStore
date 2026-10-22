import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supastore/features/notification_feature/domain/entities/announcement_entity.dart';
import 'package:supastore/features/notification_feature/domain/entities/notification_entity.dart';
import 'package:supastore/features/notification_feature/presentation/providers/notifications_provider.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const Color _primaryColor = Color(0xFFE21B23);
  static const Color _backgroundColor = Color(0xFFF7F7F8);
  static const Color _textColor = Color(0xFF222222);
  static const Color _secondaryTextColor = Color(0xFF777777);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: _textColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'اعلان‌ها',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            labelColor: _primaryColor,
            unselectedLabelColor: _secondaryTextColor,
            indicatorColor: _primaryColor,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'اعلان‌های من'),
              Tab(text: 'اطلاعیه‌های فروشگاه'),
            ],
          ),
        ),
        body: Consumer<NotificationsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading &&
                provider.notifications.isEmpty &&
                provider.announcements.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: _primaryColor,
                ),
              );
            }

            if (provider.errorMessage != null &&
                provider.notifications.isEmpty &&
                provider.announcements.isEmpty) {
              return _ErrorView(
                message: provider.errorMessage!,
                onRetry: provider.loadNotifications,
              );
            }

            return TabBarView(
              children: [
                _PersonalNotificationsTab(
                  notifications: provider.notifications,
                  onRefresh: provider.loadNotifications,
                  onNotificationTap: (notification) {
                    _openPersonalNotification(
                      context,
                      notification,
                    );
                  },
                ),
                _AnnouncementsTab(
                  announcements: provider.announcements,
                  onRefresh: provider.loadNotifications,
                  onAnnouncementTap: (announcement) {
                    _openAnnouncement(
                      context,
                      announcement,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openPersonalNotification(
      BuildContext context,
      NotificationEntity notification,
      ) async {
    final provider = context.read<NotificationsProvider>();

    if (!notification.isRead) {
      await provider.markNotificationAsRead(notification.id);
    }

    if (!context.mounted) return;

    await _showDetailsDialog(
      context,
      title: notification.title,
      body: notification.body,
      date: notification.createdAt,
    );
  }

  Future<void> _openAnnouncement(
      BuildContext context,
      AnnouncementEntity announcement,
      ) async {
    final provider = context.read<NotificationsProvider>();

    if (!announcement.isRead) {
      await provider.markAnnouncementAsRead(announcement.id);
    }

    if (!context.mounted) return;

    await _showDetailsDialog(
      context,
      title: announcement.title,
      body: announcement.body,
      date: announcement.publishedAt,
    );
  }

  Future<void> _showDetailsDialog(
      BuildContext context, {
        required String title,
        required String body,
        required DateTime date,
      }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: _textColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    body,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.9,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _formatDate(date),
                    style: const TextStyle(
                      fontSize: 11,
                      color: _secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text(
                  'بستن',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PersonalNotificationsTab extends StatelessWidget {
  final List<NotificationEntity> notifications;
  final Future<void> Function() onRefresh;
  final ValueChanged<NotificationEntity> onNotificationTap;

  const _PersonalNotificationsTab({
    required this.notifications,
    required this.onRefresh,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return RefreshIndicator(
        color: NotificationsPage._primaryColor,
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 150),
            _EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'اعلانی وجود ندارد',
              description:
              'وقتی وضعیت سفارش شما تغییر کند، اعلان آن اینجا نمایش داده می‌شود.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: NotificationsPage._primaryColor,
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final notification = notifications[index];

          return _NotificationCard(
            title: notification.title,
            body: notification.body,
            date: notification.createdAt,
            isRead: notification.isRead,
            icon: Icons.local_shipping_outlined,
            onTap: () => onNotificationTap(notification),
          );
        },
      ),
    );
  }
}

class _AnnouncementsTab extends StatelessWidget {
  final List<AnnouncementEntity> announcements;
  final Future<void> Function() onRefresh;
  final ValueChanged<AnnouncementEntity> onAnnouncementTap;

  const _AnnouncementsTab({
    required this.announcements,
    required this.onRefresh,
    required this.onAnnouncementTap,
  });

  @override
  Widget build(BuildContext context) {
    if (announcements.isEmpty) {
      return RefreshIndicator(
        color: NotificationsPage._primaryColor,
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 150),
            _EmptyState(
              icon: Icons.campaign_outlined,
              title: 'اطلاعیه‌ای منتشر نشده',
              description:
              'اطلاعیه‌های جدید فروشگاه در این قسمت نمایش داده می‌شوند.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: NotificationsPage._primaryColor,
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: announcements.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final announcement = announcements[index];

          return _NotificationCard(
            title: announcement.title,
            body: announcement.body,
            date: announcement.publishedAt,
            isRead: announcement.isRead,
            icon: Icons.campaign_outlined,
            onTap: () => onAnnouncementTap(announcement),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String body;
  final DateTime date;
  final bool isRead;
  final IconData icon;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.title,
    required this.body,
    required this.date,
    required this.isRead,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = NotificationsPage._primaryColor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: isRead
            ? Colors.white
            : const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isRead
                    ? const Color(0xFFEAEAEA)
                    : const Color(0xFFF0C7C9),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                fontWeight: isRead
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                                color: NotificationsPage._textColor,
                              ),
                            ),
                          ),
                          if (!isRead) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE21B23),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.8,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              _formatDate(date),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 12,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 62,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: NotificationsPage._textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.8,
              color: NotificationsPage._secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: NotificationsPage._primaryColor,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('تلاش مجدد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NotificationsPage._primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final localDate = date.toLocal();

  final year = localDate.year.toString().padLeft(4, '0');
  final month = localDate.month.toString().padLeft(2, '0');
  final day = localDate.day.toString().padLeft(2, '0');
  final hour = localDate.hour.toString().padLeft(2, '0');
  final minute = localDate.minute.toString().padLeft(2, '0');

  return '$year/$month/$day - $hour:$minute';
}
