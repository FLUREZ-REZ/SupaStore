import '../entities/admin_banner_entity.dart';
import '../repositories/admin_banner_repository.dart';

class GetAdminBanners {
  GetAdminBanners({
    required AdminBannerRepository repository,
  }) : _repository = repository;

  final AdminBannerRepository _repository;

  Future<List<AdminBannerEntity>> call({
    String? bannerType,
    String? search,
  }) {
    return _repository.getBanners(
      bannerType: bannerType,
      search: search,
    );
  }
}