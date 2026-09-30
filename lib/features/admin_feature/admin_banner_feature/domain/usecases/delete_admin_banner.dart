import '../repositories/admin_banner_repository.dart';

class DeleteAdminBanner {
  DeleteAdminBanner({
    required AdminBannerRepository repository,
  }) : _repository = repository;

  final AdminBannerRepository _repository;

  Future<void> call({
    required String bannerId,
  }) {
    return _repository.deleteBanner(
      bannerId: bannerId,
    );
  }
}