class FavoriteEntity {
  final String id;
  final String userId;
  final String productId;
  final DateTime createdAt;

  const FavoriteEntity({
    required this.id,
    required this.userId,
    required this.productId,
    required this.createdAt,
  });
}