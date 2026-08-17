import 'package:supastore/features/address_feature/domain/repositories/address_repository.dart';

class DeleteAddressUseCase {
  DeleteAddressUseCase({
    required AddressRepository repository,
  }) : _repository = repository;

  final AddressRepository _repository;

  Future<void> call({
    required String addressId,
    required String userId,
  }) {
    return _repository.deleteAddress(
      addressId: addressId,
      userId: userId,
    );
  }
}