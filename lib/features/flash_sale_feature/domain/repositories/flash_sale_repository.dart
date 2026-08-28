import '../entities/flash_sale_product_entity.dart';

abstract class FlashSaleRepository {
  Future<List<FlashSaleProductEntity>>
  getActiveFlashSaleProducts({
    int page = 0,
    int limit = 20,
  });
}