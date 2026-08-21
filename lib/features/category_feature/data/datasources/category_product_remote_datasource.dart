import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supastore/features/home_feature/data/models/category_model.dart';
import 'package:supastore/features/product_feature/data/models/product_model.dart';

class CategoryProductRemoteDataSource {
  CategoryProductRemoteDataSource({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<ProductModel>> getProductsByCategory({
    required String categoryId,
    int page = 0,
    int limit = 10,
  }) async {
    final from = page * limit;
    final to = from + limit - 1;

    final response = await _client
        .from('products')
        .select()
        .eq('category_id', categoryId)
        .eq('is_active', true)
        .order(
      'created_at',
      ascending: false,
    )
        .range(from, to);

    return response
        .map<ProductModel>(
          (json) => ProductModel.fromMap(json),
    )
        .toList();
  }

  Future<CategoryModel> getCategoryById(
      String categoryId,
      ) async {
    final response = await _client
        .from('categories')
        .select()
        .eq('id', categoryId)
        .single();

    return CategoryModel.fromMap(response);
  }

}