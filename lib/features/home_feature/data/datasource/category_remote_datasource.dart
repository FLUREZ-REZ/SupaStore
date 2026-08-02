import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category_model.dart';

class CategoryRemoteDataSource {
  CategoryRemoteDataSource({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .eq('is_active', true)
        .order(
      'sort_order',
      ascending: true,
    );

    return response
        .map<CategoryModel>(
          (json) => CategoryModel.fromMap(json),
    )
        .toList();
  }
}