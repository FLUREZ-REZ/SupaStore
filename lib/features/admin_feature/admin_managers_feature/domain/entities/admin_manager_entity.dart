class AdminManagerEntity {
  const AdminManagerEntity({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.avatarUrl,
    required this.isAdmin,
    required this.adminRole,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String phone;
  final String? fullName;
  final String? avatarUrl;

  final bool isAdmin;
  final String adminRole;
  final bool isActive;

  final DateTime createdAt;
  final DateTime updatedAt;
}