import 'package:supastore/features/admin_feature/shipping/domain/repositories/admin_shipping_repository.dart';

class DeleteAdminShippingMethod {
  DeleteAdminShippingMethod({
    required AdminShippingRepository repository,
  }) : _repository = repository;

  final AdminShippingRepository _repository;

  Future<void> call({
    required String id,
  }) async {
    await _repository.deleteShippingMethod(
      id: id,
    );
  }
}