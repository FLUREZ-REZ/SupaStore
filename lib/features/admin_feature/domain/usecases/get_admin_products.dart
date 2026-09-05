import '../repositories/admin_product_repository.dart';

class GetAdminProducts {
  GetAdminProducts({
    required AdminProductRepository repository,
  }) : _repository = repository;

  final AdminProductRepository _repository;

  Future<List<Map<String, dynamic>>> call({
    required int page,
    required int limit,
    String? search,
  }) {
    return _repository.getProducts(
      page: page,
      limit: limit,
      search: search,
    );
  }
}