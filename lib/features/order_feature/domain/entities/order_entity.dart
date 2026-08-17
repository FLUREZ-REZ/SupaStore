import 'order_item_entity.dart';

class OrderEntity {
  final String id;
  final String userId;

  final String? addressId;

  final String status;
  final String paymentStatus;
  final String? paymentMethod;

  final int subtotal;
  final int discount;
  final int shippingCost;
  final int totalPrice;

  final String? shippingAddress;

  final DateTime createdAt;
  final DateTime updatedAt;

  final List<OrderItemEntity> items;

  const OrderEntity({
    required this.id,
    required this.userId,
    this.addressId,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    required this.subtotal,
    required this.discount,
    required this.shippingCost,
    required this.totalPrice,
    this.shippingAddress,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  OrderEntity copyWith({
    String? id,
    String? userId,
    String? addressId,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    int? subtotal,
    int? discount,
    int? shippingCost,
    int? totalPrice,
    String? shippingAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItemEntity>? items,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      addressId: addressId ?? this.addressId,
      status: status ?? this.status,
      paymentStatus:
      paymentStatus ?? this.paymentStatus,
      paymentMethod:
      paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      shippingCost: shippingCost ?? this.shippingCost,
      totalPrice: totalPrice ?? this.totalPrice,
      shippingAddress:
      shippingAddress ?? this.shippingAddress,
      createdAt:
      createdAt ?? this.createdAt,
      updatedAt:
      updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}