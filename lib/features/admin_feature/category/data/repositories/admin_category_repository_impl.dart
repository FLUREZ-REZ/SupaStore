import 'package:supastore/features/admin_feature/category/data/datasources/admin_category_remote_datasource.dart';
import 'package:supastore/features/admin_feature/category/domain/entities/admin_category.dart';
import 'package:supastore/features/admin_feature/category/domain/repositories/admin_category_repository.dart';

class AdminCategoryRepositoryImpl
    implements AdminCategoryRepository {
  const AdminCategoryRepositoryImpl({
    required AdminCategoryRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final AdminCategoryRemoteDataSource _remoteDataSource;

  @override
  Future<List<AdminCategory>> getCategories({
    required int page,
    required int limit,
    String? search,
  }) {
    return _remoteDataSource.getCategories(
      page: page,
      limit: limit,
      search: search,
    );
  }

  @override
  Future<void> createCategory({
    required Map<String, dynamic> data,
  }) {
    return _remoteDataSource.createCategory(
      data: data,
    );
  }

  @override
  Future<void> updateCategory({
    required String categoryId,
    required Map<String, dynamic> data,
  }) {
    return _remoteDataSource.updateCategory(
      categoryId: categoryId,
      data: data,
    );
  }

  @override
  Future<void> deleteCategory({
    required String categoryId,
  }) {
    return _remoteDataSource.deleteCategory(
      categoryId: categoryId,
    );
  }

  @override
  Future<String> uploadCategoryImage({
    required String filePath,
    String? slug,
  }) {
    return _remoteDataSource.uploadCategoryImage(
      filePath: filePath,
      slug: slug,
    );
  }
}