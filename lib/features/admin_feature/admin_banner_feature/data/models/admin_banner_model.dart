import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/admin_banner_entity.dart';

class AdminBannerModel extends AdminBannerEntity {
  const AdminBannerModel({
    required super.id,
    required super.title,
    super.description,
    required super.imagePath,
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

  factory AdminBannerModel.fromMap(
      Map<String, dynamic> map,
      ) {
    final imagePath =
    map['image_url'] as String;

    final imageUrl = Supabase
        .instance
        .client
        .storage
        .from('assets')
        .getPublicUrl(imagePath);

    return AdminBannerModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description:
      map['description'] as String?,
      imagePath: imagePath,
      imageUrl: imageUrl,
      bannerType:
      map['banner_type'] as String,
      actionType:
      map['action_type'] as String?,
      actionValue:
      map['action_value'] as String?,
      sortOrder:
      (map['sort_order'] as num).toInt(),
      isActive:
      map['is_active'] as bool? ?? true,
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