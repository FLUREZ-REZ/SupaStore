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

  // ============================================================
  // SECURE CHECKOUT
  // ============================================================

  /// ایجاد Checkout امن از طریق Supabase Edge Function.
  ///
  /// مبلغ، تخفیف، هزینه ارسال و OrderItems
  /// در سمت Server محاسبه می‌شوند.
  ///
  /// Flutter فقط اطلاعات انتخاب‌های کاربر را ارسال می‌کند.
  Future<Map<String, dynamic>> createCheckout({
    required String addressId,
    required String shippingMethodId,
    required String paymentMethod,
  }) async {
    if (addressId.trim().isEmpty) {
      throw Exception(
        'آدرس ارسال انتخاب نشده است.',
      );
    }

    if (shippingMethodId.trim().isEmpty) {
      throw Exception(
        'روش ارسال انتخاب نشده است.',
      );
    }

    if (paymentMethod != 'online') {
      throw Exception(
        'روش پرداخت نامعتبر است.',
      );
    }

    final response =
    await _supabase.functions.invoke(
      'create-checkout',
      body: {
        'address_id': addressId,
        'shipping_method_id': shippingMethodId,
        'payment_method': paymentMethod,
      },
    );

    final data = response.data;

    if (data == null) {
      throw Exception(
        'پاسخ معتبری از سرور دریافت نشد.',
      );
    }

    if (data is! Map) {
      throw Exception(
        'فرمت پاسخ سرور نامعتبر است.',
      );
    }

    final result =
    Map<String, dynamic>.from(data);

    final success =
        result['success'] == true;

    if (!success) {
      final message =
          result['message'] ??
              result['error'] ??
              'ایجاد سفارش ناموفق بود.';

      throw Exception(
        message.toString(),
      );
    }

    final orderId =
    result['order_id'];

    final paymentId =
    result['payment_id'];

    final authority =
    result['authority'];

    final paymentUrl =
    result['payment_url'];

    if (orderId is! String ||
        orderId.isEmpty) {
      throw Exception(
        'شناسه سفارش از سرور دریافت نشد.',
      );
    }

    if (paymentId is! String ||
        paymentId.isEmpty) {
      throw Exception(
        'شناسه پرداخت از سرور دریافت نشد.',
      );
    }

    if (authority is! String ||
        authority.isEmpty) {
      throw Exception(
        'Authority پرداخت از سرور دریافت نشد.',
      );
    }

    if (paymentUrl is! String ||
        paymentUrl.isEmpty) {
      throw Exception(
        'آدرس پرداخت از سرور دریافت نشد.',
      );
    }

    return result;
  }

  // ============================================================
  // LEGACY CHECKOUT
  // ============================================================

  /// مسیر قدیمی Checkout.
  ///
  /// برای بخش‌های قدیمی پروژه نگه داشته شده است.
  ///
  /// برای خرید آنلاین جدید از createCheckout()
  /// استفاده شود.
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

  // ============================================================
  // LEGACY CREATE ORDER
  // ============================================================

  Future<Map<String, dynamic>> createOrder({
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
    final orderResponse =
    await _supabase
        .from('orders')
        .insert({
      'user_id': userId,
      'address_id': addressId,
      'subtotal': subtotal,
      'discount': discount,
      'shipping_cost': shippingCost,
      'total_price': totalPrice,
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
            'product_id': item.productId,
            'product_title': item.productTitle,
            'product_thumbnail':
            item.productThumbnail,
            'quantity': item.quantity,
            'unit_price': item.unitPrice,
            'discount_price':
            item.discountPrice,
            'total_price': item.totalPrice,
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

  // ============================================================
  // GET ORDERS
  // ============================================================

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

  // ============================================================
  // GET ORDER BY ID
  // ============================================================

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

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final response = await _supabase
        .from('orders')
        .select(_orderSelect)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    const allowedStatuses = {
      'pending',
      'processing',
      'shipped',
      'delivered',
      'canceled',
    };

    if (!allowedStatuses.contains(status)) {
      throw Exception('وضعیت سفارش نامعتبر است.');
    }

    final response = await _supabase
        .from('orders')
        .update({
      'status': status,
    })
        .eq('id', orderId)
        .select(_orderSelect)
        .single();

    return Map<String, dynamic>.from(response);
  }

}