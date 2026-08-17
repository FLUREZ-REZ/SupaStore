import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/features/address_feature/data/models/address_model.dart';

class AddressRemoteDataSource {
  AddressRemoteDataSource({
    SupabaseClient? client,
  }) : _client =
      client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<AddressModel>> getAddresses({
    required String userId,
  }) async {
    final response = await _client
        .from('addresses')
        .select()
        .eq('user_id', userId)
        .order(
      'is_default',
      ascending: false,
    )
        .order(
      'created_at',
      ascending: false,
    );

    return (response as List)
        .map(
          (item) => AddressModel.fromMap(
        item as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  Future<AddressModel?> getDefaultAddress({
    required String userId,
  }) async {
    final response = await _client
        .from('addresses')
        .select()
        .eq('user_id', userId)
        .eq('is_default', true)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return AddressModel.fromMap(
      response,
    );
  }

  Future<AddressModel> addAddress({
    required AddressModel address,
  }) async {
    final response = await _client
        .from('addresses')
        .insert(
      address.toInsertMap(),
    )
        .select()
        .single();

    return AddressModel.fromMap(
      response,
    );
  }

  Future<AddressModel> updateAddress({
    required AddressModel address,
  }) async {
    final response = await _client
        .from('addresses')
        .update(
      address.toUpdateMap(),
    )
        .eq(
      'id',
      address.id,
    )
        .eq(
      'user_id',
      address.userId,
    )
        .select()
        .single();

    return AddressModel.fromMap(
      response,
    );
  }

  Future<void> deleteAddress({
    required String addressId,
    required String userId,
  }) async {
    await _client
        .from('addresses')
        .delete()
        .eq(
      'id',
      addressId,
    )
        .eq(
      'user_id',
      userId,
    );
  }

  Future<AddressModel> setDefaultAddress({
    required String addressId,
    required String userId,
  }) async {

    await _client
        .from('addresses')
        .update({
      'is_default': false,
      'updated_at':
      DateTime.now().toIso8601String(),
    })
        .eq(
      'user_id',
      userId,
    );

    final response = await _client
        .from('addresses')
        .update({
      'is_default': true,
      'updated_at':
      DateTime.now().toIso8601String(),
    })
        .eq(
      'id',
      addressId,
    )
        .eq(
      'user_id',
      userId,
    )
        .select()
        .single();

    return AddressModel.fromMap(
      response,
    );
  }
}