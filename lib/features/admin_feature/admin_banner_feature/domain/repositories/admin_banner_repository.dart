import '../entities/admin_banner_entity.dart';

abstract class AdminBannerRepository {
  Future<List<AdminBannerEntity>> getBanners({
    String? bannerType,
    String? search,
  });

  Future<AdminBannerEntity> createBanner({
    required String title,
    String? description,
    required String imagePath,
    required String bannerType,
    String? actionType,
    String? actionValue,
    required int sortOrder,
    required bool isActive,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<AdminBannerEntity> updateBanner({
    required String bannerId,
    required String title,
    String? description,
    required String imagePath,
    required String bannerType,
    String? actionType,
    String? actionValue,
    required int sortOrder,
    required bool isActive,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<void> deleteBanner({
    required String bannerId,
  });

  Future<AdminBannerEntity> updateBannerStatus({
    required String bannerId,
    required bool isActive,
  });

  Future<String> uploadBannerImage({
    required dynamic file,
  });

  Future<void> deleteBannerImage({
    required String imagePath,
  });
}