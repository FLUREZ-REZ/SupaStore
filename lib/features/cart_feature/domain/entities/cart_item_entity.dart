import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';

class CartItemEntity {
  final String id;
  final String userId;
  final String productId;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProductEntity product;

  const CartItemEntity({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
  });

  CartItemEntity copyWith({
    String? id,
    String? userId,
    String? productId,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProductEntity? product,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      product: product ?? this.product,
    );
  }
}