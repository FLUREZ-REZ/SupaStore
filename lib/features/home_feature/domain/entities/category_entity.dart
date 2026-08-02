class CategoryEntity {
  final String id;

  final String name;

  final String imageUrl;

  final int sortOrder;

  final bool isActive;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.sortOrder,
    required this.isActive,
  });
}