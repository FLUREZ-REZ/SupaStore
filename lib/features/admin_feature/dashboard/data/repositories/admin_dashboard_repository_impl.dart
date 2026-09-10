import 'package:supastore/features/admin_feature/dashboard/data/datasource/admin_dashboard_remote_datasource.dart';
import 'package:supastore/features/admin_feature/dashboard/domain/entities/admin_dashboard_entity.dart';
import 'package:supastore/features/admin_feature/dashboard/domain/repositories/admin_dashboard_repository.dart';
import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';
import 'package:supastore/features/order_feature/domain/entities/order_item_entity.dart';

class AdminDashboardRepositoryImpl
    implements AdminDashboardRepository {
  AdminDashboardRepositoryImpl({
    required AdminDashboardRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final AdminDashboardRemoteDataSource
  _remoteDataSource;

  @override
  Future<AdminDashboardEntity>
  getDashboardData() async {
    final stats =
    await _remoteDataSource.getDashboardStats(
      days: 7,
    );

    final totalProducts =
    await _remoteDataSource.getTotalProducts();

    final totalUsers =
    await _remoteDataSource.getTotalUsers();

    final recentOrders =
    await _remoteDataSource.getRecentOrders();

    return AdminDashboardEntity(
      todaySales:
      (stats['today_sales'] as num?)
          ?.toInt() ??
          0,

      todayOrders:
      (stats['today_orders'] as num?)
          ?.toInt() ??
          0,

      periodSales:
      (stats['period_sales'] as num?)
          ?.toInt() ??
          0,

      periodOrders:
      (stats['period_orders'] as num?)
          ?.toInt() ??
          0,

      pendingOrders:
      (stats['pending_orders'] as num?)
          ?.toInt() ??
          0,

      processingOrders:
      (stats['processing_orders'] as num?)
          ?.toInt() ??
          0,

      shippedOrders:
      (stats['shipped_orders'] as num?)
          ?.toInt() ??
          0,

      deliveredOrders:
      (stats['delivered_orders'] as num?)
          ?.toInt() ??
          0,

      canceledOrders:
      (stats['canceled_orders'] as num?)
          ?.toInt() ??
          0,

      salesByDay:
      _mapSalesByDay(
        stats['sales_by_day'],
      ),

      totalProducts:
      totalProducts,

      totalUsers:
      totalUsers,

      recentOrders:
      recentOrders
          .map(_mapOrder)
          .toList(),

      actionOrders:
      _mapOrders(
        stats['action_orders'],
      ),

      lowStockProducts:
      _mapLowStockProducts(
        stats['low_stock_products'],
      ),
    );
  }

  List<AdminSalesDayEntity>
  _mapSalesByDay(
      dynamic value,
      ) {
    if (value is! List) {
      return [];
    }

    return value.map((item) {
      final map =
      Map<String, dynamic>.from(item);

      return AdminSalesDayEntity(
        date: DateTime.parse(
          map['date'].toString(),
        ),
        sales:
        (map['sales'] as num?)
            ?.toInt() ??
            0,
        orders:
        (map['orders'] as num?)
            ?.toInt() ??
            0,
      );
    }).toList();
  }

  List<OrderEntity> _mapOrders(
      dynamic value,
      ) {
    if (value is! List) {
      return [];
    }

    return value.map((item) {
      return _mapOrder(
        Map<String, dynamic>.from(item),
      );
    }).toList();
  }

  List<AdminLowStockProductEntity>
  _mapLowStockProducts(
      dynamic value,
      ) {
    if (value is! List) {
      return [];
    }

    return value.map((item) {
      final map =
      Map<String, dynamic>.from(item);

      return AdminLowStockProductEntity(
        id: map['id'].toString(),
        title:
        map['title']?.toString() ?? '',
        thumbnail:
        map['thumbnail']?.toString(),
        stock:
        (map['stock'] as num?)
            ?.toInt() ??
            0,
      );
    }).toList();
  }

  OrderEntity _mapOrder(
      Map<String, dynamic> data,
      ) {
    final rawItems =
    data['order_items'];

    final items = rawItems is List
        ? rawItems
        .map(
          (item) => _mapOrderItem(
        Map<String, dynamic>.from(
          item,
        ),
      ),
    )
        .toList()
        : <OrderItemEntity>[];

    return OrderEntity(
      id: data['id'].toString(),

      userId:
      data['user_id'].toString(),

      addressId:
      data['address_id']?.toString(),

      status:
      data['status']?.toString() ??
          'pending',

      paymentStatus:
      data['payment_status']
          ?.toString() ??
          'pending',

      paymentMethod:
      data['payment_method']
          ?.toString(),

      subtotal:
      (data['subtotal'] as num?)
          ?.toInt() ??
          0,

      discount:
      (data['discount'] as num?)
          ?.toInt() ??
          0,

      shippingCost:
      (data['shipping_cost'] as num?)
          ?.toInt() ??
          0,

      totalPrice:
      (data['total_price'] as num?)
          ?.toInt() ??
          0,

      shippingAddress:
      data['shipping_address']
          ?.toString(),

      createdAt:
      DateTime.parse(
        data['created_at'].toString(),
      ),

      updatedAt:
      DateTime.parse(
        data['updated_at'].toString(),
      ),

      items: items,
    );
  }

  OrderItemEntity _mapOrderItem(
      Map<String, dynamic> data,
      ) {
    return OrderItemEntity(
      id: data['id'].toString(),

      orderId:
      data['order_id'].toString(),

      productId:
      data['product_id']?.toString(),

      productTitle:
      data['product_title']
          ?.toString() ??
          '',

      productThumbnail:
      data['product_thumbnail']
          ?.toString(),

      quantity:
      (data['quantity'] as num?)
          ?.toInt() ??
          0,

      unitPrice:
      (data['unit_price'] as num?)
          ?.toInt() ??
          0,

      discountPrice:
      (data['discount_price'] as num?)
          ?.toInt(),

      totalPrice:
      (data['total_price'] as num?)
          ?.toInt() ??
          0,

      createdAt:
      DateTime.parse(
        data['created_at'].toString(),
      ),
    );
  }
}