class AdminBannerEntity {
  const AdminBannerEntity({
    required this.id,
    required this.title,
    this.description,
    required this.imagePath,
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

  final String id;
  final String title;
  final String? description;

  /// Path stored in Supabase database.
  /// Example:
  /// banners/GPT1.webp
  final String imagePath;

  /// Public URL generated from imagePath.
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

  bool get hasAction {
    return actionType != null &&
        actionType!.isNotEmpty &&
        actionValue != null &&
        actionValue!.isNotEmpty;
  }

  String get bannerTypeTitle {
    switch (bannerType) {
      case 'hero':
        return 'هیرو';

      case 'promotional':
        return 'تبلیغاتی';

      case 'bottom_home':
        return 'بنر پایین صفحه';

      default:
        return bannerType;
    }
  }

  String get actionTypeTitle {
    switch (actionType) {
      case 'product':
        return 'محصول';

      case 'category':
        return 'دسته‌بندی';

      case 'url':
        return 'لینک';

      default:
        return 'بدون عملکرد';
    }
  }
}