import 'package:supastore/features/admin_feature/category/domain/entities/admin_category.dart';

abstract class AdminCategoryRepository {
  Future<List<AdminCategory>> getCategories({
    required int page,
    required int limit,
    String? search,
  });

  Future<void> createCategory({
    required Map<String, dynamic> data,
  });

  Future<void> updateCategory({
    required String categoryId,
    required Map<String, dynamic> data,
  });

  Future<void> deleteCategory({
    required String categoryId,
  });

  Future<String> uploadCategoryImage({
    required String filePath,
    String? slug,
  });
}