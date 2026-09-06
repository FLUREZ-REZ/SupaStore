import 'package:supastore/features/admin_feature/category/domain/repositories/admin_category_repository.dart';

class CreateAdminCategory {
  const CreateAdminCategory({
    required AdminCategoryRepository repository,
  }) : _repository = repository;

  final AdminCategoryRepository _repository;

  Future<void> call({
    required Map<String, dynamic> data,
  }) {
    return _repository.createCategory(
      data: data,
    );
  }
}