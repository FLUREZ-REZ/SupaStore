import '../entities/product_specification_entity.dart';

abstract class ProductSpecificationRepository {

  Future<List<ProductSpecificationEntity>>
  getProductSpecifications(
      String productId,
      );

}