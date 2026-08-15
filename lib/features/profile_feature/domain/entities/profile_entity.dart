class ProfileEntity {
  final String id;
  final String? phone;
  final String? fullName;
  final String? avatarUrl;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileEntity({
    required this.id,
    this.phone,
    this.fullName,
    this.avatarUrl,
    required this.isAdmin,
    required this.createdAt,
    required this.updatedAt,
  });
}