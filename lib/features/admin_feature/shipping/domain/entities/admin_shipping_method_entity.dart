class AdminShippingMethodEntity {
  final String id;
  final String title;
  final String? description;
  final int cost;
  final String? estimatedDays;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;

  const AdminShippingMethodEntity({
    required this.id,
    required this.title,
    this.description,
    required this.cost,
    this.estimatedDays,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
  });

  AdminShippingMethodEntity copyWith({
    String? id,
    String? title,
    String? description,
    int? cost,
    String? estimatedDays,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return AdminShippingMethodEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      estimatedDays: estimatedDays ?? this.estimatedDays,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}