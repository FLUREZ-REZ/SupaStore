import 'package:supastore/features/home_feature/domain/entities/banner_entity.dart';
import 'package:supastore/features/home_feature/domain/repositories/home_repository.dart';

class GetSingleBannersUseCase {
  const GetSingleBannersUseCase({
    required BannerRepository repository,
  }) : _repository = repository;

  final BannerRepository _repository;

  Future<List<BannerEntity>> call() {
    return _repository.getSingleBanners();
  }
}