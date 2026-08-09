class OrderItemEntity {
  final String id;
  final String orderId;
  final String? productId;
  final String productTitle;
  final String? productThumbnail;
  final int quantity;
  final int unitPrice;
  final int? discountPrice;
  final int totalPrice;
  final DateTime createdAt;

  const OrderItemEntity({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productTitle,
    this.productThumbnail,
    required this.quantity,
    required this.unitPrice,
    this.discountPrice,
    required this.totalPrice,
    required this.createdAt,
  });

  OrderItemEntity copyWith({
    String? id,
    String? orderId,
    String? productId,
    String? productTitle,
    String? productThumbnail,
    int? quantity,
    int? unitPrice,
    int? discountPrice,
    int? totalPrice,
    DateTime? createdAt,
  }) {
    return OrderItemEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productTitle:
      productTitle ?? this.productTitle,
      productThumbnail:
      productThumbnail ?? this.productThumbnail,
      quantity:
      quantity ?? this.quantity,
      unitPrice:
      unitPrice ?? this.unitPrice,
      discountPrice:
      discountPrice ?? this.discountPrice,
      totalPrice:
      totalPrice ?? this.totalPrice,
      createdAt:
      createdAt ?? this.createdAt,
    );
  }
}