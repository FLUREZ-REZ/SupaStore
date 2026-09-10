import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';

class AdminDashboardEntity {
  const AdminDashboardEntity({
    required this.todaySales,
    required this.todayOrders,
    required this.periodSales,
    required this.periodOrders,
    required this.pendingOrders,
    required this.processingOrders,
    required this.shippedOrders,
    required this.deliveredOrders,
    required this.canceledOrders,
    required this.salesByDay,
    required this.totalProducts,
    required this.totalUsers,
    required this.recentOrders,
    required this.actionOrders,
    required this.lowStockProducts,
  });

  final int todaySales;
  final int todayOrders;
  final int periodSales;
  final int periodOrders;

  final int pendingOrders;
  final int processingOrders;
  final int shippedOrders;
  final int deliveredOrders;
  final int canceledOrders;

  final List<AdminSalesDayEntity> salesByDay;

  final int totalProducts;
  final int totalUsers;

  final List<OrderEntity> recentOrders;

  final List<OrderEntity> actionOrders;

  final List<AdminLowStockProductEntity> lowStockProducts;
}

class AdminSalesDayEntity {
  const AdminSalesDayEntity({
    required this.date,
    required this.sales,
    required this.orders,
  });

  final DateTime date;
  final int sales;
  final int orders;
}

class AdminLowStockProductEntity {
  const AdminLowStockProductEntity({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.stock,
  });

  final String id;
  final String title;
  final String? thumbnail;
  final int stock;
}