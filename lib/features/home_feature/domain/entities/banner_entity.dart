class BannerEntity {
  final String id;

  final String title;

  final String imageUrl;

  final String? actionType;

  final String? actionValue;

  final int sortOrder;

  final bool isActive;

  const BannerEntity({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.sortOrder,
    required this.isActive,
    this.actionType,
    this.actionValue,
  });
}