import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supastore/features/notification_feature/domain/entities/admin_announcement_entity.dart';
import 'package:supastore/features/notification_feature/domain/entities/admin_announcements_lists.dart';

import '../../domain/entities/announcement_entity.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationsRemoteDataSource {
  NotificationsRemoteDataSource();

  final SupabaseClient _supabase = Supabase.instance.client;

  String get _userId {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw StateError('کاربر وارد حساب نشده است.');
    }

    return user.id;
  }

  Future<List<NotificationEntity>> getNotifications() async {
    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map(
          (item) => NotificationEntity.fromMap(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  /// دریافت اطلاعیه‌های فعال برای کاربران
  Future<List<AnnouncementEntity>> getAnnouncements() async {
    final now = DateTime.now().toUtc().toIso8601String();

    final response = await _supabase
        .from('announcements')
        .select()
        .eq('is_published', true)
        .lte('published_at', now)
        .or('expires_at.is.null,expires_at.gt.$now')
        .order('published_at', ascending: false);

    final announcements = (response as List)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    if (announcements.isEmpty) {
      return [];
    }

    final readsResponse = await _supabase
        .from('announcement_reads')
        .select('announcement_id')
        .eq('user_id', _userId);

    final readIds = (readsResponse as List)
        .map((item) => item['announcement_id'] as String)
        .toSet();

    return announcements.map((item) {
      return AnnouncementEntity.fromMap(
        item,
        isRead: readIds.contains(item['id']),
      );
    }).toList();
  }

  Future<void> markNotificationAsRead(
      String notificationId,
      ) async {
    await _supabase.rpc(
      'mark_notification_read',
      params: {
        'p_notification_id': notificationId,
      },
    );
  }

  Future<void> markAnnouncementAsRead(
      String announcementId,
      ) async {
    await _supabase.from('announcement_reads').upsert(
      {
        'announcement_id': announcementId,
        'user_id': _userId,
      },
      onConflict: 'announcement_id,user_id',
      ignoreDuplicates: true,
    );
  }

  /// انتشار اطلاعیه با تاریخ انقضای اختیاری
  Future<void> publishAnnouncement({
    required String title,
    required String body,
    DateTime? expiresAt,
  }) async {
    final normalizedTitle = title.trim();
    final normalizedBody = body.trim();

    if (normalizedTitle.isEmpty || normalizedBody.isEmpty) {
      throw ArgumentError(
        'عنوان و متن اطلاعیه نباید خالی باشند.',
      );
    }

    if (normalizedTitle.length > 200) {
      throw ArgumentError(
        'عنوان اطلاعیه حداکثر ۲۰۰ کاراکتر است.',
      );
    }

    if (normalizedBody.length > 10000) {
      throw ArgumentError(
        'متن اطلاعیه بیش از حد طولانی است.',
      );
    }

    if (expiresAt != null &&
        !expiresAt.toUtc().isAfter(DateTime.now().toUtc())) {
      throw ArgumentError(
        'تاریخ انقضا باید در آینده باشد.',
      );
    }

    await _supabase.from('announcements').insert({
      'author_id': _userId,
      'title': normalizedTitle,
      'body': normalizedBody,
      'is_published': true,
      'expires_at': expiresAt?.toUtc().toIso8601String(),
    });
  }

  Future<AdminAnnouncementsPage> getAdminAnnouncements({
    required int page,
    int pageSize = 10,
  }) async {
    if (page < 0 || pageSize < 1) {
      throw ArgumentError(
        'شماره صفحه یا اندازه صفحه نامعتبر است.',
      );
    }

    final from = page * pageSize;
    final to = from + pageSize;

    final response = await _supabase
        .from('announcements')
        .select()
        .order('created_at', ascending: false)
        .range(from, to);

    final rows = (response as List)
        .map(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();

    final hasMore = rows.length > pageSize;

    final items = rows
        .take(pageSize)
        .map(
          (item) => AdminAnnouncementEntity.fromMap(item),
    )
        .toList();

    return AdminAnnouncementsPage(
      items: items,
      hasMore: hasMore,
    );
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    if (announcementId.trim().isEmpty) {
      throw ArgumentError('شناسه اطلاعیه معتبر نیست.');
    }

    await _supabase
        .from('announcements')
        .delete()
        .eq('id', announcementId);
  }

}