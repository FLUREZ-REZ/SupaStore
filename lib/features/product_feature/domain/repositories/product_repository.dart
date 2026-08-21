import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';

abstract class ProductRepository {

  Future<List<ProductEntity>> getProducts({
    int page = 0,
    int limit = 10,
  });

  Future<List<ProductEntity>> getFeaturedProducts({
    int page = 0,
    int limit = 10,
  });

  Future<List<ProductEntity>> getNewestProducts({
    int page = 0,
    int limit = 10,
  });

  Future<List<ProductEntity>> getDiscountProducts({
    int page = 0,
    int limit = 10,
  });

  Future<List<ProductEntity>> getProductsByCategory({
    required String categoryId,
    int page = 0,
    int limit = 10,
  });

  Future<ProductEntity> getProductById(String productId);
}