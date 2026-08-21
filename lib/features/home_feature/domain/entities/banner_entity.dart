class BannerEntity {
  final String id;

  final String title;

  final String? description;

  final String imageUrl;

  final String bannerType;

  final String? actionType;

  final String? actionValue;

  final int sortOrder;

  final bool isActive;

  final DateTime? startDate;

  final DateTime? endDate;

  final DateTime createdAt;

  final DateTime updatedAt;

  const BannerEntity({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    required this.bannerType,
    this.actionType,
    this.actionValue,
    required this.sortOrder,
    required this.isActive,
    this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCurrentlyActive {
    if (!isActive) {
      return false;
    }

    final now = DateTime.now();

    if (startDate != null &&
        now.isBefore(startDate!)) {
      return false;
    }

    if (endDate != null &&
        now.isAfter(endDate!)) {
      return false;
    }

    return true;
  }

  bool get hasAction {
    return actionType != null &&
        actionType!.isNotEmpty &&
        actionValue != null &&
        actionValue!.isNotEmpty;
  }
}