import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/features/home_feature/domain/entities/banner_entity.dart';

class BannerModel extends BannerEntity {
  const BannerModel({
    required super.id,
    required super.title,
    super.description,
    required super.imageUrl,
    required super.bannerType,
    super.actionType,
    super.actionValue,
    required super.sortOrder,
    required super.isActive,
    super.startDate,
    super.endDate,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BannerModel.fromMap(
      Map<String, dynamic> map,
      ) {
    final imagePath =
    map['image_url'] as String;

    return BannerModel(
      id: map['id'] as String,

      title:
      map['title'] as String,

      description:
      map['description'] as String?,

      imageUrl: Supabase
          .instance
          .client
          .storage
          .from('assets')
          .getPublicUrl(imagePath),

      bannerType:
      map['banner_type'] as String,

      actionType:
      map['action_type'] as String?,

      actionValue:
      map['action_value'] as String?,

      sortOrder:
      map['sort_order'] as int,

      isActive:
      map['is_active'] as bool,

      startDate:
      map['start_date'] != null
          ? DateTime.parse(
        map['start_date'] as String,
      )
          : null,

      endDate:
      map['end_date'] != null
          ? DateTime.parse(
        map['end_date'] as String,
      )
          : null,

      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),

      updatedAt: DateTime.parse(
        map['updated_at'] as String,
      ),
    );
  }
}