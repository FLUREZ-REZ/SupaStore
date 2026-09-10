import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardRemoteDataSource {
  AdminDashboardRemoteDataSource({
    SupabaseClient? client,
  }) : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  static const String _recentOrdersSelect = '''
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

  Future<Map<String, dynamic>> getDashboardStats({
    int days = 7,
  }) async {
    final response = await _supabase.rpc(
      'get_admin_dashboard_stats',
      params: {
        'p_days': days,
      },
    );

    if (response == null) {
      throw Exception(
        'اطلاعات داشبورد دریافت نشد.',
      );
    }

    if (response is! Map) {
      throw Exception(
        'فرمت پاسخ داشبورد نامعتبر است.',
      );
    }

    return Map<String, dynamic>.from(
      response,
    );
  }

  Future<int> getTotalProducts() async {
    final response = await _supabase
        .from('products')
        .select('id');

    return response.length;
  }

  Future<int> getTotalUsers() async {
    final response = await _supabase
        .from('profiles')
        .select('id');

    return response.length;
  }

  Future<List<Map<String, dynamic>>>
  getRecentOrders() async {
    final response = await _supabase
        .from('orders')
        .select(_recentOrdersSelect)
        .order(
      'created_at',
      ascending: false,
    )
        .limit(5);

    return List<Map<String, dynamic>>.from(
      response,
    );
  }
}