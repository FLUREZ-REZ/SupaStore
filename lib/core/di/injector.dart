import 'package:get_it/get_it.dart';
import 'package:supastore/features/home_feature/data/datasource/banner_remote_datasource.dart';
import 'package:supastore/features/home_feature/data/datasource/category_remote_datasource.dart';
import 'package:supastore/features/home_feature/data/repositories/category_repository_impl.dart';
import 'package:supastore/features/home_feature/data/repositories/home_repository_impl.dart';
import 'package:supastore/features/home_feature/domain/repositories/category_repository.dart';
import 'package:supastore/features/home_feature/domain/repositories/home_repository.dart';
import 'package:supastore/features/home_feature/presentation/providers/banner_provider.dart';
import 'package:supastore/features/home_feature/presentation/providers/category_provider.dart';
import 'package:supastore/features/product_feature/data/datasource/product_image_remote_datasource.dart';
import 'package:supastore/features/product_feature/data/datasource/product_remote_datasource.dart';
import 'package:supastore/features/product_feature/data/datasource/product_specification_remote_datasource.dart';
import 'package:supastore/features/product_feature/data/datasource/search_remote_datasource.dart';
import 'package:supastore/features/product_feature/data/repositories/product_image_repository_impl.dart';
import 'package:supastore/features/product_feature/data/repositories/product_repository_impl.dart';
import 'package:supastore/features/product_feature/data/repositories/product_specification_repository_impl.dart';
import 'package:supastore/features/product_feature/data/repositories/search_repository_impl.dart';
import 'package:supastore/features/product_feature/domain/repositories/product_image_repository.dart';
import 'package:supastore/features/product_feature/domain/repositories/product_repository.dart';
import 'package:supastore/features/product_feature/domain/repositories/product_specification_repository.dart';
import 'package:supastore/features/product_feature/domain/repositories/search_repository.dart';
import 'package:supastore/features/product_feature/presentation/providers/product_image_provider.dart';
import 'package:supastore/features/product_feature/presentation/providers/product_provider.dart';
import 'package:supastore/features/product_feature/presentation/providers/product_specification_provider.dart';
import 'package:supastore/features/product_feature/presentation/providers/search_provider.dart';



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

  getIt.registerLazySingleton<ProductImageRemoteDataSource>(
        () => ProductImageRemoteDataSource(),
  );

  getIt.registerLazySingleton<ProductImageRepository>(
        () => ProductImageRepositoryImpl(
      remoteDataSource: getIt<ProductImageRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<ProductImageProvider>(
        () => ProductImageProvider(
      repository: getIt<ProductImageRepository>(),
    ),
  );

  getIt.registerLazySingleton<ProductSpecificationRemoteDataSource>(
        () => ProductSpecificationRemoteDataSource(),
  );

  getIt.registerLazySingleton<ProductSpecificationRepository>(
        () => ProductSpecificationRepositoryImpl(
      remoteDataSource:
      getIt<ProductSpecificationRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<ProductSpecificationProvider>(
        () => ProductSpecificationProvider(
      repository: getIt<ProductSpecificationRepository>(),
    ),
  );

  getIt.registerLazySingleton<SearchRemoteDataSource>(
        () => SearchRemoteDataSource(),
  );

  getIt.registerLazySingleton<SearchRepository>(
        () => SearchRepositoryImpl(
      remoteDataSource:
      getIt<SearchRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<SearchProvider>(
        () => SearchProvider(
      repository: getIt<SearchRepository>(),
    ),
  );

}