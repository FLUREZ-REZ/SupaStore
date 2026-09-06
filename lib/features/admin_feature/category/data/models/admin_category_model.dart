import 'package:supastore/features/admin_feature/category/domain/entities/admin_category.dart';

class AdminCategoryModel extends AdminCategory {
  const AdminCategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.imageUrl,
    required super.sortOrder,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AdminCategoryModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return AdminCategoryModel(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      slug: map['slug'] as String? ?? '',
      imageUrl: map['image_url'] as String?,
      sortOrder: map['sort_order'] as int? ?? 0,
      isActive: map['is_active'] as bool? ?? true,
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'image_url': imageUrl,
      'sort_order': sortOrder,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}