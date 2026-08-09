import 'package:supabase_flutter/supabase_flutter.dart';

class OrderRemoteDataSource {
  OrderRemoteDataSource({
    SupabaseClient? client,
  }) : _supabase =
      client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  // ==================================================
  // CHECKOUT
  // ==================================================

  Future<Map<String, dynamic>> checkout({
    required String userId,
    required int subtotal,
    required int discount,
    required int shippingCost,
    required int totalPrice,
    required String shippingAddress,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    final response =
    await _supabase.rpc(
      'checkout_order',
      params: {
        'p_user_id': userId,
        'p_subtotal': subtotal,
        'p_discount': discount,
        'p_shipping_cost': shippingCost,
        'p_total_price': totalPrice,
        'p_shipping_address':
        shippingAddress,
        'p_payment_method':
        paymentMethod,
        'p_items': items,
      },
    );

    return Map<String, dynamic>.from(
      response,
    );
  }

  // ==================================================
  // CREATE ORDER
  // ==================================================

  Future<Map<String, dynamic>> createOrder({
    required String userId,
    required int subtotal,
    required int discount,
    required int shippingCost,
    required int totalPrice,
    required String shippingAddress,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    final response =
    await _supabase.rpc(
      'checkout_order',
      params: {
        'p_user_id': userId,
        'p_subtotal': subtotal,
        'p_discount': discount,
        'p_shipping_cost': shippingCost,
        'p_total_price': totalPrice,
        'p_shipping_address':
        shippingAddress,
        'p_payment_method':
        paymentMethod,
        'p_items': items,
      },
    );

    return Map<String, dynamic>.from(
      response,
    );
  }

  // ==================================================
  // GET ORDERS
  // ==================================================

  Future<List<Map<String, dynamic>>>
  getOrders(
      String userId,
      ) async {
    final response =
    await _supabase
        .from('orders')
        .select('''
              id,
              user_id,
              status,
              payment_status,
              payment_method,
              subtotal,
              discount,
              shipping_cost,
              total_price,
              shipping_address,
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
            ''')
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

  // ==================================================
  // GET ORDER BY ID
  // ==================================================

  Future<Map<String, dynamic>>
  getOrderById(
      String orderId,
      ) async {
    final response =
    await _supabase
        .from('orders')
        .select('''
              id,
              user_id,
              status,
              payment_status,
              payment_method,
              subtotal,
              discount,
              shipping_cost,
              total_price,
              shipping_address,
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
            ''')
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