import 'package:supastore/features/address_feature/domain/entities/address_entity.dart';
import 'package:supastore/features/address_feature/domain/repositories/address_repository.dart';

class UpdateAddressUseCase {
  UpdateAddressUseCase({
    required AddressRepository repository,
  }) : _repository = repository;

  final AddressRepository _repository;

  Future<AddressEntity> call({
    required AddressEntity address,
  }) {
    return _repository.updateAddress(
      address: address,
    );
  }
}