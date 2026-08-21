

import 'package:supastore/features/product_feature/data/datasource/product_remote_datasource.dart';
import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';
import 'package:supastore/features/product_feature/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    required ProductRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ProductRemoteDataSource _remoteDataSource;

  @override
  Future<List<ProductEntity>> getProducts({
    int page = 0,
    int limit = 10,
  }) async {
    return await _remoteDataSource.getProducts(
      page: page,
      limit: limit,
    );
  }

  @override
  Future<List<ProductEntity>> getFeaturedProducts({
    int page = 0,
    int limit = 10,
  }) async {
    return await _remoteDataSource.getFeaturedProducts(
      page: page,
      limit: limit,
    );
  }

  @override
  Future<List<ProductEntity>> getNewestProducts({
    int page = 0,
    int limit = 10,
  }) async {
    return await _remoteDataSource.getNewestProducts(
      page: page,
      limit: limit,
    );
  }

  @override
  Future<List<ProductEntity>> getDiscountProducts({
    int page = 0,
    int limit = 10,
  }) async {
    return await _remoteDataSource.getDiscountProducts(
      page: page,
      limit: limit,
    );
  }

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

  @override
  Future<ProductEntity> getProductById(
      String productId,
      ) async {
    return _remoteDataSource.getProductById(
      productId,
    );
  }

}