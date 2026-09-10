import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/admin_feature/dashboard/domain/entities/admin_dashboard_entity.dart';
import 'package:supastore/features/admin_feature/dashboard/presentaion/providers/admin_dashboard_provider.dart';
import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AdminDashboardProvider>(
      create: (_) =>
      getIt<AdminDashboardProvider>()..loadDashboard(),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDashboardProvider>(
      builder: (
          context,
          provider,
          child,
          ) {
        if (provider.isLoading && !provider.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null && !provider.hasData) {
          return _ErrorView(
            message: provider.error!,
            onRetry: provider.loadDashboard,
          );
        }

        final dashboard = provider.dashboard;

        if (dashboard == null) {
          return _ErrorView(
            message: 'اطلاعات داشبورد موجود نیست.',
            onRetry: provider.loadDashboard,
          );
        }

        return RefreshIndicator(
          onRefresh: provider.refreshDashboard,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            children: [
              Text(
                'خلاصه وضعیت فروشگاه',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),

              SizedBox(height: 6.h),

              Text(
                'نمای کلی عملکرد فروشگاه',
                style: TextStyle(
                  fontSize: 12.5.sp,
                  color: Colors.black54,
                ),
              ),

              SizedBox(height: 18.h),

              _StatsGrid(
                dashboard: dashboard,
              ),

              SizedBox(height: 20.h),

              _SalesChartCard(
                salesByDay: dashboard.salesByDay,
              ),

              SizedBox(height: 20.h),

              _ActionOrdersCard(
                orders: dashboard.actionOrders,
              ),

              SizedBox(height: 20.h),

              _LowStockProductsCard(
                products: dashboard.lowStockProducts,


              ),

              SizedBox(height: 20.h),

              _OrderStatusCard(
                dashboard: dashboard,
              ),

              SizedBox(height: 20.h),

              _RecentOrdersCard(
                orders: dashboard.recentOrders,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// STATS
// ============================================================

class _StatsGrid extends StatefulWidget {
  const _StatsGrid({
    required this.dashboard,
  });

  final AdminDashboardEntity dashboard;

  @override
  State<_StatsGrid> createState() => _StatsGridState();
}

class _StatsGridState extends State<_StatsGrid> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final dashboard = widget.dashboard;

    return Column(
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 1.5,
          children: [
            _StatCard(
              title: 'فروش امروز',
              value:
              '${_formatPrice(dashboard.todaySales)} تومان',
              icon: Icons.payments_rounded,
            ),
            _StatCard(
              title: 'سفارش‌ها',
              value: _formatNumber(
                dashboard.periodOrders,
              ),
              icon: Icons.shopping_bag_rounded,
            ),
            _StatCard(
              title: 'محصولات',
              value: _formatNumber(
                dashboard.totalProducts,
              ),
              icon: Icons.inventory_2_rounded,
            ),
            _StatCard(
              title: 'کاربران',
              value: _formatNumber(
                dashboard.totalUsers,
              ),
              icon: Icons.people_alt_rounded,
            ),
          ],
        ),

        AnimatedSize(
          duration: const Duration(
            milliseconds: 300,
          ),
          curve: Curves.easeInOut,
          child: _isExpanded
              ? Padding(
            padding: EdgeInsets.only(
              top: 12.h,
            ),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  title: 'سفارش امروز',
                  value: _formatNumber(
                    dashboard.todayOrders,
                  ),
                  icon:
                  Icons.receipt_long_rounded,
                ),
                _StatCard(
                  title: 'فروش ۷ روز اخیر',
                  value:
                  '${_formatPrice(dashboard.periodSales)} تومان',
                  icon:
                  Icons.trending_up_rounded,
                ),
              ],
            ),
          )
              : const SizedBox.shrink(),
        ),

        SizedBox(height: 8.h),

        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 6.h,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isExpanded
                      ? 'نمایش کمتر'
                      : 'نمایش بیشتر',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(width: 3.w),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(
                    milliseconds: 300,
                  ),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 23.sp,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            size: 27.sp,
            color: const Color(0xFFE21B23),
          ),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.black54,
            ),
          ),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SALES CHART
// ============================================================

class _SalesChartCard extends StatelessWidget {
  const _SalesChartCard({
    required this.salesByDay,
  });

  final List<AdminSalesDayEntity> salesByDay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'فروش ۷ روز اخیر',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            'روند فروش روزانه',
            style: TextStyle(
              fontSize: 11.5.sp,
              color: Colors.black54,
            ),
          ),

          SizedBox(height: 24.h),

          SizedBox(
            height: 230.h,
            child: salesByDay.isEmpty
                ? const Center(
              child: Text(
                'داده‌ای برای نمایش وجود ندارد.',
              ),
            )
                : LineChart(
              LineChartData(
                minY: 0,

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),

                borderData: FlBorderData(
                  show: false,
                ),

                titlesData: FlTitlesData(
                  topTitles:
                  const AxisTitles(
                    sideTitles:
                    SideTitles(
                      showTitles: false,
                    ),
                  ),

                  rightTitles:
                  const AxisTitles(
                    sideTitles:
                    SideTitles(
                      showTitles: false,
                    ),
                  ),

                  leftTitles: AxisTitles(
                    sideTitles:
                    SideTitles(
                      showTitles: true,
                      reservedSize: 45.w,
                      getTitlesWidget:
                          (
                          value,
                          meta,
                          ) {
                        return Text(
                          _compactPrice(value),
                          style: TextStyle(
                            fontSize: 9.sp,
                            color:
                            Colors.black54,
                          ),
                        );
                      },
                    ),
                  ),

                  bottomTitles: AxisTitles(
                    sideTitles:
                    SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget:
                          (
                          value,
                          meta,
                          ) {
                        final index =
                        value.toInt();

                        if (index < 0 ||
                            index >=
                                salesByDay.length) {
                          return const SizedBox
                              .shrink();
                        }

                        final date =
                            salesByDay[index].date;

                        return Padding(
                          padding:
                          EdgeInsets.only(
                            top: 8.h,
                          ),
                          child: Text(
                            '${date.day}/${date.month}',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color:
                              Colors.black54,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                lineTouchData:
                LineTouchData(
                  touchTooltipData:
                  LineTouchTooltipData(
                    getTooltipItems:
                        (
                        touchedSpots,
                        ) {
                      return touchedSpots.map(
                            (spot) {
                          return LineTooltipItem(
                            '${_formatPrice(spot.y.toInt())} تومان',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          );
                        },
                      ).toList();
                    },
                  ),
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      salesByDay.length,
                          (index) {
                        return FlSpot(
                          index.toDouble(),
                          salesByDay[index]
                              .sales
                              .toDouble(),
                        );
                      },
                    ),
                    isCurved: true,
                    barWidth: 3,
                    dotData:
                    const FlDotData(
                      show: true,
                    ),
                    belowBarData:
                    BarAreaData(
                      show: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ACTION ORDERS
// ============================================================

class _ActionOrdersCard extends StatelessWidget {
  const _ActionOrdersCard({
    required this.orders,
  });

  final List<OrderEntity> orders;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color:
                  const Color(0xFFFFF1E6),
                  borderRadius:
                  BorderRadius.circular(
                    11.r,
                  ),
                ),
                child: Icon(
                  Icons.priority_high_rounded,
                  size: 21.sp,
                  color:
                  const Color(0xFFF57C00),
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سفارش‌های نیازمند اقدام',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'سفارش‌هایی که نیاز به پیگیری دارند',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color:
                        Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              if (orders.isNotEmpty)
                Container(
                  padding:
                  EdgeInsets.symmetric(
                    horizontal: 9.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color:
                    const Color(0xFFFFE9EA),
                    borderRadius:
                    BorderRadius.circular(
                      8.r,
                    ),
                  ),
                  child: Text(
                    _formatNumber(
                      orders.length,
                    ),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight:
                      FontWeight.w800,
                      color:
                      const Color(
                        0xFFE21B23,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 16.h),

          if (orders.isEmpty)
            Container(
              width: double.infinity,
              padding:
              EdgeInsets.symmetric(
                vertical: 20.h,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 34.sp,
                    color: Colors.green,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'سفارشی برای پیگیری وجود ندارد.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:
                      Colors.black54,
                    ),
                  ),
                ],
              ),
            )
          else
            ...orders.map(
                  (order) => Padding(
                padding:
                EdgeInsets.only(
                  bottom: 10.h,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42.w,
                      height: 42.w,
                      decoration:
                      BoxDecoration(
                        color:
                        const Color(
                          0xFFFFF5F5,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          11.r,
                        ),
                      ),
                      child: Icon(
                        Icons
                            .shopping_bag_rounded,
                        size: 21.sp,
                        color:
                        const Color(
                          0xFFE21B23,
                        ),
                      ),
                    ),

                    SizedBox(width: 10.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            'سفارش #${_shortOrderId(order.id)}',
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            TextStyle(
                              fontSize:
                              12.sp,
                              fontWeight:
                              FontWeight
                                  .w700,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${_formatPrice(order.totalPrice)} تومان',
                            style:
                            TextStyle(
                              fontSize:
                              11.sp,
                              color:
                              Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _ActionOrderStatus(
                      status:
                      order.status,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionOrderStatus
    extends StatelessWidget {
  const _ActionOrderStatus({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;
    Color background;

    switch (status) {
      case 'pending':
        text = 'بررسی';
        color =
        const Color(0xFFE65100);
        background =
        const Color(0xFFFFF3E0);
        break;

      case 'processing':
        text = 'پردازش';
        color =
        const Color(0xFF1565C0);
        background =
        const Color(0xFFE3F2FD);
        break;

      case 'shipped':
        text = 'پیگیری ارسال';
        color =
        const Color(0xFF6A1B9A);
        background =
        const Color(0xFFF3E5F5);
        break;

      default:
        text = status;
        color = Colors.black54;
        background =
        const Color(0xFFF3F3F3);
    }

    return Container(
      padding:
      EdgeInsets.symmetric(
        horizontal: 9.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
        BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9.5.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ============================================================
// LOW STOCK PRODUCTS
// ============================================================

class _LowStockProductsCard
    extends StatelessWidget {
  const _LowStockProductsCard({

    required this.products,
  });

  final List<AdminLowStockProductEntity>
  products;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color:
                  const Color(0xFFFFF4E5),
                  borderRadius:
                  BorderRadius.circular(
                    11.r,
                  ),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 21.sp,
                  color:
                  const Color(0xFFF57C00),
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'موجودی کم',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'محصولاتی که نیاز به تأمین موجودی دارند',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color:
                        Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              if (products.isNotEmpty)
                Container(
                  padding:
                  EdgeInsets.symmetric(
                    horizontal: 9.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color:
                    const Color(0xFFFFF1E6),
                    borderRadius:
                    BorderRadius.circular(
                      8.r,
                    ),
                  ),
                  child: Text(
                    _formatNumber(
                      products.length,
                    ),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight:
                      FontWeight.w800,
                      color:
                      const Color(
                        0xFFF57C00,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 16.h),

          if (products.isEmpty)
            Container(
              width: double.infinity,
              padding:
              EdgeInsets.symmetric(
                vertical: 20.h,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_rounded,
                    size: 34.sp,
                    color: Colors.green,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'محصولی با موجودی کم وجود ندارد.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:
                      Colors.black54,
                    ),
                  ),
                ],
              ),
            )
          else
            ...products.map(
                  (product) => Padding(
                padding:
                EdgeInsets.only(
                  bottom: 10.h,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46.w,
                      height: 46.w,
                      decoration:
                      BoxDecoration(
                        color:
                        const Color(
                          0xFFF7F7F7,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          11.r,
                        ),
                      ),
                      clipBehavior:
                      Clip.antiAlias,
                      child:
                      product.thumbnail !=
                          null &&
                          product.thumbnail!
                              .isNotEmpty
                          ? Image.network(
                        product.thumbnail!,
                        width: 46.w,
                        height: 46.w,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (
                            context,
                            error,
                            stackTrace,
                            ) {
                          return Icon(
                            Icons
                                .image_not_supported_outlined,
                            size:
                            21.sp,
                            color:
                            Colors.black38,
                          );
                        },
                      )
                          : Icon(
                        Icons
                            .inventory_2_outlined,
                        size:
                        21.sp,
                        color:
                        Colors.black38,
                      ),
                    ),

                    SizedBox(width: 10.w),

                    Expanded(
                      child: Text(
                        product.title,
                        maxLines: 2,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(width: 8.w),

                    _StockBadge(
                      stock:
                      product.stock,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({
    required this.stock,
  });

  final int stock;

  @override
  Widget build(BuildContext context) {
    final bool critical = stock <= 2;

    return Container(
      padding:
      EdgeInsets.symmetric(
        horizontal: 9.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: critical
            ? const Color(0xFFFFE9EA)
            : const Color(0xFFFFF3E0),
        borderRadius:
        BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Text(
            _formatNumber(stock),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight:
              FontWeight.w800,
              color: critical
                  ? const Color(
                0xFFE21B23,
              )
                  : const Color(
                0xFFF57C00,
              ),
            ),
          ),
          Text(
            'موجودی',
            style: TextStyle(
              fontSize: 8.5.sp,
              color: critical
                  ? const Color(
                0xFFE21B23,
              )
                  : const Color(
                0xFFF57C00,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ORDER STATUS
// ============================================================

class _OrderStatusCard extends StatelessWidget {
  const _OrderStatusCard({
    required this.dashboard,
  });

  final AdminDashboardEntity dashboard;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatusItem(
        title: 'در انتظار بررسی',
        value: dashboard.pendingOrders,
        icon: Icons.schedule_rounded,
      ),
      _StatusItem(
        title: 'در حال پردازش',
        value: dashboard.processingOrders,
        icon: Icons.autorenew_rounded,
      ),
      _StatusItem(
        title: 'ارسال شده',
        value: dashboard.shippedOrders,
        icon: Icons.local_shipping_rounded,
      ),
      _StatusItem(
        title: 'تحویل داده شده',
        value: dashboard.deliveredOrders,
        icon: Icons.check_circle_rounded,
      ),
      _StatusItem(
        title: 'لغو شده',
        value: dashboard.canceledOrders,
        icon: Icons.cancel_rounded,
      ),
    ];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'وضعیت سفارش‌ها',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight:
              FontWeight.w800,
            ),
          ),

          SizedBox(height: 14.h),

          ...items.map(
                (item) => Padding(
              padding:
              EdgeInsets.only(
                bottom: 10.h,
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 21.sp,
                    color:
                    const Color(
                      0xFFE21B23,
                    ),
                  ),

                  SizedBox(width: 10.w),

                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                      ),
                    ),
                  ),

                  Text(
                    _formatNumber(
                      item.value,
                    ),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusItem {
  const _StatusItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final int value;
  final IconData icon;
}

// ============================================================
// RECENT ORDERS
// ============================================================

class _RecentOrdersCard extends StatelessWidget {
  const _RecentOrdersCard({
    required this.orders,
  });

  final List<OrderEntity> orders;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'آخرین سفارش‌ها',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight:
              FontWeight.w800,
            ),
          ),

          SizedBox(height: 12.h),

          if (orders.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'هنوز سفارشی ثبت نشده است.',
                ),
              ),
            )
          else
            ...orders.map(
                  (order) {
                final status =
                    order.status;

                return Padding(
                  padding:
                  EdgeInsets.only(
                    bottom: 10.h,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42.w,
                        height: 42.w,
                        decoration:
                        BoxDecoration(
                          color:
                          const Color(
                            0xFFFFE9EA,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            12.r,
                          ),
                        ),
                        child: Icon(
                          Icons
                              .shopping_bag_rounded,
                          color:
                          const Color(
                            0xFFE21B23,
                          ),
                          size: 22.sp,
                        ),
                      ),

                      SizedBox(width: 10.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Text(
                              'سفارش #${_shortOrderId(order.id)}',
                              style:
                              TextStyle(
                                fontSize:
                                12.sp,
                                fontWeight:
                                FontWeight
                                    .w700,
                              ),
                            ),

                            SizedBox(
                              height: 4.h,
                            ),

                            Text(
                              '${_formatPrice(order.totalPrice)} تومان',
                              style:
                              TextStyle(
                                fontSize:
                                11.sp,
                                color:
                                Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      _OrderStatusBadge(
                        status:
                        status,
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _OrderStatusBadge
    extends StatelessWidget {
  const _OrderStatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    String text;

    switch (status) {
      case 'pending':
        text = 'در انتظار';
        break;

      case 'processing':
        text = 'پردازش';
        break;

      case 'shipped':
        text = 'ارسال شده';
        break;

      case 'delivered':
        text = 'تحویل شده';
        break;

      case 'canceled':
      case 'cancelled':
        text = 'لغو شده';
        break;

      default:
        text = status;
    }

    return Container(
      padding:
      EdgeInsets.symmetric(
        horizontal: 9.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color:
        const Color(0xFFF3F3F3),
        borderRadius:
        BorderRadius.circular(
          8.r,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9.5.sp,
          fontWeight:
          FontWeight.w600,
        ),
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: Colors.red,
            ),

            SizedBox(height: 12.h),

            Text(
              message,
              textAlign:
              TextAlign.center,
            ),

            SizedBox(height: 16.h),

            ElevatedButton(
              onPressed: onRetry,
              child:
              const Text(
                'تلاش مجدد',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

String _formatNumber(int value) {
  final text = value.toString();

  final buffer = StringBuffer();

  for (int i = 0; i < text.length; i++) {
    if (i > 0 &&
        (text.length - i) % 3 == 0) {
      buffer.write(',');
    }

    buffer.write(text[i]);
  }

  return _toPersianDigits(
    buffer.toString(),
  );
}

String _formatPrice(int value) {
  return _formatNumber(value);
}

String _compactPrice(double value) {
  if (value >= 1000000000) {
    return '${(value / 1000000000).toStringAsFixed(1)}B';
  }

  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }

  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(0)}K';
  }

  return value.toInt().toString();
}

String _shortOrderId(String id) {
  if (id.length <= 8) {
    return id;
  }

  return id.substring(0, 8);
}

String _toPersianDigits(String value) {
  const english = '0123456789';
  const persian = '۰۱۲۳۴۵۶۷۸۹';

  return value.split('').map((char) {
    final index =
    english.indexOf(char);

    if (index == -1) {
      return char;
    }

    return persian[index];
  }).join();
}