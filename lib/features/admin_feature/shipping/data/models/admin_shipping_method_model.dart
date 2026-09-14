import 'package:supastore/features/admin_feature/shipping/domain/entities/admin_shipping_method_entity.dart';

class AdminShippingMethodModel
    extends AdminShippingMethodEntity {
  const AdminShippingMethodModel({
    required super.id,
    required super.title,
    super.description,
    required super.cost,
    super.estimatedDays,
    required super.isActive,
    required super.sortOrder,
    required super.createdAt,
  });

  factory AdminShippingMethodModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return AdminShippingMethodModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      cost: int.parse(
        map['cost'].toString(),
      ),
      estimatedDays:
      map['estimated_days'] as String?,
      isActive:
      map['is_active'] as bool,
      sortOrder: int.parse(
        map['sort_order'].toString(),
      ),
      createdAt: DateTime.parse(
        map['created_at'].toString(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cost': cost,
      'estimated_days': estimatedDays,
      'is_active': isActive,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }
}