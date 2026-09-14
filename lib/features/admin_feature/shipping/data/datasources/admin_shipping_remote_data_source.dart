import 'package:supabase_flutter/supabase_flutter.dart';

class AdminShippingRemoteDataSource {
  AdminShippingRemoteDataSource();

  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getShippingMethods() async {
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
        .order(
      'sort_order',
      ascending: true,
    )
        .order(
      'created_at',
      ascending: false,
    );

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createShippingMethod({
    required String title,
    String? description,
    required int cost,
    String? estimatedDays,
    required bool isActive,
    required int sortOrder,
  }) async {
    final response = await _supabase
        .from('shipping_methods')
        .insert({
      'title': title,
      'description': description,
      'cost': cost,
      'estimated_days': estimatedDays,
      'is_active': isActive,
      'sort_order': sortOrder,
    })
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
        .single();

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> updateShippingMethod({
    required String id,
    required String title,
    String? description,
    required int cost,
    String? estimatedDays,
    required bool isActive,
    required int sortOrder,
  }) async {
    final response = await _supabase
        .from('shipping_methods')
        .update({
      'title': title,
      'description': description,
      'cost': cost,
      'estimated_days': estimatedDays,
      'is_active': isActive,
      'sort_order': sortOrder,
    })
        .eq('id', id)
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
        .single();

    return Map<String, dynamic>.from(response);
  }

  Future<void> deleteShippingMethod({
    required String id,
  }) async {
    await _supabase
        .from('shipping_methods')
        .delete()
        .eq('id', id);
  }
}