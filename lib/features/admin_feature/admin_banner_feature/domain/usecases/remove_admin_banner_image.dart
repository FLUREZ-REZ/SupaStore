import '../repositories/admin_banner_repository.dart';

class RemoveAdminBannerImage {
  RemoveAdminBannerImage({
    required AdminBannerRepository repository,
  }) : _repository = repository;

  final AdminBannerRepository _repository;

  Future<void> call({
    required String imagePath,
  }) {
    return _repository.deleteBannerImage(
      imagePath: imagePath,
    );
  }
}