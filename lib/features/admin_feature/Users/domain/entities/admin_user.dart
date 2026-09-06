class AdminUser {
  AdminUser({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.avatarUrl,
    required this.isAdmin,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? phone;
  final String? fullName;
  final String? avatarUrl;
  final bool isAdmin;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}