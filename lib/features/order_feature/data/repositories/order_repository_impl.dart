import 'package:supastore/features/order_feature/data/datasource/order_remote_datasource.dart';
import 'package:supastore/features/order_feature/domain/entities/checkout_result_entity.dart';
import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';
import 'package:supastore/features/order_feature/domain/entities/order_item_entity.dart';
import 'package:supastore/features/order_feature/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({
    required OrderRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final OrderRemoteDataSource _remoteDataSource;

  // ============================================================
  // SECURE CHECKOUT
  // ============================================================

  @override
  Future<CheckoutResultEntity> createCheckout({
    required String addressId,
    required String shippingMethodId,
    required String paymentMethod,
  }) async {
    final result =
    await _remoteDataSource.createCheckout(
      addressId: addressId,
      shippingMethodId: shippingMethodId,
      paymentMethod: paymentMethod,
    );

    return _mapCheckoutResult(result);
  }

  // ============================================================
  // LEGACY CHECKOUT
  // ============================================================

  @override
  Future<OrderEntity> checkout({
    required String userId,
    required String addressId,
    required int subtotal,
    required int discount,
    required int shippingCost,
    required int totalPrice,
    required String shippingAddress,
    required String paymentMethod,
    required List<OrderItemEntity> items,
  }) async {
    final result =
    await _remoteDataSource.checkout(
      userId: userId,
      addressId: addressId,
      subtotal: subtotal,
      discount: discount,
      shippingCost: shippingCost,
      totalPrice: totalPrice,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      items: items,
    );

    return _mapOrder(result);
  }

  // ============================================================
  // CREATE ORDER
  // ============================================================

  @override
  Future<OrderEntity> createOrder({
    required String userId,
    required String addressId,
    required int subtotal,
    required int discount,
    required int shippingCost,
    required int totalPrice,
    required String shippingAddress,
    required String paymentMethod,
    required List<OrderItemEntity> items,
  }) async {
    final result =
    await _remoteDataSource.createOrder(
      userId: userId,
      addressId: addressId,
      subtotal: subtotal,
      discount: discount,
      shippingCost: shippingCost,
      totalPrice: totalPrice,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      items: items,
    );

    return _mapOrder(result);
  }

  // ============================================================
  // GET ORDERS
  // ============================================================

  @override
  Future<List<OrderEntity>> getOrders(
      String userId,
      ) async {
    final result =
    await _remoteDataSource.getOrders(
      userId,
    );

    return result
        .map(_mapOrder)
        .toList();
  }

  // ============================================================
  // GET ORDER BY ID
  // ============================================================

  @override
  Future<OrderEntity> getOrderById(
      String orderId,
      ) async {
    final result =
    await _remoteDataSource.getOrderById(
      orderId,
    );

    return _mapOrder(result);
  }

  // ============================================================
  // GET USER ORDERS
  // ============================================================

  @override
  Future<List<OrderEntity>> getUserOrders(
      String userId,
      ) async {
    final result =
    await _remoteDataSource.getUserOrders(
      userId,
    );

    return result
        .map(_mapOrder)
        .toList();
  }

  // ============================================================
  // MAP CHECKOUT RESULT
  // ============================================================

  CheckoutResultEntity _mapCheckoutResult(
      Map<String, dynamic> map,
      ) {
    final orderId =
    map['order_id'];

    final paymentId =
    map['payment_id'];

    final amount =
    map['amount'];

    final currency =
    map['currency'];

    final authority =
    map['authority'];

    final paymentUrl =
    map['payment_url'];

    final sandbox =
    map['sandbox'];

    if (orderId is! String ||
        orderId.isEmpty) {
      throw Exception(
        'شناسه سفارش نامعتبر است.',
      );
    }

    if (paymentId is! String ||
        paymentId.isEmpty) {
      throw Exception(
        'شناسه پرداخت نامعتبر است.',
      );
    }

    if (amount is! num) {
      throw Exception(
        'مبلغ پرداخت نامعتبر است.',
      );
    }

    if (currency is! String ||
        currency.isEmpty) {
      throw Exception(
        'واحد پول نامعتبر است.',
      );
    }

    if (authority is! String ||
        authority.isEmpty) {
      throw Exception(
        'Authority پرداخت نامعتبر است.',
      );
    }

    if (paymentUrl is! String ||
        paymentUrl.isEmpty) {
      throw Exception(
        'آدرس درگاه پرداخت نامعتبر است.',
      );
    }

    return CheckoutResultEntity(
      orderId: orderId,
      paymentId: paymentId,
      amount: amount.toInt(),
      currency: currency,
      authority: authority,
      paymentUrl: paymentUrl,
      sandbox: sandbox == true,
    );
  }

  // ============================================================
  // MAP ORDER
  // ============================================================

  OrderEntity _mapOrder(
      Map<String, dynamic> map,
      ) {
    final rawItems =
    map['order_items'];

    final List<OrderItemEntity> items =
    rawItems is List
        ? rawItems
        .map(
          (item) => _mapOrderItem(
        Map<String, dynamic>.from(
          item,
        ),
      ),
    )
        .toList()
        : [];

    return OrderEntity(
      id: map['id'] as String,

      userId:
      map['user_id'] as String,

      addressId:
      map['address_id'] as String?,

      subtotal:
      map['subtotal'] as int,

      discount:
      map['discount'] as int,

      shippingCost:
      map['shipping_cost'] as int,

      totalPrice:
      map['total_price'] as int,

      shippingAddress:
      map['shipping_address'] as String?,

      paymentMethod:
      map['payment_method'] as String?,

      paymentStatus:
      map['payment_status'] as String,

      status:
      map['status'] as String,

      createdAt:
      DateTime.parse(
        map['created_at'] as String,
      ),

      updatedAt:
      DateTime.parse(
        map['updated_at'] as String,
      ),

      items: items,
    );
  }

  // ============================================================
  // MAP ORDER ITEM
  // ============================================================

  OrderItemEntity _mapOrderItem(
      Map<String, dynamic> map,
      ) {
    return OrderItemEntity(
      id: map['id'] as String,

      orderId:
      map['order_id'] as String,

      productId:
      map['product_id'] as String,

      productTitle:
      map['product_title'] as String,

      productThumbnail:
      map['product_thumbnail'] as String,

      quantity:
      map['quantity'] as int,

      unitPrice:
      map['unit_price'] as int,

      discountPrice:
      map['discount_price'] as int?,

      totalPrice:
      map['total_price'] as int,

      createdAt:
      DateTime.parse(
        map['created_at'] as String,
      ),
    );
  }
}