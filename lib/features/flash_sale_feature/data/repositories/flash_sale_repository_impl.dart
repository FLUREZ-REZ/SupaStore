import 'package:supastore/features/flash_sale_feature/data/datasource/flash_sale_remote_data_source.dart';
import 'package:supastore/features/flash_sale_feature/domain/entities/flash_sale_product_entity.dart';
import 'package:supastore/features/flash_sale_feature/domain/repositories/flash_sale_repository.dart';

class FlashSaleRepositoryImpl
    implements FlashSaleRepository {

  final FlashSaleRemoteDataSource remoteDataSource;

  const FlashSaleRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<FlashSaleProductEntity>>
  getActiveFlashSaleProducts({
    int page = 0,
    int limit = 20,
  }) async {

    final models =
    await remoteDataSource.getActiveFlashSaleProducts(
      page: page,
      limit: limit,
    );

    return models
        .map(
          (model) => model.toEntity(),
    )
        .toList();
  }
}