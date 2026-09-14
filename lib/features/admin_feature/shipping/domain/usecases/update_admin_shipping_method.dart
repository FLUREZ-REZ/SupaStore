import 'package:supastore/features/admin_feature/shipping/domain/entities/admin_shipping_method_entity.dart';
import 'package:supastore/features/admin_feature/shipping/domain/repositories/admin_shipping_repository.dart';

class UpdateAdminShippingMethod {
  UpdateAdminShippingMethod({
    required AdminShippingRepository repository,
  }) : _repository = repository;

  final AdminShippingRepository _repository;

  Future<AdminShippingMethodEntity> call({
    required String id,
    required String title,
    String? description,
    required int cost,
    String? estimatedDays,
    required bool isActive,
    required int sortOrder,
  }) async {
    return _repository.updateShippingMethod(
      id: id,
      title: title,
      description: description,
      cost: cost,
      estimatedDays: estimatedDays,
      isActive: isActive,
      sortOrder: sortOrder,
    );
  }
}