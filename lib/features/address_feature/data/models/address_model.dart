import 'package:supastore/features/address_feature/domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.receiverName,
    required super.phone,
    required super.province,
    required super.city,
    required super.address,
    super.postalCode,
    required super.isDefault,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AddressModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return AddressModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,

      title:
      map['title'] as String? ?? '',

      receiverName:
      map['receiver_name'] as String? ?? '',

      phone:
      map['phone'] as String? ?? '',

      province:
      map['province'] as String? ?? '',

      city:
      map['city'] as String? ?? '',

      address:
      map['address'] as String? ?? '',

      postalCode:
      map['postal_code'] as String?,

      isDefault:
      map['is_default'] as bool? ?? false,

      createdAt:
      DateTime.parse(
        map['created_at'] as String,
      ),

      updatedAt:
      DateTime.parse(
        map['updated_at'] as String,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'receiver_name': receiverName,
      'phone': phone,
      'province': province,
      'city': city,
      'address': address,
      'postal_code': postalCode,
      'is_default': isDefault,
      'created_at':
      createdAt.toIso8601String(),
      'updated_at':
      updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'title': title,
      'receiver_name': receiverName,
      'phone': phone,
      'province': province,
      'city': city,
      'address': address,
      'postal_code': postalCode,
      'is_default': isDefault,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'title': title,
      'receiver_name': receiverName,
      'phone': phone,
      'province': province,
      'city': city,
      'address': address,
      'postal_code': postalCode,
      'is_default': isDefault,
      'updated_at':
      DateTime.now().toIso8601String(),
    };
  }
}