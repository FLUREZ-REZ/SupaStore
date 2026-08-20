import '../entities/flash_sale_product_entity.dart';

abstract class FlashSaleRepository {
  Future<List<FlashSaleProductEntity>>
  getActiveFlashSaleProducts();
}