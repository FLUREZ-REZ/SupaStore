import '../entities/flash_sale_product_entity.dart';
import '../repositories/flash_sale_repository.dart';

class GetActiveFlashSaleProductsUseCase {
  final FlashSaleRepository repository;

  const GetActiveFlashSaleProductsUseCase({
    required this.repository,
  });

  Future<List<FlashSaleProductEntity>> call({
    int page = 0,
    int limit = 20,
  }) {
    return repository.getActiveFlashSaleProducts(
      page: page,
      limit: limit,
    );
  }
}