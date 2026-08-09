import 'package:supastore/features/order_feature/data/datasource/order_remote_datasource.dart';
import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';
import 'package:supastore/features/order_feature/domain/entities/order_item_entity.dart';
import 'package:supastore/features/order_feature/domain/repositories/order_repository.dart';

class OrderRepositoryImpl
    implements OrderRepository {
  OrderRepositoryImpl({
    required OrderRemoteDataSource
    remoteDataSource,
  }) : _remoteDataSource =
      remoteDataSource;

  final OrderRemoteDataSource
  _remoteDataSource;

  OrderItemEntity _mapOrderItem(
      Map<String, dynamic> map,
      ) {
    return OrderItemEntity(
      id: map['id'] as String,
      orderId:
      map['order_id'] as String,
      productId:
      map['product_id'] as String?,
      productTitle:
      map['product_title'] as String,
      productThumbnail:
      map['product_thumbnail']
      as String?,
      quantity:
      map['quantity'] as int,
      unitPrice:
      map['unit_price'] as int,
      discountPrice:
      map['discount_price'] as int?,
      totalPrice:
      map['total_price'] as int,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
    );
  }

  OrderEntity _mapOrder(
      Map<String, dynamic> map,
      ) {
    final itemsData =
        map['order_items']
        as List<dynamic>? ??
            [];

    final items = itemsData
        .map(
          (item) => _mapOrderItem(
        Map<String, dynamic>.from(
          item,
        ),
      ),
    )
        .toList();

    return OrderEntity(
      id: map['id'] as String,
      userId:
      map['user_id'] as String,
      status:
      map['status'] as String,
      paymentStatus:
      map['payment_status']
      as String,
      paymentMethod:
      map['payment_method']
      as String?,
      subtotal:
      map['subtotal'] as int,
      discount:
      map['discount'] as int,
      shippingCost:
      map['shipping_cost'] as int,
      totalPrice:
      map['total_price'] as int,
      shippingAddress:
      map['shipping_address']
      as String?,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] as String,
      ),
      items: items,
    );
  }

  Map<String, dynamic>
  _mapItemToMap(
      OrderItemEntity item,
      ) {
    return {
      'product_id':
      item.productId,
      'product_title':
      item.productTitle,
      'product_thumbnail':
      item.productThumbnail,
      'quantity':
      item.quantity,
      'unit_price':
      item.unitPrice,
      'discount_price':
      item.discountPrice,
      'total_price':
      item.totalPrice,
    };
  }

  @override
  Future<OrderEntity> checkout({
    required String userId,
    required int subtotal,
    required int discount,
    required int shippingCost,
    required int totalPrice,
    required String shippingAddress,
    required String paymentMethod,
    required List<OrderItemEntity> items,
  }) async {
    final result =
    await _remoteDataSource
        .checkout(
      userId: userId,
      subtotal: subtotal,
      discount: discount,
      shippingCost:
      shippingCost,
      totalPrice:
      totalPrice,
      shippingAddress:
      shippingAddress,
      paymentMethod:
      paymentMethod,
      items: items
          .map(_mapItemToMap)
          .toList(),
    );

    return _mapOrder(result);
  }

  @override
  Future<OrderEntity>
  createOrder({
    required String userId,
    required int subtotal,
    required int discount,
    required int shippingCost,
    required int totalPrice,
    required String shippingAddress,
    required String paymentMethod,
    required List<OrderItemEntity> items,
  }) async {
    final result =
    await _remoteDataSource
        .createOrder(
      userId: userId,
      subtotal: subtotal,
      discount: discount,
      shippingCost:
      shippingCost,
      totalPrice:
      totalPrice,
      shippingAddress:
      shippingAddress,
      paymentMethod:
      paymentMethod,
      items: items
          .map(_mapItemToMap)
          .toList(),
    );

    return _mapOrder(result);
  }

  @override
  Future<List<OrderEntity>>
  getOrders(
      String userId,
      ) async {
    final result =
    await _remoteDataSource
        .getOrders(
      userId,
    );

    return result
        .map(_mapOrder)
        .toList();
  }

  @override
  Future<OrderEntity>
  getOrderById(
      String orderId,
      ) async {
    final result =
    await _remoteDataSource
        .getOrderById(
      orderId,
    );

    return _mapOrder(result);
  }
}