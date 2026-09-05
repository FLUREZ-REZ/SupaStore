import '../entities/admin_product_option.dart';

abstract class AdminProductRepository {
  Future<List<Map<String, dynamic>>> getProducts({
    required int page,
    required int limit,
    String? search,
  });

  Future<List<AdminProductOption>> getCategories();

  Future<List<AdminProductOption>> getBrands();

  Future<void> createProduct({
    required Map<String, dynamic> data,
  });

  Future<void> updateProduct({
    required String productId,
    required Map<String, dynamic> data,
  });

  Future<void> deleteProduct({
    required String productId,
  });

  Future<String> uploadProductImage({
    required String filePath,
  });
}