import 'package:supastore/features/product_feature/data/datasource/product_specification_remote_datasource.dart';
import 'package:supastore/features/product_feature/domain/entities/product_specification_entity.dart';
import 'package:supastore/features/product_feature/domain/repositories/product_specification_repository.dart';

class ProductSpecificationRepositoryImpl
    implements ProductSpecificationRepository {

  ProductSpecificationRepositoryImpl({
    required ProductSpecificationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ProductSpecificationRemoteDataSource _remoteDataSource;

  @override
  Future<List<ProductSpecificationEntity>> getProductSpecifications(
      String productId,
      ) {
    return _remoteDataSource.getProductSpecifications(
      productId,
    );
  }
}