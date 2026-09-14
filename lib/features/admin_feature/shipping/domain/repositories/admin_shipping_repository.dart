import 'package:supastore/features/admin_feature/shipping/domain/entities/admin_shipping_method_entity.dart';

abstract class AdminShippingRepository {
  Future<List<AdminShippingMethodEntity>> getShippingMethods();

  Future<AdminShippingMethodEntity> createShippingMethod({
    required String title,
    String? description,
    required int cost,
    String? estimatedDays,
    required bool isActive,
    required int sortOrder,
  });

  Future<AdminShippingMethodEntity> updateShippingMethod({
    required String id,
    required String title,
    String? description,
    required int cost,
    String? estimatedDays,
    required bool isActive,
    required int sortOrder,
  });

  Future<void> deleteShippingMethod({
    required String id,
  });
}