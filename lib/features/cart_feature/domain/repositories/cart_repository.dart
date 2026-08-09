import 'package:supastore/features/cart_feature/domain/entities/cart_item_entity.dart';

abstract class CartRepository {

  /// دریافت آیتم‌های سبد خرید کاربر
  Future<List<CartItemEntity>> getCartItems(
      String userId,
      );

  /// افزودن محصول به سبد خرید
  Future<CartItemEntity> addToCart({
    required String userId,
    required String productId,
    required int quantity,
  });

  /// تغییر تعداد محصول
  Future<CartItemEntity> updateQuantity({
    required String cartItemId,
    required int quantity,
  });

  /// حذف یک محصول از سبد خرید
  Future<void> removeFromCart(
      String cartItemId,
      );

  /// خالی کردن کامل سبد خرید
  Future<void> clearCart(
      String userId,
      );
}