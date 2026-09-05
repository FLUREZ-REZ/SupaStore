import '../repositories/admin_product_repository.dart';

class CreateAdminProduct {
  CreateAdminProduct({
    required AdminProductRepository repository,
  }) : _repository = repository;

  final AdminProductRepository _repository;

  Future<void> call({
    required Map<String, dynamic> data,
  }) {
    return _repository.createProduct(
      data: data,
    );
  }
}