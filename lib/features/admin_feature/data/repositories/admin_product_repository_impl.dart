import '../../domain/entities/admin_product_option.dart';
import '../../domain/repositories/admin_product_repository.dart';
import '../datasources/admin_product_remote_datasource.dart';

class AdminProductRepositoryImpl
    implements AdminProductRepository {
  AdminProductRepositoryImpl({
    required AdminProductRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final AdminProductRemoteDataSource _remoteDataSource;

  @override
  Future<List<Map<String, dynamic>>> getProducts({
    required int page,
    required int limit,
    String? search,
  }) {
    return _remoteDataSource.getProducts(
      page: page,
      limit: limit,
      search: search,
    );
  }

  @override
  Future<List<AdminProductOption>> getCategories() {
    return _remoteDataSource.getCategories();
  }

  @override
  Future<List<AdminProductOption>> getBrands() {
    return _remoteDataSource.getBrands();
  }

  @override
  Future<void> createProduct({
    required Map<String, dynamic> data,
  }) {
    return _remoteDataSource.createProduct(
      data: data,
    );
  }

  @override
  Future<void> updateProduct({
    required String productId,
    required Map<String, dynamic> data,
  }) {
    return _remoteDataSource.updateProduct(
      productId: productId,
      data: data,
    );
  }

  @override
  Future<void> deleteProduct({
    required String productId,
  }) {
    return _remoteDataSource.deleteProduct(
      productId: productId,
    );
  }

  @override
  Future<String> uploadProductImage({
    required String filePath,
  }) {
    return _remoteDataSource.uploadProductImage(
      filePath: filePath,
    );
  }
}