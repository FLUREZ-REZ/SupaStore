import 'package:supastore/features/address_feature/data/datasources/address_remote_data_source.dart';
import 'package:supastore/features/address_feature/data/models/address_model.dart';
import 'package:supastore/features/address_feature/domain/entities/address_entity.dart';
import 'package:supastore/features/address_feature/domain/repositories/address_repository.dart';

class AddressRepositoryImpl
    implements AddressRepository {
  AddressRepositoryImpl({
    required AddressRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final AddressRemoteDataSource _remoteDataSource;

  // ============================================================
  // GET ADDRESSES
  // ============================================================

  @override
  Future<List<AddressEntity>> getAddresses({
    required String userId,
  }) async {
    final result =
    await _remoteDataSource.getAddresses(
      userId: userId,
    );

    return result;
  }

  // ============================================================
  // GET ADDRESS BY ID
  // ============================================================

  @override
  Future<AddressEntity?> getAddressById({
    required String addressId,
  }) async {
    final result =
    await _remoteDataSource.getAddressById(
      addressId: addressId,
    );

    return result;
  }

  // ============================================================
  // GET DEFAULT ADDRESS
  // ============================================================

  @override
  Future<AddressEntity?> getDefaultAddress({
    required String userId,
  }) async {
    final result =
    await _remoteDataSource.getDefaultAddress(
      userId: userId,
    );

    return result;
  }

  // ============================================================
  // ADD ADDRESS
  // ============================================================

  @override
  Future<AddressEntity> addAddress({
    required AddressEntity address,
  }) async {
    final model = AddressModel(
      id: address.id,
      userId: address.userId,
      title: address.title,
      receiverName: address.receiverName,
      phone: address.phone,
      province: address.province,
      city: address.city,
      address: address.address,
      postalCode: address.postalCode,
      isDefault: address.isDefault,
      createdAt: address.createdAt,
      updatedAt: address.updatedAt,
    );

    return await _remoteDataSource.addAddress(
      address: model,
    );
  }

  // ============================================================
  // UPDATE ADDRESS
  // ============================================================

  @override
  Future<AddressEntity> updateAddress({
    required AddressEntity address,
  }) async {
    final model = AddressModel(
      id: address.id,
      userId: address.userId,
      title: address.title,
      receiverName: address.receiverName,
      phone: address.phone,
      province: address.province,
      city: address.city,
      address: address.address,
      postalCode: address.postalCode,
      isDefault: address.isDefault,
      createdAt: address.createdAt,
      updatedAt: address.updatedAt,
    );

    return await _remoteDataSource.updateAddress(
      address: model,
    );
  }

  // ============================================================
  // DELETE ADDRESS
  // ============================================================

  @override
  Future<void> deleteAddress({
    required String addressId,
    required String userId,
  }) async {
    await _remoteDataSource.deleteAddress(
      addressId: addressId,
      userId: userId,
    );
  }

  // ============================================================
  // SET DEFAULT ADDRESS
  // ============================================================

  @override
  Future<AddressEntity> setDefaultAddress({
    required String addressId,
    required String userId,
  }) async {
    return await _remoteDataSource.setDefaultAddress(
      addressId: addressId,
      userId: userId,
    );
  }
}