class ShippingMethodEntity {
  final String id;

  final String title;

  final String? description;

  final int cost;

  final String? estimatedDays;

  final bool isActive;

  final int sortOrder;

  final DateTime createdAt;

  const ShippingMethodEntity({
    required this.id,
    required this.title,
    this.description,
    required this.cost,
    this.estimatedDays,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
  });
}