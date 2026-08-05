import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/product_image_entity.dart';

class ProductImageModel extends ProductImageEntity {
  const ProductImageModel({
    required super.id,
    required super.productId,
    required super.imageUrl,
    required super.sortOrder,
    required super.isPrimary,
    required super.createdAt,
  });

  factory ProductImageModel.fromMap(
      Map<String, dynamic> map,
      ) {
    final imagePath = map['image_url'] as String;

    return ProductImageModel(
      id: map['id'] as String,
      productId: map['product_id'] as String,

      imageUrl: Supabase.instance.client.storage
          .from('assets')
          .getPublicUrl(imagePath),

      sortOrder: map['sort_order'] as int,

      isPrimary: map['is_primary'] as bool,

      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
    );
  }
}