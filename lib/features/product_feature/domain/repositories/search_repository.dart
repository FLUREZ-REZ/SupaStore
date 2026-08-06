import '../entities/product_entity.dart';

abstract class SearchRepository {
  Future<List<ProductEntity>> searchProducts(
      String query,
      );
}