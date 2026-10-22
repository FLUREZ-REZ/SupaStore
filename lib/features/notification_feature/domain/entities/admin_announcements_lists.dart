import 'admin_announcement_entity.dart';

class AdminAnnouncementsPage {
  final List<AdminAnnouncementEntity> items;
  final bool hasMore;

  const AdminAnnouncementsPage({
    required this.items,
    required this.hasMore,
  });
}