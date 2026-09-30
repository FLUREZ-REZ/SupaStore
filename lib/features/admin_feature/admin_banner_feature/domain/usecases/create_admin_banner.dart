import '../entities/admin_banner_entity.dart';
import '../repositories/admin_banner_repository.dart';

class CreateAdminBanner {
  CreateAdminBanner({
    required AdminBannerRepository repository,
  }) : _repository = repository;

  final AdminBannerRepository _repository;

  Future<AdminBannerEntity> call({
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
  }) {
    return _repository.createBanner(
      title: title,
      description: description,
      imagePath: imagePath,
      bannerType: bannerType,
      actionType: actionType,
      actionValue: actionValue,
      sortOrder: sortOrder,
      isActive: isActive,
      startDate: startDate,
      endDate: endDate,
    );
  }
}