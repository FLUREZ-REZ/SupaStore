class AdminStoreSettingsEntity {
  const AdminStoreSettingsEntity({
    required this.id,
    required this.storeName,
    required this.logoUrl,
    required this.tagline,
    required this.description,
    required this.phone,
    required this.email,
    required this.address,
    required this.postalCode,
    required this.instagram,
    required this.telegram,
    required this.website,
    required this.legalName,
    required this.nationalId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;

  final String storeName;
  final String? logoUrl;
  final String? tagline;
  final String? description;

  final String? phone;
  final String? email;

  final String? address;
  final String? postalCode;

  final String? instagram;
  final String? telegram;
  final String? website;

  final String? legalName;
  final String? nationalId;

  final DateTime createdAt;
  final DateTime updatedAt;
}