import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/admin_feature/dashboard/domain/entities/admin_dashboard_entity.dart';
import 'package:supastore/features/admin_feature/dashboard/presentaion/providers/admin_dashboard_provider.dart';
import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';


class _DashboardShimmer extends StatefulWidget {
  const _DashboardShimmer();

  @override
  State<_DashboardShimmer> createState() =>
      _DashboardShimmerState();
}

class _DashboardShimmerState extends State<_DashboardShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            children: [
              SizedBox(height: 6.h),

              _DashboardSkeletonBox(
                animation: _controller,
                width: 175.w,
                height: 22.h,
              ),

              SizedBox(height: 10.h),

              _DashboardSkeletonBox(
                animation: _controller,
                width: 220.w,
                height: 14.h,
              ),

              SizedBox(height: 20.h),

              // آمار فروشگاه
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF023e8a),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _DashboardSkeletonBox(
                          animation: _controller,
                          width: 27.w,
                          height: 27.w,
                        ),
                        _DashboardSkeletonBox(
                          animation: _controller,
                          width: 75.w,
                          height: 12.h,
                        ),
                        _DashboardSkeletonBox(
                          animation: _controller,
                          width: 100.w,
                          height: 17.h,
                        ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: 20.h),

              // نمودار فروش
              _DashboardSkeletonSection(
                animation: _controller,
                height: 320.h,
                titleWidth: 135.w,
                subtitleWidth: 160.w,
                child: SizedBox(
                  height: 195.h,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      70.h,
                      110.h,
                      90.h,
                      150.h,
                      120.h,
                      175.h,
                      135.h,
                    ].map((barHeight) {
                      return _DashboardSkeletonBox(
                        animation: _controller,
                        width: 18.w,
                        height: barHeight,
                        radius: 5.r,
                      );
                    }).toList(),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // سفارش‌های نیازمند اقدام
              _DashboardSkeletonSection(
                animation: _controller,
                height: 250.h,
                titleWidth: 175.w,
                rowCount: 3,
              ),

              SizedBox(height: 20.h),

              // محصولات با موجودی کم
              _DashboardSkeletonSection(
                animation: _controller,
                height: 250.h,
                titleWidth: 105.w,
                rowCount: 3,
                showThumbnail: true,
              ),

              SizedBox(height: 20.h),

              // وضعیت سفارش‌ها
              _DashboardSkeletonSection(
                animation: _controller,
                height: 255.h,
                titleWidth: 140.w,
                rowCount: 5,
                compactRows: true,
              ),

              SizedBox(height: 20.h),

              // آخرین سفارش‌ها
              _DashboardSkeletonSection(
                animation: _controller,
                height: 245.h,
                titleWidth: 130.w,
                rowCount: 3,
                showThumbnail: true,
              ),

              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardSkeletonSection extends StatelessWidget {
  const _DashboardSkeletonSection({
    required this.animation,
    required this.height,
    required this.titleWidth,
    this.subtitleWidth,
    this.rowCount = 0,
    this.showThumbnail = false,
    this.compactRows = false,
    this.child,
  });

  final Animation<double> animation;
  final double height;
  final double titleWidth;
  final double? subtitleWidth;
  final int rowCount;
  final bool showThumbnail;
  final bool compactRows;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFCAF0F8),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardSkeletonBox(
            animation: animation,
            width: titleWidth,
            height: 19.h,
          ),

          if (subtitleWidth != null) ...[
            SizedBox(height: 8.h),
            _DashboardSkeletonBox(
              animation: animation,
              width: subtitleWidth!,
              height: 12.h,
            ),
          ],

          if (child != null) ...[
            const Spacer(),
            child!,
          ],

          if (rowCount > 0) ...[
            SizedBox(height: 20.h),
            ...List.generate(rowCount, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: compactRows ? 15.h : 12.h,
                ),
                child: Row(
                  children: [
                    if (showThumbnail) ...[
                      _DashboardSkeletonBox(
                        animation: animation,
                        width: 43.w,
                        height: 43.w,
                        radius: 10.r,
                      ),
                      SizedBox(width: 10.w),
                    ] else if (!compactRows) ...[
                      _DashboardSkeletonBox(
                        animation: animation,
                        width: 32.w,
                        height: 32.w,
                        radius: 8.r,
                      ),
                      SizedBox(width: 10.w),
                    ],

                    Expanded(
                      child: _DashboardSkeletonBox(
                        animation: animation,
                        width: double.infinity,
                        height: compactRows ? 12.h : 14.h,
                        radius: 4.r,
                      ),
                    ),

                    SizedBox(width: 12.w),

                    _DashboardSkeletonBox(
                      animation: animation,
                      width: compactRows ? 28.w : 48.w,
                      height: compactRows ? 13.h : 25.h,
                      radius: 6.r,
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _DashboardSkeletonBox extends StatelessWidget {
  const _DashboardSkeletonBox({
    required this.animation,
    required this.width,
    required this.height,
    this.radius = 6,
  });

  final Animation<double> animation;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final start = -1.5 + animation.value * 3;

          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(start, 0),
                end: Alignment(start + 1, 0),
                colors: const [
                  Color(0xFFDCEAF0),
                  Color(0xFFF8FCFD),
                  Color(0xFFDCEAF0),
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(bounds);
            },
            child: Container(
              width: width,
              height: height,
              color: const Color(0xFFDCEAF0),
            ),
          );
        },
      ),
    );
  }
}


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
          return const _DashboardShimmer();
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
              SizedBox(height: 6.h),
              Text(
                'خلاصه وضعیت فروشگاه',
                style: TextStyle(
                  color: Color (0xFF03045e),
                  fontSize: 16.sp,
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
              icon: Iconsax.card_copy,
            ),
            _StatCard(
              title: 'سفارش‌ها',
              value: _formatNumber(
                dashboard.periodOrders,
              ),
              icon: Iconsax.box_copy,
            ),
            _StatCard(
              title: 'محصولات',
              value: _formatNumber(
                dashboard.totalProducts,
              ),
              icon: Iconsax.shop_copy,
            ),
            _StatCard(
              title: 'کاربران',
              value: _formatNumber(
                dashboard.totalUsers,
              ),
              icon: Iconsax.people_copy,
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
                  Iconsax.receipt_copy,
                ),
                _StatCard(
                  title: 'فروش ۷ روز اخیر',
                  value:
                  '${_formatPrice(dashboard.periodSales)} تومان',
                  icon:
                  Iconsax.trend_up_copy,
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
        color: Color(0xFFcaf0f8),
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
            color: const Color(0xFF03045e),
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

// ============================================================
// SALES BAR CHART
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
        color: const Color(0xFF03045e),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'فروش ۷ روز اخیر',
            style: TextStyle(
              color: const Color(0xFFcaf0f8),
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            'میزان فروش روزانه',
            style: TextStyle(
              fontSize: 11.5.sp,
              color: const Color(0xFFcaf0f8),
            ),
          ),

          SizedBox(height: 24.h),

          SizedBox(
            height: 250.h,
            child: salesByDay.isEmpty
                ? Center(
              child: Text(
                'داده‌ای برای نمایش وجود ندارد.',
                style: TextStyle(
                  color: const Color(0xFFcaf0f8),
                  fontSize: 12.sp,
                ),
              ),
            )
                : BarChart(
              BarChartData(
                minY: 0,

                alignment: BarChartAlignment.spaceAround,

                maxY: _getMaxY(),

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getInterval(),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.12),
                      strokeWidth: 1,
                    );
                  },
                ),

                borderData: FlBorderData(
                  show: false,
                ),

                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),

                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45.w,
                      interval: _getInterval(),
                      getTitlesWidget: (
                          value,
                          meta,
                          ) {
                        return Text(
                          _compactPricePersian(value),
                          style: TextStyle(
                            fontSize: 8.5.sp,
                            color:
                            const Color(0xFFcaf0f8),
                          ),
                        );
                      },
                    ),
                  ),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32.h,
                      getTitlesWidget: (
                          value,
                          meta,
                          ) {
                        final index = value.toInt();

                        if (index < 0 ||
                            index >= salesByDay.length) {
                          return const SizedBox.shrink();
                        }

                        final date =
                            salesByDay[index].date;

                        return Padding(
                          padding: EdgeInsets.only(
                            top: 8.h,
                          ),
                          child: Text(
                            '${_toPersianDigits(date.day.toString())}/${_toPersianDigits(date.month.toString())}',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color:
                              const Color(0xFFcaf0f8),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData:
                  BarTouchTooltipData(
                    getTooltipItem: (
                        group,
                        groupIndex,
                        rod,
                        rodIndex,
                        ) {
                      return BarTooltipItem(
                        '${_formatPrice(rod.toY.toInt())} تومان',
                        TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                ),

                barGroups: List.generate(
                  salesByDay.length,
                      (index) {
                    final sales =
                        salesByDay[index].sales;

                    return BarChartGroupData(
                      x: index,
                      barsSpace: 0,
                      barRods: [
                        BarChartRodData(
                          toY: sales.toDouble(),
                          width: 18.w,
                          borderRadius:
                          BorderRadius.only(
                            topLeft:
                            Radius.circular(5.r),
                            topRight:
                            Radius.circular(5.r),
                          ),
                          color:
                          const Color(0xFF00B4D8),
                          backDrawRodData:
                          BackgroundBarChartRodData(
                            show: true,
                            toY: _getMaxY(),
                            color:
                            Colors.white
                                .withOpacity(0.06),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxY() {
    if (salesByDay.isEmpty) {
      return 100;
    }

    final maxSales = salesByDay
        .map((item) => item.sales)
        .reduce((a, b) => a > b ? a : b);

    if (maxSales == 0) {
      return 100;
    }

    return maxSales * 1.2;
  }

  double _getInterval() {
    final maxY = _getMaxY();

    if (maxY <= 1000) {
      return 200;
    }

    if (maxY <= 10000) {
      return 2000;
    }

    if (maxY <= 100000) {
      return 20000;
    }

    if (maxY <= 1000000) {
      return 200000;
    }

    if (maxY <= 10000000) {
      return 2000000;
    }

    return maxY / 5;
  }
}

// ============================================================
// PERSIAN COMPACT PRICE
// ============================================================

String _compactPricePersian(double value) {
  if (value >= 1000000000) {
    return '${_toPersianDigits((value / 1000000000).toStringAsFixed(1))}B';
  }

  if (value >= 1000000) {
    return '${_toPersianDigits((value / 1000000).toStringAsFixed(1))}M';
  }

  if (value >= 1000) {
    return '${_toPersianDigits((value / 1000).toStringAsFixed(0))}K';
  }

  return _toPersianDigits(value.toInt().toString());
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
        color: Color(0xFF0096c7),
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
                  const Color(0xFFcaf0f8),
                  borderRadius:
                  BorderRadius.circular(
                    11.r,
                  ),
                ),
                child: Icon(
                  Iconsax.warning_2_copy,
                  size: 21.sp,
                  color:
                  const Color(0xFF03045e),
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
                        color: Colors.white,
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
                        Color(0xFF03045e),
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
                    const Color(0xFFade8f4),
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
                        0xFF03045e,
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
                          0xFFcaf0f8,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          11.r,
                        ),
                      ),
                      child: Icon(
                        Iconsax.box_copy,
                        size: 21.sp,
                        color:
                        const Color(
                          0xFF03045e,
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
                              color: Colors.white,
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
                              9.sp,
                              color:
                              Color(0xFF03045e),
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
        const Color(0xFF03045e);
        background =
        const Color(0xFFF2F7A0);
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
        color: Color(0xFF023e8a),
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
                  const Color(0xFFcaf0f8),
                  borderRadius:
                  BorderRadius.circular(
                    11.r,
                  ),
                ),
                child: Icon(
                  Iconsax.warning_2_copy,
                  size: 21.sp,
                  color:
                  const Color(0xFF03045e),
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
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'محصولاتی که نیاز به تأمین موجودی دارند',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color:
                        Color(0xFFade8f4),
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
                    const Color(0xFFcaf0f8),
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
                        0xFF03045e,
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
                    Iconsax.box_copy,
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
                          0xFFcaf0f8,
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
                            Iconsax.image_copy,
                            size:
                            21.sp,
                            color:
                            Color(0xFF03045e),
                          );
                        },
                      )
                          : Icon(
                        Iconsax.box_copy,
                        size:
                        21.sp,
                        color:
                        Colors.black54,
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
                          color: Colors.white,
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
        icon: Iconsax.clock_copy,
      ),
      _StatusItem(
        title: 'در حال پردازش',
        value: dashboard.processingOrders,
        icon: Iconsax.refresh_copy,
      ),
      _StatusItem(
        title: 'ارسال شده',
        value: dashboard.shippedOrders,
        icon: Iconsax.truck_copy,
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
        color: Color(0xFF90e0ef),
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
              color: Color (0xFF03045e),
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
                      0xFF03045e,
                    ),
                  ),

                  SizedBox(width: 10.w),

                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        color: Color(0xFF03045e),
                        fontSize: 12.5.sp,
                      ),
                    ),
                  ),

                  Text(
                    _formatNumber(
                      item.value,
                    ),
                    style: TextStyle(
                      color: Color(0xFF03045e),
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
        color: Color (0xFFcaf0f8),
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
              color: Color (0xFF03045e),
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
                            0xFF03045e,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            12.r,
                          ),
                        ),
                        child: Icon(
                          Iconsax.shopping_bag_copy,
                          color:
                          const Color(
                            0xFFcaf0f8,
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
                                color: Color (0xFF03045e),
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
                                9.sp,
                                color:
                                Color(0xFF023e8a),
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
        const Color(0xFF03045e),
        borderRadius:
        BorderRadius.circular(
          8.r,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Color (0xFFcaf0f8),
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
              Iconsax.warning_2_copy,
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