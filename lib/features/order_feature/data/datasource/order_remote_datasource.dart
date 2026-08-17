import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/features/order_feature/domain/entities/order_item_entity.dart';

class OrderRemoteDataSource {
  OrderRemoteDataSource({
    SupabaseClient? client,
  }) : _supabase =
      client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  static const String _orderSelect = '''
    id,
    user_id,
    address_id,
    subtotal,
    discount,
    shipping_cost,
    total_price,
    shipping_address,
    payment_method,
    payment_status,
    status,
    created_at,
    updated_at,
    order_items (
      id,
      order_id,
      product_id,
      product_title,
      product_thumbnail,
      quantity,
      unit_price,
      discount_price,
      total_price,
      created_at
    )
  ''';

  Future<Map<String, dynamic>> checkout({
    required String userId,

    required String addressId,

    required int subtotal,
    required int discount,
    required int shippingCost,
    required int totalPrice,

    required String shippingAddress,

    required String paymentMethod,

    required List<OrderItemEntity> items,
  }) async {
    return createOrder(
      userId: userId,
      addressId: addressId,
      subtotal: subtotal,
      discount: discount,
      shippingCost: shippingCost,
      totalPrice: totalPrice,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      items: items,
    );
  }

  Future<Map<String, dynamic>> createOrder({
    required String userId,

    /// ID آدرس انتخاب‌شده
    required String addressId,

    required int subtotal,
    required int discount,
    required int shippingCost,
    required int totalPrice,

    /// آدرس ذخیره‌شده در لحظه خرید
    required String shippingAddress,

    required String paymentMethod,

    required List<OrderItemEntity> items,
  }) async {

    final orderResponse =
    await _supabase
        .from('orders')
        .insert({
      'user_id': userId,

      // آدرس انتخاب‌شده
      'address_id': addressId,

      'subtotal': subtotal,
      'discount': discount,
      'shipping_cost': shippingCost,
      'total_price': totalPrice,

      // Snapshot آدرس
      'shipping_address': shippingAddress,

      'payment_method': paymentMethod,

      'payment_status': 'pending',

      'status': 'pending',
    })
        .select(_orderSelect)
        .single();

    final orderId =
    orderResponse['id'] as String;

    if (items.isNotEmpty) {
      final orderItems =
      items.map(
            (item) {
          return {
            'order_id': orderId,

            'product_id':
            item.productId,

            'product_title':
            item.productTitle,

            'product_thumbnail':
            item.productThumbnail,

            'quantity':
            item.quantity,

            'unit_price':
            item.unitPrice,

            'discount_price':
            item.discountPrice,

            'total_price':
            item.totalPrice,
          };
        },
      ).toList();

      await _supabase
          .from('order_items')
          .insert(orderItems);
    }

    final result =
    await _supabase
        .from('orders')
        .select(_orderSelect)
        .eq(
      'id',
      orderId,
    )
        .single();

    return Map<String, dynamic>.from(
      result,
    );
  }

  Future<List<Map<String, dynamic>>>
  getOrders(
      String userId,
      ) async {
    final response =
    await _supabase
        .from('orders')
        .select(_orderSelect)
        .eq(
      'user_id',
      userId,
    )
        .order(
      'created_at',
      ascending: false,
    );

    return List<
        Map<String, dynamic>>.from(
      response,
    );
  }

  Future<List<Map<String, dynamic>>>
  getUserOrders(
      String userId,
      ) async {
    return getOrders(userId);
  }

  Future<Map<String, dynamic>>
  getOrderById(
      String orderId,
      ) async {
    final response =
    await _supabase
        .from('orders')
        .select(_orderSelect)
        .eq(
      'id',
      orderId,
    )
        .single();

    return Map<String, dynamic>.from(
      response,
    );
  }
}