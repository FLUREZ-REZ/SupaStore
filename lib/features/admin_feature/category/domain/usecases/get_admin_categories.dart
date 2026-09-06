import 'package:supastore/features/admin_feature/category/domain/entities/admin_category.dart';
import 'package:supastore/features/admin_feature/category/domain/repositories/admin_category_repository.dart';

class GetAdminCategories {
  const GetAdminCategories({
    required AdminCategoryRepository repository,
  }) : _repository = repository;

  final AdminCategoryRepository _repository;

  Future<List<AdminCategory>> call({
    required int page,
    required int limit,
    String? search,
  }) {
    return _repository.getCategories(
      page: page,
      limit: limit,
      search: search,
    );
  }
}