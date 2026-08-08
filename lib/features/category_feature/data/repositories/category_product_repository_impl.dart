

import 'package:supastore/features/category_feature/data/datasources/category_product_remote_datasource.dart';
import 'package:supastore/features/category_feature/domain/repositories/category_product_repository.dart';
import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';

class CategoryProductRepositoryImpl
    implements CategoryProductRepository {

  CategoryProductRepositoryImpl({
    required CategoryProductRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final CategoryProductRemoteDataSource _remoteDataSource;


  @override
  Future<List<ProductEntity>> getProductsByCategory({
    required String categoryId,
    int page = 0,
    int limit = 10,
  }) async {

    return await _remoteDataSource.getProductsByCategory(
      categoryId: categoryId,
      page: page,
      limit: limit,
    );

  }
}