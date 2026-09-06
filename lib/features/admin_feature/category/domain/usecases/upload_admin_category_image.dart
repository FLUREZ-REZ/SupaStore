import 'package:supastore/features/admin_feature/category/domain/repositories/admin_category_repository.dart';

class UploadAdminCategoryImage {
  const UploadAdminCategoryImage({
    required AdminCategoryRepository repository,
  }) : _repository = repository;

  final AdminCategoryRepository _repository;

  Future<String> call({
    required String filePath,
    String? slug,
  }) {
    return _repository.uploadCategoryImage(
      filePath: filePath,
      slug: slug,
    );
  }
}