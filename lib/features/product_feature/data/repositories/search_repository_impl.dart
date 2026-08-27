import 'package:supastore/features/product_feature/data/datasource/search_remote_datasource.dart';
import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';
import 'package:supastore/features/product_feature/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl({
    required SearchRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final SearchRemoteDataSource _remoteDataSource;

  @override
  Future<List<ProductEntity>> searchProducts({
    required String query,
    int page = 0,
    int limit = 10,
  }) {
    return _remoteDataSource.searchProducts(
      query: query,
      page: page,
      limit: limit,
    );
  }
}