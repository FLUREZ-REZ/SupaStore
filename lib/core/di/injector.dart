import 'package:get_it/get_it.dart';
import 'package:supastore/features/home_feature/data/datasource/banner_remote_datasource.dart';
import 'package:supastore/features/home_feature/data/datasource/category_remote_datasource.dart';
import 'package:supastore/features/home_feature/data/repositories/category_repository_impl.dart';
import 'package:supastore/features/home_feature/data/repositories/home_repository_impl.dart';
import 'package:supastore/features/home_feature/domain/repositories/category_repository.dart';
import 'package:supastore/features/home_feature/domain/repositories/home_repository.dart';
import 'package:supastore/features/home_feature/presentation/providers/banner_provider.dart';
import 'package:supastore/features/home_feature/presentation/providers/category_provider.dart';
import 'package:supastore/features/product_feature/data/datasource/product_remote_datasource.dart';
import 'package:supastore/features/product_feature/data/repositories/product_repository_impl.dart';
import 'package:supastore/features/product_feature/domain/repositories/product_repository.dart';
import 'package:supastore/features/product_feature/presentation/providers/product_provider.dart';



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

  getIt.registerLazySingleton<CategoryRemoteDataSource>(
        () => CategoryRemoteDataSource(),
  );

  getIt.registerLazySingleton<CategoryRepository>(
        () => CategoryRepositoryImpl(
      remoteDataSource: getIt<CategoryRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<CategoryProvider>(
        () => CategoryProvider(
      repository: getIt<CategoryRepository>(),
    ),
  );

  getIt.registerLazySingleton<ProductRemoteDataSource>(
        () => ProductRemoteDataSource(),
  );

  getIt.registerLazySingleton<ProductRepository>(
        () => ProductRepositoryImpl(
      remoteDataSource: getIt<ProductRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<ProductProvider>(
        () => ProductProvider(
      repository: getIt<ProductRepository>(),
    ),
  );

}