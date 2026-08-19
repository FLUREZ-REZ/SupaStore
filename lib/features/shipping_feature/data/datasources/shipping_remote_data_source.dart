import 'package:supabase_flutter/supabase_flutter.dart';

class ShippingRemoteDataSource {
  ShippingRemoteDataSource();

  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<List<Map<String, dynamic>>>
  getShippingMethods() async {
    final response = await _supabase
        .from('shipping_methods')
        .select('''
          id,
          title,
          description,
          cost,
          estimated_days,
          is_active,
          sort_order,
          created_at
        ''')
        .eq(
      'is_active',
      true,
    )
        .order(
      'sort_order',
      ascending: true,
    );

    return List<Map<String, dynamic>>.from(
      response,
    );
  }
}