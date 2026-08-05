import 'package:supastore/features/product_feature/data/datasource/product_image_remote_datasource.dart';
import 'package:supastore/features/product_feature/domain/entities/product_image_entity.dart';
import 'package:supastore/features/product_feature/domain/repositories/product_image_repository.dart';

class ProductImageRepositoryImpl implements ProductImageRepository {
  ProductImageRepositoryImpl({
    required ProductImageRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ProductImageRemoteDataSource _remoteDataSource;

  @override
  Future<List<ProductImageEntity>> getProductImages(
      String productId,
      ) {
    return _remoteDataSource.getProductImages(productId);
  }
}