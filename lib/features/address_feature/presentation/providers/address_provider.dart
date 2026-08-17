import 'package:flutter/foundation.dart';

import 'package:supastore/features/address_feature/domain/entities/address_entity.dart';
import 'package:supastore/features/address_feature/domain/usecases/add_address_use_case.dart';
import 'package:supastore/features/address_feature/domain/usecases/delete_address_use_case.dart';
import 'package:supastore/features/address_feature/domain/usecases/get_addresses_use_case.dart';
import 'package:supastore/features/address_feature/domain/usecases/get_default_address_use_case.dart';
import 'package:supastore/features/address_feature/domain/usecases/set_default_address_use_case.dart';
import 'package:supastore/features/address_feature/domain/usecases/update_address_use_case.dart';

class AddressProvider extends ChangeNotifier {
  AddressProvider({
    required GetAddressesUseCase getAddressesUseCase,
    required GetDefaultAddressUseCase getDefaultAddressUseCase,
    required AddAddressUseCase addAddressUseCase,
    required UpdateAddressUseCase updateAddressUseCase,
    required DeleteAddressUseCase deleteAddressUseCase,
    required SetDefaultAddressUseCase setDefaultAddressUseCase,
  })  : _getAddressesUseCase = getAddressesUseCase,
        _getDefaultAddressUseCase =
            getDefaultAddressUseCase,
        _addAddressUseCase = addAddressUseCase,
        _updateAddressUseCase =
            updateAddressUseCase,
        _deleteAddressUseCase =
            deleteAddressUseCase,
        _setDefaultAddressUseCase =
            setDefaultAddressUseCase;

  final GetAddressesUseCase _getAddressesUseCase;

  final GetDefaultAddressUseCase
  _getDefaultAddressUseCase;

  final AddAddressUseCase _addAddressUseCase;

  final UpdateAddressUseCase
  _updateAddressUseCase;

  final DeleteAddressUseCase
  _deleteAddressUseCase;

  final SetDefaultAddressUseCase
  _setDefaultAddressUseCase;

  List<AddressEntity> _addresses = [];

  List<AddressEntity> get addresses =>
      List.unmodifiable(_addresses);

  AddressEntity? _defaultAddress;

  AddressEntity? get defaultAddress =>
      _defaultAddress;

  AddressEntity? _selectedAddress;

  AddressEntity? get selectedAddress =>
      _selectedAddress;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isUpdating = false;

  bool get isUpdating => _isUpdating;

  String? _error;

  String? get error => _error;

  bool get isEmpty => _addresses.isEmpty;

  bool get isNotEmpty => _addresses.isNotEmpty;

  Future<void> loadAddresses({
    required String userId,
  }) async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      final result =
      await _getAddressesUseCase(
        userId: userId,
      );

      _addresses = result;

      _defaultAddress = _findDefaultAddress();

      // اگر آدرس انتخاب‌شده دیگر وجود نداشت،
      // آن را پاک می‌کنیم.

      if (_selectedAddress != null) {
        final exists =
        _addresses.any(
              (address) =>
          address.id ==
              _selectedAddress!.id,
        );

        if (!exists) {
          _selectedAddress =
              _defaultAddress;
        }
      } else {
        _selectedAddress =
            _defaultAddress;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;

    notifyListeners();
  }

  Future<void> loadDefaultAddress({
    required String userId,
  }) async {
    _error = null;

    try {
      final result =
      await _getDefaultAddressUseCase(
        userId: userId,
      );

      _defaultAddress = result;

      if (result != null) {
        _selectedAddress = result;
      }
    } catch (e) {
      _error = e.toString();

      notifyListeners();

      return;
    }

    notifyListeners();
  }

  Future<bool> addAddress({
    required AddressEntity address,
  }) async {
    _isUpdating = true;
    _error = null;

    notifyListeners();

    try {
      final result =
      await _addAddressUseCase(
        address: address,
      );

      _addresses = [
        ..._addresses,
        result,
      ];


      if (result.isDefault ||
          _addresses.length == 1) {
        _defaultAddress = result;
        _selectedAddress = result;
      }

      _isUpdating = false;

      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();

      _isUpdating = false;

      notifyListeners();

      return false;
    }
  }

  Future<bool> updateAddress({
    required AddressEntity address,
  }) async {
    _isUpdating = true;
    _error = null;

    notifyListeners();

    try {
      final result =
      await _updateAddressUseCase(
        address: address,
      );

      final index =
      _addresses.indexWhere(
            (item) =>
        item.id == address.id,
      );

      if (index != -1) {
        final updated =
        List<AddressEntity>.from(
          _addresses,
        );

        updated[index] = result;

        _addresses = updated;
      }

      if (result.isDefault) {
        _defaultAddress = result;
      }

      if (_selectedAddress?.id ==
          result.id) {
        _selectedAddress = result;
      }

      _defaultAddress =
          _findDefaultAddress();

      _isUpdating = false;

      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();

      _isUpdating = false;

      notifyListeners();

      return false;
    }
  }

  Future<bool> deleteAddress({
    required String addressId,
    required String userId,
  }) async {
    _isUpdating = true;
    _error = null;

    notifyListeners();

    try {
      await _deleteAddressUseCase(
        addressId: addressId,
        userId: userId,
      );

      _addresses =
          _addresses.where(
                (address) =>
            address.id != addressId,
          ).toList();

      if (_selectedAddress?.id ==
          addressId) {
        _selectedAddress =
            _findDefaultAddress();
      }

      if (_defaultAddress?.id ==
          addressId) {
        _defaultAddress =
            _findDefaultAddress();
      }

      _isUpdating = false;

      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();

      _isUpdating = false;

      notifyListeners();

      return false;
    }
  }

  Future<bool> setDefaultAddress({
    required String addressId,
    required String userId,
  }) async {
    _isUpdating = true;
    _error = null;

    notifyListeners();

    try {
      final result =
      await _setDefaultAddressUseCase(
        addressId: addressId,
        userId: userId,
      );


      _addresses =
          _addresses.map(
                (address) {
              if (address.id ==
                  addressId) {
                return result;
              }

              return AddressEntity(
                id: address.id,
                userId: address.userId,
                title: address.title,
                receiverName:
                address.receiverName,
                phone: address.phone,
                province: address.province,
                city: address.city,
                address: address.address,
                postalCode:
                address.postalCode,
                isDefault: false,
                createdAt:
                address.createdAt,
                updatedAt:
                address.updatedAt,
              );
            },
          ).toList();

      _defaultAddress = result;

      _selectedAddress = result;

      _isUpdating = false;

      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();

      _isUpdating = false;

      notifyListeners();

      return false;
    }
  }

  void selectAddress(
      AddressEntity address,
      ) {
    _selectedAddress = address;

    notifyListeners();
  }

  Future<void> refresh({
    required String userId,
  }) async {
    await loadAddresses(
      userId: userId,
    );
  }

  void clearAddresses() {
    _addresses = [];

    _defaultAddress = null;

    _selectedAddress = null;

    _error = null;

    notifyListeners();
  }

  void clearError() {
    _error = null;

    notifyListeners();
  }

  AddressEntity? _findDefaultAddress() {
    for (final address in _addresses) {
      if (address.isDefault) {
        return address;
      }
    }

    return null;
  }
}