import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    super.phone,
    super.fullName,
    super.avatarUrl,
    required super.isAdmin,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProfileModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return ProfileModel(
      id: map['id'] as String,
      phone: map['phone'] as String?,
      fullName: map['full_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      isAdmin: map['is_admin'] as bool? ?? false,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] as String,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phone': phone,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'is_admin': isAdmin,
      'created_at':
      createdAt.toIso8601String(),
      'updated_at':
      updatedAt.toIso8601String(),
    };
  }
}