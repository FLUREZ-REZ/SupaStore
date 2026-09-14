import 'package:supastore/features/admin_feature/shipping/domain/entities/admin_shipping_method_entity.dart';
import 'package:supastore/features/admin_feature/shipping/domain/repositories/admin_shipping_repository.dart';

class GetAdminShippingMethods {
  GetAdminShippingMethods({
    required AdminShippingRepository repository,
  }) : _repository = repository;

  final AdminShippingRepository _repository;

  Future<List<AdminShippingMethodEntity>> call() async {
    return _repository.getShippingMethods();
  }
}