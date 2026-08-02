import 'package:supastore/features/home_feature/data/datasource/banner_remote_datasource.dart';
import 'package:supastore/features/home_feature/domain/entities/banner_entity.dart';
import 'package:supastore/features/home_feature/domain/repositories/home_repository.dart';

class BannerRepositoryImpl implements BannerRepository {
  BannerRepositoryImpl({
    BannerRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
      remoteDataSource ?? BannerRemoteDataSource();

  final BannerRemoteDataSource _remoteDataSource;

  @override
  Future<List<BannerEntity>> getBanners() async {
    return await _remoteDataSource.getBanners();
  }
}