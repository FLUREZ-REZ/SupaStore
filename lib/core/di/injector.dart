import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================
// ADDRESS FEATURE
// ============================================================

import 'package:supastore/features/address_feature/data/datasources/address_remote_data_source.dart';
import 'package:supastore/features/address_feature/data/repositories/address_repository_impl.dart';
import 'package:supastore/features/address_feature/domain/repositories/address_repository.dart';
import 'package:supastore/features/address_feature/domain/usecases/add_address_use_case.dart';
import 'package:supastore/features/address_feature/domain/usecases/delete_address_use_case.dart';
import 'package:supastore/features/address_feature/domain/usecases/get_addresses_use_case.dart';
import 'package:supastore/features/address_feature/domain/usecases/get_default_address_use_case.dart';
import 'package:supastore/features/address_feature/domain/usecases/set_default_address_use_case.dart';
import 'package:supastore/features/address_feature/domain/usecases/update_address_use_case.dart';
import 'package:supastore/features/address_feature/presentation/providers/address_provider.dart';

// ============================================================
// CART FEATURE
// ============================================================

import 'package:supastore/features/cart_feature/data/datasource/cart_remote_datasource.dart';
import 'package:supastore/features/cart_feature/data/repositories/cart_repository_impl.dart';
import 'package:supastore/features/cart_feature/domain/repositories/cart_repository.dart';
import 'package:supastore/features/cart_feature/presentation/providers/cart_provider.dart';

// ============================================================
// CATEGORY FEATURE
// ============================================================

import 'package:supastore/features/category_feature/data/datasources/category_product_remote_datasource.dart';
import 'package:supastore/features/category_feature/data/repositories/category_product_repository_impl.dart';
import 'package:supastore/features/category_feature/domain/repositories/category_product_repository.dart';
import 'package:supastore/features/category_feature/presentation/providers/category_product_provider.dart';

// ============================================================
// FAVORITE FEATURE
// ============================================================

import 'package:supastore/features/favorite_feature/data/datasource/favorite_remote_datasource.dart';
import 'package:supastore/features/favorite_feature/data/repositories/favorite_repository_impl.dart';
import 'package:supastore/features/favorite_feature/domain/repositories/favorite_repository.dart';
import 'package:supastore/features/favorite_feature/presentation/providers/favorite_provider.dart';

// ============================================================
// FLASH SALE FEATURE
// ============================================================

import 'package:supastore/features/flash_sale_feature/data/datasource/flash_sale_remote_data_source.dart';
import 'package:supastore/features/flash_sale_feature/data/repositories/flash_sale_repository_impl.dart';
import 'package:supastore/features/flash_sale_feature/domain/repositories/flash_sale_repository.dart';
import 'package:supastore/features/flash_sale_feature/domain/usecases/get_active_flash_sales_use_case.dart';
import 'package:supastore/features/flash_sale_feature/presentation/providers/flash_sale_provider.dart';

// ============================================================
// HOME FEATURE - BANNER
// ============================================================

import 'package:supastore/features/home_feature/data/datasource/banner_remote_datasource.dart';
import 'package:supastore/features/home_feature/data/datasource/category_remote_datasource.dart';
import 'package:supastore/features/home_feature/data/repositories/home_repository_impl.dart';
import 'package:supastore/features/home_feature/data/repositories/category_repository_impl.dart';
import 'package:supastore/features/home_feature/domain/get_single_banners_use_case.dart';
import 'package:supastore/features/home_feature/domain/repositories/home_repository.dart';
import 'package:supastore/features/home_feature/domain/repositories/category_repository.dart';
import 'package:supastore/features/home_feature/presentation/providers/banner_provider.dart';
import 'package:supastore/features/home_feature/presentation/providers/category_provider.dart';

// ============================================================
// ORDER FEATURE
// ============================================================

import 'package:supastore/features/order_feature/data/datasource/order_remote_datasource.dart';
import 'package:supastore/features/order_feature/data/repositories/order_repository_impl.dart';
import 'package:supastore/features/order_feature/domain/repositories/order_repository.dart';
import 'package:supastore/features/order_feature/presentation/providers/checkout_provider.dart';
import 'package:supastore/features/order_feature/presentation/providers/order_provider.dart';

// ============================================================
// PRODUCT FEATURE
// ============================================================

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

import 'package:supastore/features/product_feature/presentation/providers/latest_products_provider.dart';
import 'package:supastore/features/product_feature/presentation/providers/popular_products_provider.dart';
import 'package:supastore/features/product_feature/presentation/providers/product_image_provider.dart';
import 'package:supastore/features/product_feature/presentation/providers/product_provider.dart';
import 'package:supastore/features/product_feature/presentation/providers/product_specification_provider.dart';
import 'package:supastore/features/product_feature/presentation/providers/related_products_provider.dart';
import 'package:supastore/features/product_feature/presentation/providers/search_provider.dart';

// ============================================================
// PROFILE FEATURE
// ============================================================

import 'package:supastore/features/profile_feature/data/datasources/profile_remote_data_source.dart';
import 'package:supastore/features/profile_feature/data/repositories/profile_repository_impl.dart';
import 'package:supastore/features/profile_feature/domain/repositories/profile_repository.dart';
import 'package:supastore/features/profile_feature/domain/usecases/create_profile_use_case.dart';
import 'package:supastore/features/profile_feature/domain/usecases/get_profile_use_case.dart';
import 'package:supastore/features/profile_feature/domain/usecases/update_profile_use_case.dart';
import 'package:supastore/features/profile_feature/presentation/providers/profile_provider.dart';
import 'package:supastore/features/review_feature/data/datasources/blocked_word_remote_data_source.dart';
import 'package:supastore/features/review_feature/data/datasources/review_remote_data_source.dart';
import 'package:supastore/features/review_feature/data/repositories/blocked_word_repository_impl.dart';
import 'package:supastore/features/review_feature/data/repositories/review_repository_impl.dart';
import 'package:supastore/features/review_feature/domain/repositories/blocked_word_repository.dart';
import 'package:supastore/features/review_feature/domain/repositories/review_repository.dart';
import 'package:supastore/features/review_feature/presentation/providers/review_provider.dart';

// ============================================================
// SETTINGS FEATURE
// ============================================================

import 'package:supastore/features/settings_feature/data/datasources/settings_local_data_source.dart';
import 'package:supastore/features/settings_feature/presentation/providers/settings_provider.dart';

// ============================================================
// SHIPPING FEATURE
// ============================================================

import 'package:supastore/features/shipping_feature/data/datasources/shipping_remote_data_source.dart';
import 'package:supastore/features/shipping_feature/data/repositories/shipping_repository_impl.dart';
import 'package:supastore/features/shipping_feature/domain/repositories/shipping_repository.dart';
import 'package:supastore/features/shipping_feature/presentation/providers/shipping_provider.dart';

// ============================================================
// GET IT
// ============================================================

final getIt = GetIt.instance;


// ============================================================
// SETUP INJECTOR
// ============================================================

Future<void> setupInjector() async {
  // ==========================================================
  // SHARED PREFERENCES
  // ==========================================================

  final sharedPreferences =
  await SharedPreferences.getInstance();

  getIt.registerSingleton<SharedPreferences>(
    sharedPreferences,
  );

  // ==========================================================
  // BANNER FEATURE
  // ==========================================================
// ============================================================
// BANNER FEATURE
// ============================================================

  // ============================================================
// BANNER FEATURE
// ============================================================

  /// Banner Remote DataSource
  getIt.registerLazySingleton<BannerRemoteDataSource>(
        () => BannerRemoteDataSourceImpl(
      client: Supabase.instance.client,
    ),
  );

  /// Banner Repository
  getIt.registerLazySingleton<BannerRepository>(
        () => BannerRepositoryImpl(
      remoteDataSource:
      getIt<BannerRemoteDataSource>(),
    ),
  );

  /// Banner Provider
  getIt.registerFactory<BannerProvider>(
        () => BannerProvider(
      repository:
      getIt<BannerRepository>(),
    ),
  );

  // ==========================================================
  // CATEGORY FEATURE
  // ==========================================================

  getIt.registerLazySingleton<CategoryRemoteDataSource>(
        () => CategoryRemoteDataSource(),
  );

  getIt.registerLazySingleton<CategoryRepository>(
        () => CategoryRepositoryImpl(
      remoteDataSource:
      getIt<CategoryRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<CategoryProvider>(
        () => CategoryProvider(
      repository: getIt<CategoryRepository>(),
    ),
  );

  // ==========================================================
  // PRODUCT FEATURE
  // ==========================================================

  getIt.registerLazySingleton<ProductRemoteDataSource>(
        () => ProductRemoteDataSource(),
  );

  getIt.registerLazySingleton<ProductRepository>(
        () => ProductRepositoryImpl(
      remoteDataSource:
      getIt<ProductRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<ProductProvider>(
        () => ProductProvider(
      repository: getIt<ProductRepository>(),
    ),
  );

  // ==========================================================
  // PRODUCT IMAGE
  // ==========================================================

  getIt.registerLazySingleton<ProductImageRemoteDataSource>(
        () => ProductImageRemoteDataSource(),
  );

  getIt.registerLazySingleton<ProductImageRepository>(
        () => ProductImageRepositoryImpl(
      remoteDataSource:
      getIt<ProductImageRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<ProductImageProvider>(
        () => ProductImageProvider(
      repository:
      getIt<ProductImageRepository>(),
    ),
  );

  // ==========================================================
  // PRODUCT SPECIFICATION
  // ==========================================================

  getIt.registerLazySingleton<
      ProductSpecificationRemoteDataSource>(
        () => ProductSpecificationRemoteDataSource(),
  );

  getIt.registerLazySingleton<
      ProductSpecificationRepository>(
        () => ProductSpecificationRepositoryImpl(
      remoteDataSource:
      getIt<ProductSpecificationRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<ProductSpecificationProvider>(
        () => ProductSpecificationProvider(
      repository:
      getIt<ProductSpecificationRepository>(),
    ),
  );

  // ==========================================================
  // SEARCH
  // ==========================================================

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
      repository:
      getIt<SearchRepository>(),
    ),
  );

  // ==========================================================
  // CATEGORY PRODUCT
  // ==========================================================

  getIt.registerLazySingleton<
      CategoryProductRemoteDataSource>(
        () => CategoryProductRemoteDataSource(),
  );

  getIt.registerLazySingleton<CategoryProductRepository>(
        () => CategoryProductRepositoryImpl(
      remoteDataSource:
      getIt<CategoryProductRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<CategoryProductProvider>(
        () => CategoryProductProvider(
      repository:
      getIt<CategoryProductRepository>(),
    ),
  );

  // ==========================================================
  // CART
  // ==========================================================

  getIt.registerLazySingleton<CartRemoteDataSource>(
        () => CartRemoteDataSource(),
  );

  getIt.registerLazySingleton<CartRepository>(
        () => CartRepositoryImpl(
      remoteDataSource:
      getIt<CartRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<CartProvider>(
        () => CartProvider(
      repository:
      getIt<CartRepository>(),
    ),
  );

  // ==========================================================
  // ORDER
  // ==========================================================

  getIt.registerLazySingleton<OrderRemoteDataSource>(
        () => OrderRemoteDataSource(),
  );

  getIt.registerLazySingleton<OrderRepository>(
        () => OrderRepositoryImpl(
      remoteDataSource:
      getIt<OrderRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<CheckoutProvider>(
        () => CheckoutProvider(
      repository:
      getIt<OrderRepository>(),
      cartProvider:
      getIt<CartProvider>(),
    ),
  );

  getIt.registerFactory<OrderProvider>(
        () => OrderProvider(
      repository:
      getIt<OrderRepository>(),
    ),
  );

  // ==========================================================
  // FAVORITE
  // ==========================================================

  getIt.registerLazySingleton<FavoriteRemoteDataSource>(
        () => FavoriteRemoteDataSource(),
  );

  getIt.registerLazySingleton<FavoriteRepository>(
        () => FavoriteRepositoryImpl(
      remoteDataSource:
      getIt<FavoriteRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<FavoriteProvider>(
        () => FavoriteProvider(
      repository:
      getIt<FavoriteRepository>(),
    ),
  );

  // ==========================================================
  // PROFILE
  // ==========================================================

  getIt.registerLazySingleton<ProfileRemoteDataSource>(
        () => ProfileRemoteDataSource(),
  );

  getIt.registerLazySingleton<ProfileRepository>(
        () => ProfileRepositoryImpl(
      remoteDataSource:
      getIt<ProfileRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetProfileUseCase>(
        () => GetProfileUseCase(
      repository:
      getIt<ProfileRepository>(),
    ),
  );

  getIt.registerLazySingleton<CreateProfileUseCase>(
        () => CreateProfileUseCase(
      repository:
      getIt<ProfileRepository>(),
    ),
  );

  getIt.registerLazySingleton<UpdateProfileUseCase>(
        () => UpdateProfileUseCase(
      repository:
      getIt<ProfileRepository>(),
    ),
  );

  getIt.registerFactory<ProfileProvider>(
        () => ProfileProvider(
      getProfileUseCase:
      getIt<GetProfileUseCase>(),
      createProfileUseCase:
      getIt<CreateProfileUseCase>(),
      updateProfileUseCase:
      getIt<UpdateProfileUseCase>(),
    ),
  );

  // ==========================================================
  // SETTINGS
  // ==========================================================

  getIt.registerLazySingleton<SettingsLocalDataSource>(
        () => SettingsLocalDataSource(
      preferences:
      getIt<SharedPreferences>(),
    ),
  );

  getIt.registerFactory<SettingsProvider>(
        () => SettingsProvider(
      localDataSource:
      getIt<SettingsLocalDataSource>(),
    ),
  );

  // ==========================================================
  // ADDRESS
  // ==========================================================

  getIt.registerLazySingleton<AddressRemoteDataSource>(
        () => AddressRemoteDataSource(),
  );

  getIt.registerLazySingleton<AddressRepository>(
        () => AddressRepositoryImpl(
      remoteDataSource:
      getIt<AddressRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetAddressesUseCase>(
        () => GetAddressesUseCase(
      repository:
      getIt<AddressRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetDefaultAddressUseCase>(
        () => GetDefaultAddressUseCase(
      repository:
      getIt<AddressRepository>(),
    ),
  );

  getIt.registerLazySingleton<AddAddressUseCase>(
        () => AddAddressUseCase(
      repository:
      getIt<AddressRepository>(),
    ),
  );

  getIt.registerLazySingleton<UpdateAddressUseCase>(
        () => UpdateAddressUseCase(
      repository:
      getIt<AddressRepository>(),
    ),
  );

  getIt.registerLazySingleton<DeleteAddressUseCase>(
        () => DeleteAddressUseCase(
      repository:
      getIt<AddressRepository>(),
    ),
  );

  getIt.registerLazySingleton<SetDefaultAddressUseCase>(
        () => SetDefaultAddressUseCase(
      repository:
      getIt<AddressRepository>(),
    ),
  );

  getIt.registerFactory<AddressProvider>(
        () => AddressProvider(
      getAddressesUseCase:
      getIt<GetAddressesUseCase>(),
      getDefaultAddressUseCase:
      getIt<GetDefaultAddressUseCase>(),
      addAddressUseCase:
      getIt<AddAddressUseCase>(),
      updateAddressUseCase:
      getIt<UpdateAddressUseCase>(),
      deleteAddressUseCase:
      getIt<DeleteAddressUseCase>(),
      setDefaultAddressUseCase:
      getIt<SetDefaultAddressUseCase>(),
    ),
  );

  // ==========================================================
  // SHIPPING
  // ==========================================================

  getIt.registerLazySingleton<ShippingRemoteDataSource>(
        () => ShippingRemoteDataSource(),
  );

  getIt.registerLazySingleton<ShippingRepository>(
        () => ShippingRepositoryImpl(
      remoteDataSource:
      getIt<ShippingRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<ShippingProvider>(
        () => ShippingProvider(
      repository:
      getIt<ShippingRepository>(),
    ),
  );

  // ==========================================================
  // FLASH SALE
  // ==========================================================

  getIt.registerLazySingleton<FlashSaleRemoteDataSource>(
        () => FlashSaleRemoteDataSourceImpl(
      supabase:
      Supabase.instance.client,
    ),
  );

  getIt.registerLazySingleton<FlashSaleRepository>(
        () => FlashSaleRepositoryImpl(
      remoteDataSource:
      getIt<FlashSaleRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<
      GetActiveFlashSaleProductsUseCase>(
        () => GetActiveFlashSaleProductsUseCase(
      repository:
      getIt<FlashSaleRepository>(),
    ),
  );

  getIt.registerFactory<FlashSaleProvider>(
        () => FlashSaleProvider(
      getActiveFlashSaleProductsUseCase:
      getIt<GetActiveFlashSaleProductsUseCase>(),
    ),
  );

  // ==========================================================
  // LATEST PRODUCTS
  // ==========================================================

  getIt.registerFactory<LatestProductsProvider>(
        () => LatestProductsProvider(
      repository:
      getIt<ProductRepository>(),
    ),
  );

  // ==========================================================
  // POPULAR PRODUCTS
  // ==========================================================

  getIt.registerFactory<PopularProductsProvider>(
        () => PopularProductsProvider(
      repository:
      getIt<ProductRepository>(),
    ),
  );

  // ==========================================================
  // RELATED PRODUCTS
  // ==========================================================

  getIt.registerFactory<RelatedProductsProvider>(
        () => RelatedProductsProvider(
      repository:
      getIt<ProductRepository>(),
    ),
  );


  //baraye bakhsh review :

  getIt.registerLazySingleton<ReviewRemoteDataSource>(
        () => ReviewRemoteDataSource(),
  );

  getIt.registerLazySingleton<ReviewRepository>(
        () => ReviewRepositoryImpl(
      remoteDataSource:
      getIt<ReviewRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<ReviewProvider>(
        () => ReviewProvider(
      repository: getIt<ReviewRepository>(),
      blockedWordRepository:
      getIt<BlockedWordRepository>(),
    ),
  );

// ==========================================================
// BLOCKED WORD
// ==========================================================

  getIt.registerLazySingleton<
      BlockedWordRemoteDataSource>(
        () => BlockedWordRemoteDataSource(
      client: Supabase.instance.client,
    ),
  );

  getIt.registerLazySingleton<
      BlockedWordRepository>(
        () => BlockedWordRepositoryImpl(
      remoteDataSource:
      getIt<BlockedWordRemoteDataSource>(),
    ),
  );

}