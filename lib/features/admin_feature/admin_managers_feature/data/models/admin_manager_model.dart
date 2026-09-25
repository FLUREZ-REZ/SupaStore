import '../../domain/entities/admin_manager_entity.dart';

class AdminManagerModel extends AdminManagerEntity {
  const AdminManagerModel({
    required super.id,
    required super.phone,
    required super.fullName,
    required super.avatarUrl,
    required super.isAdmin,
    required super.adminRole,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AdminManagerModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AdminManagerModel(
      id: json['id'] as String,
      phone: json['phone'] as String? ?? '',
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isAdmin: json['is_admin'] as bool? ?? false,
      adminRole: json['admin_role'] as String? ?? 'none',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(
        json['created_at'] as String,
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'is_admin': isAdmin,
      'admin_role': adminRole,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}