import 'package:supastore/features/admin_feature/category/domain/repositories/admin_category_repository.dart';

class UpdateAdminCategory {
  const UpdateAdminCategory({
    required AdminCategoryRepository repository,
  }) : _repository = repository;

  final AdminCategoryRepository _repository;

  Future<void> call({
    required String categoryId,
    required Map<String, dynamic> data,
  }) {
    return _repository.updateCategory(
      categoryId: categoryId,
      data: data,
    );
  }
}