import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:supastore/core/di/injector.dart';

import 'package:supastore/features/home_feature/domain/entities/banner_entity.dart';

import 'package:supastore/features/category_feature/presentation/providers/category_product_provider.dart';

import 'package:supastore/features/product_feature/presentation/providers/product_provider.dart';

class BannerNavigationHandler {
  BannerNavigationHandler._();

  static Future<void> handle({
    required BuildContext context,
    required BannerEntity banner,
  }) async {
    final actionType = banner.actionType;
    final actionValue = banner.actionValue;

    // -----------------------------------------------
    // No action
    // -----------------------------------------------

    if (actionType == null ||
        actionType.isEmpty ||
        actionValue == null ||
        actionValue.isEmpty) {
      return;
    }

    switch (actionType) {
    // =============================================
    // PRODUCT
    // =============================================

      case 'product':
        await _openProduct(
          context: context,
          productId: actionValue,
        );
        break;

    // =============================================
    // CATEGORY
    // =============================================

      case 'category':
        await _openCategory(
          context: context,
          categoryId: actionValue,
        );
        break;

    // =============================================
    // URL
    // =============================================

      case 'url':
      // بعداً می‌توانیم
      // url_launcher را اضافه کنیم.
        break;

      default:
        debugPrint(
          '⚠️ Unknown banner action type: $actionType',
        );
    }
  }

  // =================================================
  // PRODUCT
  // =================================================

  static Future<void> _openProduct({
    required BuildContext context,
    required String productId,
  }) async {
    try {
      final productProvider =
      getIt<ProductProvider>();

      final product =
      await productProvider.getProductById(
        productId,
      );

      if (!context.mounted) {
        return;
      }

      if (product == null) {
        _showMessage(
          context,
          'محصول مورد نظر پیدا نشد',
        );

        return;
      }

      context.pushNamed(
        'product-details',
        extra: product,
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      debugPrint(
        '❌ Banner product navigation error: $e',
      );

      _showMessage(
        context,
        'خطا در باز کردن محصول',
      );
    }
  }

  // =================================================
  // CATEGORY
  // =================================================

  static Future<void> _openCategory({
    required BuildContext context,
    required String categoryId,
  }) async {
    try {
      final categoryProductProvider =
      getIt<CategoryProductProvider>();

      final category =
      await categoryProductProvider
          .getCategoryById(
        categoryId,
      );

      if (!context.mounted) {
        return;
      }

      if (category == null) {
        _showMessage(
          context,
          'دسته‌بندی مورد نظر پیدا نشد',
        );

        return;
      }

      context.pushNamed(
        'category',
        extra: category,
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      debugPrint(
        '❌ Banner category navigation error: $e',
      );

      _showMessage(
        context,
        'خطا در باز کردن دسته‌بندی',
      );
    }
  }

  // =================================================
  // SnackBar
  // =================================================

  static void _showMessage(
      BuildContext context,
      String message,
      ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }
}