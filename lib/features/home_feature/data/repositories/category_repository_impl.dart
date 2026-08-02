import 'package:supastore/features/home_feature/data/datasource/category_remote_datasource.dart';
import 'package:supastore/features/home_feature/domain/entities/category_entity.dart';
import 'package:supastore/features/home_feature/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl({
    required CategoryRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final CategoryRemoteDataSource _remoteDataSource;

  @override
  Future<List<CategoryEntity>> getCategories() async {
    return await _remoteDataSource.getCategories();
  }
}