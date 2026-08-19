import 'package:supastore/features/shipping_feature/domain/entities/shipping_method_entity.dart';

abstract class ShippingRepository {
  Future<List<ShippingMethodEntity>>
  getShippingMethods();
}