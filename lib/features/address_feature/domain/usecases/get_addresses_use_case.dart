import 'package:supastore/features/address_feature/domain/entities/address_entity.dart';
import 'package:supastore/features/address_feature/domain/repositories/address_repository.dart';

class GetAddressesUseCase {
  GetAddressesUseCase({
    required AddressRepository repository,
  }) : _repository = repository;

  final AddressRepository _repository;

  Future<List<AddressEntity>> call({
    required String userId,
  }) {
    return _repository.getAddresses(
      userId: userId,
    );
  }
}