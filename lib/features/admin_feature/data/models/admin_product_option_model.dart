import '../../domain/entities/admin_product_option.dart';

class AdminProductOptionModel extends AdminProductOption {
  const AdminProductOptionModel({
    required super.id,
    required super.name,
    super.logoUrl,
  });

  factory AdminProductOptionModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return AdminProductOptionModel(
      id: map['id'] as String,
      name: map['name'] as String,
      logoUrl: map['logo_url'] as String?,
    );
  }
}