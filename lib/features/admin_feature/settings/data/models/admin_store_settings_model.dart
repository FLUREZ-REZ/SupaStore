import 'package:supastore/features/admin_feature/settings/domain/entities/admin_store_settings_entity.dart';

class AdminStoreSettingsModel
    extends AdminStoreSettingsEntity {
  const AdminStoreSettingsModel({
    required super.id,
    required super.storeName,
    required super.logoUrl,
    required super.tagline,
    required super.description,
    required super.phone,
    required super.email,
    required super.address,
    required super.postalCode,
    required super.instagram,
    required super.telegram,
    required super.website,
    required super.legalName,
    required super.nationalId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AdminStoreSettingsModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return AdminStoreSettingsModel(
      id: map['id'] as String,
      storeName: map['store_name'] as String? ?? '',
      logoUrl: map['logo_url'] as String?,
      tagline: map['tagline'] as String?,
      description: map['description'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      postalCode: map['postal_code'] as String?,
      instagram: map['instagram'] as String?,
      telegram: map['telegram'] as String?,
      website: map['website'] as String?,
      legalName: map['legal_name'] as String?,
      nationalId: map['national_id'] as String?,
      createdAt: DateTime.parse(
        map['created_at'].toString(),
      ),
      updatedAt: DateTime.parse(
        map['updated_at'].toString(),
      ),
    );
  }

  factory AdminStoreSettingsModel.empty() {
    final now = DateTime.now();

    return AdminStoreSettingsModel(
      id: '',
      storeName: '',
      logoUrl: null,
      tagline: null,
      description: null,
      phone: null,
      email: null,
      address: null,
      postalCode: null,
      instagram: null,
      telegram: null,
      website: null,
      legalName: null,
      nationalId: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'store_name': storeName,
      'logo_url': logoUrl,
      'tagline': tagline,
      'description': description,
      'phone': phone,
      'email': email,
      'address': address,
      'postal_code': postalCode,
      'instagram': instagram,
      'telegram': telegram,
      'website': website,
      'legal_name': legalName,
      'national_id': nationalId,
    };
  }
}