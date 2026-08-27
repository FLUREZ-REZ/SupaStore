import '../entities/product_entity.dart';

abstract class SearchRepository {
  Future<List<ProductEntity>> searchProducts({
    required String query,
    int page = 0,
    int limit = 10,
  });
}