import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/features/home_feature/domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.categoryId,
    super.brandId,
    required super.title,
    required super.slug,
    required super.description,
    required super.thumbnail,
    required super.price,
    super.discountPrice,
    required super.discountPercent,
    required super.rating,
    required super.reviewCount,
    required super.isAvailable,
    required super.isFeatured,
    required super.createdAt,
    required super.soldCount,
    required super.isNew,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    final thumbnailPath = map['thumbnail'] as String;

    return ProductModel(
      id: map['id'] as String,
      categoryId: map['category_id'] as String,
      brandId: map['brand_id'] as String?,
      title: map['title'] as String,
      slug: map['slug'] as String,
      description: map['description'] as String,
      thumbnail: Supabase.instance.client.storage
          .from('assets')
          .getPublicUrl(thumbnailPath),
      price: map['price'] as int,
      discountPrice: map['discount_price'] as int?,
      discountPercent: map['discount_percent'] as int,
      rating: (map['rating'] as num).toDouble(),
      reviewCount: map['review_count'] as int,
      isAvailable: map['is_available'] as bool,
      isFeatured: map['is_featured'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),

      soldCount: map['sold_count'] as int,
      isNew: map['is_new'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'brand_id': brandId,
      'title': title,
      'slug': slug,
      'description': description,
      'thumbnail': thumbnail,
      'price': price,
      'discount_price': discountPrice,
      'discount_percent': discountPercent,
      'rating': rating,
      'review_count': reviewCount,
      'is_available': isAvailable,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),

      'sold_count': soldCount,
      'is_new': isNew,
    };
  }
}