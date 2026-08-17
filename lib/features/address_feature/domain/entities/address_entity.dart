class AddressEntity {
  final String id;

  final String userId;

  final String title;

  final String receiverName;

  final String phone;

  final String province;

  final String city;

  final String address;

  final String? postalCode;

  final bool isDefault;

  final DateTime createdAt;

  final DateTime updatedAt;

  const AddressEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.receiverName,
    required this.phone,
    required this.province,
    required this.city,
    required this.address,
    this.postalCode,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });
}