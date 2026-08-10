import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';
import 'package:supastore/features/order_feature/domain/entities/order_item_entity.dart';

abstract class OrderRepository {
  Future<OrderEntity> checkout({
    required String userId,
    required int subtotal,
    required int discount,
    required int shippingCost,
    required int totalPrice,
    required String shippingAddress,
    required String paymentMethod,
    required List<OrderItemEntity> items,
  });

  Future<OrderEntity> createOrder({
    required String userId,
    required int subtotal,
    required int discount,
    required int shippingCost,
    required int totalPrice,
    required String shippingAddress,
    required String paymentMethod,
    required List<OrderItemEntity> items,
  });

  Future<List<OrderEntity>> getOrders(
      String userId,
      );

  Future<OrderEntity> getOrderById(
      String orderId,
      );

  Future<List<OrderEntity>> getUserOrders(
      String userId,
      );

}