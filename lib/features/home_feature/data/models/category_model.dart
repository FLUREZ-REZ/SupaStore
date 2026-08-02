import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supastore/features/home_feature/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.sortOrder,
    required super.isActive,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    final imagePath = map['image_url'] as String;

    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      imageUrl: Supabase.instance.client.storage
          .from('assets')
          .getPublicUrl(imagePath),
      sortOrder: map['sort_order'] as int,
      isActive: map['is_active'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }
}