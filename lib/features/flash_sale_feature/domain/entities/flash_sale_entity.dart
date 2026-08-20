class FlashSaleEntity {
  final String id;
  final String productId;
  final int discountPrice;
  final DateTime startAt;
  final DateTime endAt;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;

  const FlashSaleEntity({
    required this.id,
    required this.productId,
    required this.discountPrice,
    required this.startAt,
    required this.endAt,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
  });

  bool get isStarted =>
      !DateTime.now().isBefore(startAt);

  bool get isExpired =>
      DateTime.now().isAfter(endAt);

  bool get isRunning =>
      isActive &&
          isStarted &&
          !isExpired;
}