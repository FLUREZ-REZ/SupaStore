import '../repositories/admin_product_repository.dart';

class UploadAdminProductImage {
  UploadAdminProductImage({
    required AdminProductRepository repository,
  }) : _repository = repository;

  final AdminProductRepository _repository;

  Future<String> call({
    required String filePath,
  }) {
    return _repository.uploadProductImage(
      filePath: filePath,
    );
  }
}