import '../entities/admin_product_option.dart';
import '../repositories/admin_product_repository.dart';

class GetAdminProductOptions {
  GetAdminProductOptions({
    required AdminProductRepository repository,
  }) : _repository = repository;

  final AdminProductRepository _repository;

  Future<List<AdminProductOption>> getCategories() {
    return _repository.getCategories();
  }

  Future<List<AdminProductOption>> getBrands() {
    return _repository.getBrands();
  }
}