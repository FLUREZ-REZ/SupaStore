import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';

import 'package:supastore/features/admin_feature/presentation/pages/admin_main_page.dart';

import 'package:supastore/features/auth_feature/presentation/pages/admin_page.dart';
import 'package:supastore/features/auth_feature/presentation/pages/auth_page.dart';
import 'package:supastore/features/auth_feature/presentation/pages/otp_page.dart';
import 'package:supastore/features/auth_feature/presentation/providers/otp_provider.dart';

import 'package:supastore/features/cart_feature/presentation/providers/cart_provider.dart';

import 'package:supastore/features/category_feature/presentation/pages/category_list_page.dart';
import 'package:supastore/features/category_feature/presentation/pages/category_page.dart';

import 'package:supastore/features/flash_sale_feature/presentation/pages/flash_sale_page.dart';

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

import 'package:supastore/features/payment_feature/presentation/pages/payment_result_page.dart';

import '../../features/splash_feature/presentation/pages/splash_page.dart';
import '../../features/intro_feature/presentation/pages/intro_page.dart';


class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',

    routes: [

      // ==========================================================
      // Splash
      // ==========================================================

      GoRoute(
        path: '/',
        name: 'splash',
        builder: (
            context,
            state,
            ) {
          return const SplashPage();
        },
      ),

      // ==========================================================
      // Intro
      // ==========================================================

      GoRoute(
        path: '/intro',
        name: 'intro',
        builder: (
            context,
            state,
            ) {
          return const IntroPage();
        },
      ),

      // ==========================================================
      // Auth
      // ==========================================================

      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (
            context,
            state,
            ) {
          return const AuthPage();
        },
      ),

      // ==========================================================
      // Home
      // ==========================================================

      GoRoute(
        path: '/home',
        name: 'home',
        builder: (
            context,
            state,
            ) {
          return ChangeNotifierProvider<
              ProfileProvider>(
            create: (_) =>
                getIt<ProfileProvider>(),
            child: const MainPage(),
          );
        },
      ),

      // ==========================================================
      // OTP
      // ==========================================================

      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (
            context,
            state,
            ) {
          final phone =
          state.extra as String;

          return ChangeNotifierProvider<
              OtpProvider>(
            create: (_) =>
                OtpProvider(),
            child: OtpPage(
              phoneNumber: phone,
            ),
          );
        },
      ),

      // ==========================================================
      // Product Details
      // ==========================================================

      GoRoute(
        path: '/product-details',
        name: 'product-details',
        builder: (
            context,
            state,
            ) {
          final product =
          state.extra as ProductEntity;

          return MultiProvider(
            providers: [

              ChangeNotifierProvider(
                create: (_) =>
                getIt<ProductImageProvider>()
                  ..loadImages(
                    product.id,
                  ),
              ),

              ChangeNotifierProvider(
                create: (_) =>
                getIt<
                    ProductSpecificationProvider>()
                  ..loadSpecifications(
                    product.id,
                  ),
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

      // ==========================================================
      // Search
      // ==========================================================

      GoRoute(
        path: '/search',
        name: 'search',
        builder: (
            context,
            state,
            ) {
          return const SearchPage();
        },
      ),

      // ==========================================================
      // Category
      // ==========================================================

      GoRoute(
        path: '/category',
        name: 'category',
        builder: (
            context,
            state,
            ) {
          final category =
          state.extra as CategoryEntity;

          return CategoryPage(
            category: category,
          );
        },
      ),

      // ==========================================================
      // Edit Profile
      // ==========================================================

      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (
            context,
            state,
            ) {
          return ChangeNotifierProvider<
              ProfileProvider>(
            create: (_) =>
                getIt<ProfileProvider>(),
            child:
            const EditProfilePage(),
          );
        },
      ),

      // ==========================================================
      // Categories
      // ==========================================================

      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (
            context,
            state,
            ) {
          return const CategoryListPage();
        },
      ),

      // ==========================================================
      // Latest Products
      // ==========================================================

      GoRoute(
        path: '/latest-products',
        name: 'latest-products',
        builder: (
            context,
            state,
            ) {
          return const LatestProductsPage();
        },
      ),

      // ==========================================================
      // Popular Products
      // ==========================================================

      GoRoute(
        path: '/popular-products',
        name: 'popular-products',
        builder: (
            context,
            state,
            ) {
          return const PopularProductsPage();
        },
      ),

      // ==========================================================
      // Flash Sale
      // ==========================================================

      GoRoute(
        path: '/flash-sale',
        name: 'flash-sale',
        builder: (
            context,
            state,
            ) {
          return const FlashSalePage();
        },
      ),

      // ==========================================================
      // Admin
      // ==========================================================

      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (
            context,
            state,
            ) {
          return const AdminMainPage();
        },
      ),

      // ==========================================================
      // PAYMENT RESULT
      // ==========================================================

      GoRoute(
        path: '/payment-result',
        name: 'payment-result',
        builder: (
            context,
            state,
            ) {
          final data =
          state.extra
          as Map<String, dynamic>?;

          final orderId =
          data?['orderId']
              ?.toString();

          final status =
          data?['status']
              ?.toString();

          final refId =
          data?['refId']
              ?.toString();

          if (orderId == null ||
              orderId.isEmpty) {
            return const Scaffold(
              body: Center(
                child: Text(
                  'شناسه سفارش نامعتبر است.',
                ),
              ),
            );
          }

          return PaymentResultPage(
            orderId: orderId,
            status: status,
            refId: refId,
          );
        },
      ),
    ],
  );
}