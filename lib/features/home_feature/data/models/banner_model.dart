import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supastore/features/home_feature/domain/entities/banner_entity.dart';

class BannerModel extends BannerEntity {
  const BannerModel({
    required super.id,
    required super.title,
    required super.imageUrl,
    required super.sortOrder,
    required super.isActive,
    super.actionType,
    super.actionValue,
  });

  factory BannerModel.fromMap(Map<String, dynamic> map) {
    final imagePath = map['image_url'] as String;

    return BannerModel(
      id: map['id'] as String,
      title: map['title'] as String,
      imageUrl: Supabase.instance.client.storage
          .from('assets')
          .getPublicUrl(imagePath),
      actionType: map['action_type'] as String?,
      actionValue: map['action_value'] as String?,
      sortOrder: map['sort_order'] as int,
      isActive: map['is_active'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'action_type': actionType,
      'action_value': actionValue,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }
}