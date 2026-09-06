import 'package:supastore/features/admin_feature/Users/domain/entities/admin_user.dart';

class AdminUserModel extends AdminUser {
  AdminUserModel({
    required super.id,
    required super.phone,
    required super.fullName,
    required super.avatarUrl,
    required super.isAdmin,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AdminUserModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return AdminUserModel(
      id: map['id'] as String,
      phone: map['phone'] as String?,
      fullName: map['full_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      isAdmin: map['is_admin'] as bool? ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(
        map['created_at'].toString(),
      )
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(
        map['updated_at'].toString(),
      )
          : null,
    );
  }
}