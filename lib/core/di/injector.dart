import 'package:get_it/get_it.dart';
import 'package:supastore/features/home_feature/data/datasource/banner_remote_datasource.dart';
import 'package:supastore/features/home_feature/data/repositories/home_repository_impl.dart';
import 'package:supastore/features/home_feature/domain/repositories/home_repository.dart';
import 'package:supastore/features/home_feature/presentation/providers/banner_provider.dart';



final getIt = GetIt.instance;

Future<void> setupInjector() async {

  /// Banner DataSource
  getIt.registerLazySingleton<BannerRemoteDataSource>(
        () => BannerRemoteDataSource(),
  );

  /// Banner Repository
  getIt.registerLazySingleton<BannerRepository>(
        () => BannerRepositoryImpl(
      remoteDataSource: getIt<BannerRemoteDataSource>(),
    ),
  );

  /// Banner Provider
  getIt.registerFactory<BannerProvider>(
        () => BannerProvider(
      repository: getIt<BannerRepository>(),
    ),
  );
}