import 'package:supastore/features/address_feature/domain/entities/address_entity.dart';
import 'package:supastore/features/address_feature/domain/repositories/address_repository.dart';

class AddAddressUseCase {
  AddAddressUseCase({
    required AddressRepository repository,
  }) : _repository = repository;

  final AddressRepository _repository;

  Future<AddressEntity> call({
    required AddressEntity address,
  }) {
    return _repository.addAddress(
      address: address,
    );
  }
}