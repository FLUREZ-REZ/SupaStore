import '../repositories/admin_product_repository.dart';

class DeleteAdminProduct {
  DeleteAdminProduct({
    required AdminProductRepository repository,
  }) : _repository = repository;

  final AdminProductRepository _repository;

  Future<void> call({
    required String productId,
  }) {
    return _repository.deleteProduct(
      productId: productId,
    );
  }
}