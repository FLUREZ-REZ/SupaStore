import 'package:supastore/features/address_feature/domain/entities/address_entity.dart';

abstract class AddressRepository {

  Future<List<AddressEntity>> getAddresses({
    required String userId,
  });

  Future<AddressEntity?> getDefaultAddress({
    required String userId,
  });

  Future<AddressEntity> addAddress({
    required AddressEntity address,
  });

  Future<AddressEntity> updateAddress({
    required AddressEntity address,
  });

  Future<void> deleteAddress({
    required String addressId,
    required String userId,
  });

  Future<AddressEntity> setDefaultAddress({
    required String addressId,
    required String userId,
  });
}