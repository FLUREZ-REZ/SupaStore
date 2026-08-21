import 'package:supastore/features/home_feature/domain/entities/category_entity.dart';

import '../../../product_feature/domain/entities/product_entity.dart';

abstract class CategoryProductRepository {
  Future<List<ProductEntity>> getProductsByCategory({
    required String categoryId,
    int page = 0,
    int limit = 10,
  });

  Future<CategoryEntity> getCategoryById(
      String categoryId,
      );

}