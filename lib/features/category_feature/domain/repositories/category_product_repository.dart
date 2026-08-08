import '../../../product_feature/domain/entities/product_entity.dart';

abstract class CategoryProductRepository {
  Future<List<ProductEntity>> getProductsByCategory({
    required String categoryId,
    int page = 0,
    int limit = 10,
  });
}