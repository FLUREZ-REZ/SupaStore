import 'package:supastore/features/order_feature/domain/entities/checkout_result_entity.dart';
import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';
import 'package:supastore/features/order_feature/domain/entities/order_item_entity.dart';

abstract class OrderRepository {
  Future<CheckoutResultEntity> createCheckout({
    required String addressId,
    required String shippingMethodId,
    required String paymentMethod,
  });

  Future<OrderEntity> checkout({
    required String userId,
    required String addressId,
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
    required String addressId,
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

  Future<List<OrderEntity>> getAllOrders();

  Future<OrderEntity> updateOrderStatus({
    required String orderId,
    required String status,
  });

}