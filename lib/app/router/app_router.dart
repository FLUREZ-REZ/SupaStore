import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/auth_feature/presentation/pages/otp_page.dart';
import 'package:supastore/features/auth_feature/presentation/providers/otp_provider.dart';
import 'package:supastore/features/cart_feature/presentation/providers/cart_provider.dart';
import 'package:supastore/features/category_feature/presentation/pages/category_list_page.dart';
import 'package:supastore/features/category_feature/presentation/pages/category_page.dart';
import 'package:supastore/features/home_feature/domain/entities/category_entity.dart';
import 'package:supastore/features/home_feature/presentation/pages/main_page.dart';
import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';
import 'package:supastore/features/product_feature/presentation/pages/popular_products_page.dart';
import 'package:supastore/features/product_feature/presentation/pages/product_details_page.dart';
import 'package:supastore/features/product_feature/presentation/pages/search_page.dart';
import 'package:supastore/features/product_feature/presentation/providers/product_image_provider.dart';
import 'package:supastore/features/product_feature/presentation/providers/product_specification_provider.dart';
import 'package:supastore/features/product_feature/presentation/widgets/latest_products_page.dart';
import 'package:supastore/features/profile_feature/presentation/pages/edit_profile_page.dart';
import 'package:supastore/features/profile_feature/presentation/providers/profile_provider.dart';
import '../../features/splash_feature/presentation/pages/splash_page.dart';
import '../../features/intro_feature/presentation/pages/intro_page.dart';
import '../../features/auth_feature/presentation/pages/auth_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',

    routes: [

      /// Splash
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      /// Intro
      GoRoute(
        path: '/intro',
        name: 'intro',
        builder: (context, state) => const IntroPage(),
      ),

      /// Auth
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthPage(),
      ),

      /// Home
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) {
          return ChangeNotifierProvider<ProfileProvider>(
            create: (_) => getIt<ProfileProvider>(),
            child: const MainPage(),
          );
        },
      ),


      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final phone = state.extra as String;

          return ChangeNotifierProvider(
            create: (_) => OtpProvider(),

            child: OtpPage(
              phoneNumber: phone,
            ),
          );
        },
      ),

      GoRoute(
        path: '/product-details',
        name: 'product-details',
        builder: (context, state) {
          final product =
          state.extra as ProductEntity;

          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) =>
                getIt<ProductImageProvider>()
                  ..loadImages(product.id),
              ),

              ChangeNotifierProvider(
                create: (_) =>
                getIt<ProductSpecificationProvider>()
                  ..loadSpecifications(product.id),
              ),

              ChangeNotifierProvider.value(
                value: getIt<CartProvider>(),
              ),
            ],
            child: ProductDetailsPage(
              product: product,
            ),
          );
        },
      ),

      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) {
          return const SearchPage();
        },
      ),

      GoRoute(
        name: 'category',
        path: '/category',

        builder: (context, state) {
          final category = state.extra as CategoryEntity;

          return CategoryPage(
            category: category,
          );
        },
      ),

      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) {
          return ChangeNotifierProvider<ProfileProvider>(
            create: (_) => getIt<ProfileProvider>(),
            child: const EditProfilePage(),
          );
        },
      ),

     // see more category part :
      GoRoute(
        name: 'categories',
        path: '/categories',
        builder: (context, state) {
          return const CategoryListPage();
        },
      ),


      GoRoute(
        name: 'latest-products',
        path: '/latest-products',
        builder: (
            context,
            state,
            ) {
          return const LatestProductsPage();
        },
      ),


      GoRoute(
        name: 'popular-products',
        path: '/popular-products',
        builder: (
            context,
            state,
            ) {
          return const PopularProductsPage();
        },
      ),

    ],
  );
}