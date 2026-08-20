import '../entities/flash_sale_product_entity.dart';
import '../repositories/flash_sale_repository.dart';

class GetActiveFlashSaleProductsUseCase {
  final FlashSaleRepository repository;

  const GetActiveFlashSaleProductsUseCase({
    required this.repository,
  });

  Future<List<FlashSaleProductEntity>> call() {
    return repository.getActiveFlashSaleProducts();
  }
}