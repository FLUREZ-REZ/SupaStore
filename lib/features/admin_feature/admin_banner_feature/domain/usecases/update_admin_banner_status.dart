import '../entities/admin_banner_entity.dart';
import '../repositories/admin_banner_repository.dart';

class UpdateAdminBannerStatus {
  UpdateAdminBannerStatus({
    required AdminBannerRepository repository,
  }) : _repository = repository;

  final AdminBannerRepository _repository;

  Future<AdminBannerEntity> call({
    required String bannerId,
    required bool isActive,
  }) {
    return _repository.updateBannerStatus(
      bannerId: bannerId,
      isActive: isActive,
    );
  }
}