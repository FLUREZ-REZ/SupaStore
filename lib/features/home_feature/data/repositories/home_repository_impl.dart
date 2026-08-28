import 'package:supastore/features/home_feature/data/datasource/banner_remote_datasource.dart';
import 'package:supastore/features/home_feature/domain/entities/banner_entity.dart';
import 'package:supastore/features/home_feature/domain/repositories/home_repository.dart';

class BannerRepositoryImpl
    implements BannerRepository {
  BannerRepositoryImpl({
    required BannerRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final BannerRemoteDataSource _remoteDataSource;

  @override
  Future<List<BannerEntity>>
  getHeroBanners() async {
    return _remoteDataSource
        .getHeroBanners();
  }

  @override
  Future<List<BannerEntity>>
  getPromotionalBanners() async {
    return _remoteDataSource
        .getPromotionalBanners();
  }

  @override
  Future<List<BannerEntity>>
  getSingleBanners() async {
    return _remoteDataSource
        .getSingleBanners();
  }
}