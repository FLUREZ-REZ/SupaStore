import 'package:supastore/features/admin_feature/category/domain/repositories/admin_category_repository.dart';

class DeleteAdminCategory {
  const DeleteAdminCategory({
    required AdminCategoryRepository repository,
  }) : _repository = repository;

  final AdminCategoryRepository _repository;

  Future<void> call({
    required String categoryId,
  }) {
    return _repository.deleteCategory(
      categoryId: categoryId,
    );
  }
}