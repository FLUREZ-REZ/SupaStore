import '../entities/product_image_entity.dart';

abstract class ProductImageRepository {
  Future<List<ProductImageEntity>> getProductImages(
      String productId,
      );
}