import '../repositories/admin_product_repository.dart';

class UpdateAdminProduct {
  UpdateAdminProduct({
    required AdminProductRepository repository,
  }) : _repository = repository;

  final AdminProductRepository _repository;

  Future<void> call({
    required String productId,
    required Map<String, dynamic> data,
  }) {
    return _repository.updateProduct(
      productId: productId,
      data: data,
    );
  }
}